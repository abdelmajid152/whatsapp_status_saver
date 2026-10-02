import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/app_info.dart';
import '../../core/l10n/strings.dart';
import '../../core/widgets/app_icons.dart';
import '../media/data/media_repository.dart';

typedef _Section = ({String title, String body});

const _updated = {
  'ar': 'آخر تحديث: 2 أكتوبر 2026',
  'en': 'Last updated: October 2, 2026',
};

const _ar = <_Section>[
  (
    title: 'مقدمة',
    body: 'يحترم تطبيق "حافظ الحالات" خصوصيتك. توضح هذه السياسة ما يصل إليه التطبيق وكيف يستخدمه. التطبيق غير تابع لواتساب أو لشركة Meta.',
  ),
  (
    title: 'البيانات التي نصل إليها',
    body: 'يقرأ التطبيق ملفات الحالات (صور وفيديو) المخزّنة على جهازك داخل مجلدات واتساب وواتساب الأعمال، وذلك فقط لعرضها لك داخل التطبيق.',
  ),
  (
    title: 'البيانات التي لا نجمعها',
    body: 'لا نجمع أي بيانات شخصية، ولا نرفع أي ملف إلى الإنترنت، ولا نستخدم أدوات تتبع أو تحليلات أو إعلانات. كل شيء يبقى على جهازك.',
  ),
  (
    title: 'الحفظ والمشاركة',
    body: 'عند الضغط على "حفظ" تُنسخ الحالة إلى مجلد {dir} على جهازك. وعند المشاركة يُرسل الملف إلى التطبيق الذي تختاره أنت عبر قائمة المشاركة في النظام.',
  ),
  (
    title: 'الأذونات',
    body: 'يطلب التطبيق إذن الوصول إلى الملفات لقراءة الحالات وحفظها فقط. يمكنك سحب الإذن في أي وقت من إعدادات الهاتف.',
  ),
  (
    title: 'خصوصية الآخرين',
    body: 'الحالات ملك لأصحابها. يُرجى عدم إعادة نشرها أو مشاركتها دون إذنهم.',
  ),
  (
    title: 'الأطفال',
    body: 'التطبيق غير موجّه للأطفال دون 13 عاماً، ولا نجمع أي بيانات منهم.',
  ),
  (
    title: 'التغييرات على هذه السياسة',
    body: 'قد نحدّث هذه السياسة عند إضافة ميزات جديدة، وسيظهر تاريخ آخر تحديث أعلى الصفحة.',
  ),
  (title: 'تواصل معنا', body: 'لأي سؤال عن الخصوصية راسلنا على: {email}'),
];

const _en = <_Section>[
  (
    title: 'Introduction',
    body: 'Status Saver respects your privacy. This policy explains what the app accesses and how it is used. The app is not affiliated with WhatsApp or Meta.',
  ),
  (
    title: 'What we access',
    body: 'The app reads status files (photos and videos) stored on your device in the WhatsApp and WhatsApp Business folders, only to show them to you inside the app.',
  ),
  (
    title: 'What we don’t collect',
    body: 'We collect no personal data, upload no files, and use no tracking, analytics or ads. Everything stays on your device.',
  ),
  (
    title: 'Saving and sharing',
    body: 'Tapping "Save" copies the status to {dir} on your device. Sharing sends the file only to the app you pick in the system share sheet.',
  ),
  (
    title: 'Permissions',
    body: 'Storage access is used only to read and save statuses. You can revoke it at any time in your phone settings.',
  ),
  (
    title: 'Other people’s privacy',
    body: 'Statuses belong to the people who posted them. Please don’t repost or share them without permission.',
  ),
  (
    title: 'Children',
    body: 'The app is not directed at children under 13, and we collect no data from them.',
  ),
  (
    title: 'Changes to this policy',
    body: 'We may update this policy when features change; the date at the top shows the latest version.',
  ),
  (title: 'Contact us', body: 'For any privacy question, email us at: {email}'),
];

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  static Future<void> open(BuildContext context) => Navigator.of(context)
      .push(MaterialPageRoute<void>(builder: (_) => const PrivacyPolicyPage()));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = Localizations.localeOf(context).languageCode == 'ar'
        ? 'ar'
        : 'en';
    final sections = lang == 'ar' ? _ar : _en;
    // LTR isolates keep the path/email readable inside Arabic text.
    String fill(String s) => s
        .replaceAll('{dir}', '\u2066${MediaRepository.savedDir}\u2069')
        .replaceAll('{email}', '\u2066${AppInfo.supportEmail}\u2069');

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: HugeIcon(
            icon: AppIcons.back(context),
            color: theme.colorScheme.onSurface,
          ),
        ),
        title: Text(context.tr(Tr.privacyPolicy)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        children: [
          Text(
            _updated[lang]!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          for (final s in sections) ...[
            const SizedBox(height: 22),
            Text(
              s.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              fill(s.body),
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.7),
            ),
          ],
        ],
      ),
    );
  }
}
