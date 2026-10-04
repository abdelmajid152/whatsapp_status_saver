package com.abdelmajid.statussaver

import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.media.MediaMetadataRetriever
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.DocumentsContract
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream
import java.io.InputStream
import java.util.concurrent.Executors

/**
 * Storage Access Framework bridge (Android 11+), so the app only gets access
 * to the WhatsApp status folders the user picks instead of all files.
 *
 * Paths are expressed as ExternalStorageProvider document ids, e.g.
 * `primary:Android/media/com.whatsapp/WhatsApp/Media/.Statuses`.
 */
class MainActivity : FlutterActivity() {
    private val io = Executors.newFixedThreadPool(3)
    private val main = Handler(Looper.getMainLooper())
    private var pendingPick: Pair<String, MethodChannel.Result>? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler(::onCall)
    }

    private fun onCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "sdkInt" -> result.success(Build.VERSION.SDK_INT)
            "grantedTree" -> result.success(grantedTree(call.arg("docId"))?.toString())
            "pickTree" -> pickTree(call.arg("docId"), result)
            "list" -> background(result) {
                list(Uri.parse(call.arg("tree")), call.arg("docId"))
            }
            "copy" -> background(result) {
                copy(call.arg("source"), call.arg("dest"))
                true
            }
            "thumbnail" -> background(result) {
                thumbnail(
                    call.arg("source"),
                    call.arg("dest"),
                    call.argument<Int>("size") ?: 360,
                    call.argument<Boolean>("video") ?: false,
                )
            }
            else -> result.notImplemented()
        }
    }

    // ---- Access ------------------------------------------------------------

    /** A persisted tree permission that covers [docId], if any. */
    private fun grantedTree(docId: String): Uri? =
        contentResolver.persistedUriPermissions
            .filter { it.isReadPermission && it.uri.authority == AUTHORITY }
            .map { it.uri }
            .firstOrNull { covers(it, docId) }

    private fun covers(tree: Uri, docId: String): Boolean {
        val root = runCatching { DocumentsContract.getTreeDocumentId(tree) }.getOrNull()
            ?: return false
        val isChild = docId.startsWith(if (root.endsWith(":")) root else "$root/")
        return docId == root || isChild
    }

    private fun pickTree(docId: String, result: MethodChannel.Result) {
        pendingPick?.second?.success("cancelled")
        pendingPick = docId to result
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
            putExtra(
                DocumentsContract.EXTRA_INITIAL_URI,
                DocumentsContract.buildDocumentUri(AUTHORITY, docId),
            )
            addFlags(
                Intent.FLAG_GRANT_READ_URI_PERMISSION or
                    Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION,
            )
        }
        startActivityForResult(intent, PICK_REQUEST)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != PICK_REQUEST) return
        val (docId, result) = pendingPick ?: return
        pendingPick = null

        val tree = data?.data
        when {
            resultCode != RESULT_OK || tree == null -> result.success("cancelled")
            tree.authority != AUTHORITY || !covers(tree, docId) -> result.success("wrong")
            else -> {
                contentResolver.takePersistableUriPermission(
                    tree,
                    Intent.FLAG_GRANT_READ_URI_PERMISSION,
                )
                result.success("ok")
            }
        }
    }

    // ---- Files -------------------------------------------------------------

    /** Direct children of [docId] inside [tree]; empty if it doesn't exist. */
    private fun list(tree: Uri, docId: String): List<Map<String, Any?>> {
        val children = DocumentsContract.buildChildDocumentsUriUsingTree(tree, docId)
        val columns = arrayOf(
            DocumentsContract.Document.COLUMN_DOCUMENT_ID,
            DocumentsContract.Document.COLUMN_DISPLAY_NAME,
            DocumentsContract.Document.COLUMN_MIME_TYPE,
            DocumentsContract.Document.COLUMN_LAST_MODIFIED,
        )
        val out = mutableListOf<Map<String, Any?>>()
        runCatching {
            contentResolver.query(children, columns, null, null, null)?.use { c ->
                while (c.moveToNext()) {
                    val childId = c.getString(0)
                    out += mapOf(
                        "docId" to childId,
                        "uri" to DocumentsContract
                            .buildDocumentUriUsingTree(tree, childId).toString(),
                        "name" to c.getString(1),
                        "dir" to (c.getString(2) == DocumentsContract.Document.MIME_TYPE_DIR),
                        "modified" to c.getLong(3),
                    )
                }
            }
        }
        return out
    }

    private fun open(source: String): InputStream =
        if (source.startsWith("content://")) {
            contentResolver.openInputStream(Uri.parse(source))
                ?: error("Cannot open $source")
        } else {
            FileInputStream(source)
        }

    private fun copy(source: String, dest: String) {
        val target = File(dest)
        target.parentFile?.mkdirs()
        open(source).use { input -> target.outputStream().use { input.copyTo(it) } }
    }

    /** Writes a JPEG preview of at most [size]px to [dest]; false if none. */
    private fun thumbnail(source: String, dest: String, size: Int, video: Boolean): Boolean {
        val bitmap = (if (video) videoFrame(source, size) else imageSample(source, size))
            ?: return false
        File(dest).apply { parentFile?.mkdirs() }.outputStream().use {
            bitmap.compress(Bitmap.CompressFormat.JPEG, 80, it)
        }
        bitmap.recycle()
        return true
    }

    private fun videoFrame(source: String, size: Int): Bitmap? {
        val retriever = MediaMetadataRetriever()
        return try {
            if (source.startsWith("content://")) {
                retriever.setDataSource(this, Uri.parse(source))
            } else {
                retriever.setDataSource(source)
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
                retriever.getScaledFrameAtTime(
                    0, MediaMetadataRetriever.OPTION_CLOSEST_SYNC, size, size,
                )
            } else {
                retriever.frameAtTime
            }
        } catch (_: Exception) {
            null
        } finally {
            retriever.release()
        }
    }

    private fun imageSample(source: String, size: Int): Bitmap? = runCatching {
        val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
        open(source).use { BitmapFactory.decodeStream(it, null, bounds) }
        var sample = 1
        while (bounds.outWidth / (sample * 2) >= size && bounds.outHeight / (sample * 2) >= size) {
            sample *= 2
        }
        val options = BitmapFactory.Options().apply { inSampleSize = sample }
        open(source).use { BitmapFactory.decodeStream(it, null, options) }
    }.getOrNull()

    // ---- Helpers -----------------------------------------------------------

    private fun <T> background(result: MethodChannel.Result, task: () -> T) {
        io.execute {
            try {
                val value = task()
                main.post { result.success(value) }
            } catch (e: Exception) {
                main.post { result.error("io", e.message, null) }
            }
        }
    }

    private fun MethodCall.arg(name: String): String =
        argument<String>(name) ?: throw IllegalArgumentException("Missing $name")

    companion object {
        private const val CHANNEL = "status_saver/storage"
        private const val AUTHORITY = "com.android.externalstorage.documents"
        private const val PICK_REQUEST = 4711
    }
}
