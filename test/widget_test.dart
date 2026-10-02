import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp_status_saver/app.dart';
import 'package:whatsapp_status_saver/core/storage/prefs.dart';
import 'package:whatsapp_status_saver/features/permissions/permission_controller.dart';

class _DeniedPermission extends PermissionController {
  @override
  Future<bool> build() async => false;
}

void main() {
  testWidgets('shows permission request and switches tabs', (tester) async {
    SharedPreferences.setMockInitialValues({'locale': 'en'});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          prefsProvider.overrideWithValue(prefs),
          permissionProvider.overrideWith(_DeniedPermission.new),
        ],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Grant access'), findsWidgets);

    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();
    expect(find.text('Language'), findsOneWidget);
  });
}
