import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../common/eland_responsive.dart';
import '../common/strings.dart';
import 'providers/settings_provider.dart';
import 'workouts/backup_actions.dart';
import '../common/widgets/settings_widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import '../common/theme.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final r = ElandResponsive(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.maybePop(context);
          },
        ),
        title: Text(
          ElandStrings.of('setting_title').toUpperCase(),
          style: TextStyle(
            fontSize: r.font(18),
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: r.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SettingsSectionTitle(
                title: ElandStrings.of('interface_section').toUpperCase(),
              ),

              SettingsDropdownTile<String>(
                icon: Icons.language_rounded,
                title: ElandStrings.of('setting_lang_title'),
                subtitle: ElandStrings.of('setting_lang_subtitle'),
                value: settings.language,
                items: const ['it', 'en'],
                onChanged: (val) {
                  HapticFeedback.lightImpact();
                  settingsNotifier.updateLanguage(val!);
                },
              ),

              SettingsDropdownTile<int>(
                icon: Icons.timer_outlined,
                title: ElandStrings.of('setting_prep_title'),
                subtitle: ElandStrings.of('setting_prep_subtitle'),
                value: settings.preparationTime,
                items: const [0, 5, 10, 15, 30, 45, 60],
                onChanged: (val) {
                  HapticFeedback.lightImpact();
                  settingsNotifier.updatePreparationTime(val!);
                },
              ),

              SettingsSwitchTile(
                icon: Icons.fitness_center_rounded,
                title: ElandStrings.of('setting_metric_title'),
                subtitle: ElandStrings.of('setting_metric_subtitle'),
                value: settings.useMetricUnits,
                onChanged: (val) {
                  HapticFeedback.lightImpact();
                  settingsNotifier.toggleMetricUnits(val);
                },
              ),

              SizedBox(height: r.sectionGap),

              SettingsSectionTitle(
                title: ElandStrings.of('mood_selection').toUpperCase(),
              ),

              SettingsSwitchTile(
                icon: Icons.dark_mode_rounded,
                title: ElandStrings.of('setting_theme_title'),
                subtitle: ElandStrings.of('setting_theme_subtitle'),
                value: settings.isDarkMode,
                onChanged: (val) {
                  HapticFeedback.lightImpact();
                  settingsNotifier.toggleDarkMode(val);
                },
              ),

              SettingsColorSelector(
                icon: Icons.palette_rounded,
                title: ElandStrings.of('setting_color_title'),
                colors: ElandColors.customPalette,
                selectedIndex: settings.primaryColorIndex,
                onColorSelected: (index) {
                  HapticFeedback.lightImpact();
                  settingsNotifier.updatePrimaryColor(index);
                },
              ),

              SizedBox(height: r.sectionGap),

              SettingsSectionTitle(
                title: ElandStrings.of('section_alerts_notifications')
                    .toUpperCase(),
              ),

              SettingsSwitchTile(
                icon: Icons.volume_up_rounded,
                title: ElandStrings.of('setting_sound_title'),
                subtitle: ElandStrings.of('setting_sound_subtitle'),
                value: settings.soundEnabled,
                onChanged: (val) {
                  HapticFeedback.lightImpact();
                  settingsNotifier.toggleSound(val);
                },
              ),

              SettingsSwitchTile(
                icon: Icons.vibration_rounded,
                title: ElandStrings.of('setting_haptic_title'),
                subtitle: ElandStrings.of('setting_haptic_subtitle'),
                value: settings.hapticFeedback,
                onChanged: (val) {
                  HapticFeedback.lightImpact();
                  settingsNotifier.toggleHaptic(val);
                },
              ),

              SettingsSwitchTile(
                icon: Icons.phone_android_rounded,
                title: ElandStrings.of('setting_screen_title'),
                subtitle: ElandStrings.of('setting_screen_subtitle'),
                value: settings.keepScreenOn,
                onChanged: (val) {
                  HapticFeedback.lightImpact();
                  settingsNotifier.toggleKeepScreenOn(val);
                },
              ),

              SizedBox(height: r.compactGap),

              SettingsActionTile(
                icon: Icons.verified_user_rounded,
                title: ElandStrings.of('action_permissions_title'),
                subtitle: ElandStrings.of('action_permissions_subtitle'),
                trailing: Icon(
                  Icons.open_in_new_rounded,
                  size: r.icon(18),
                ),
                onTap: () async {
                  HapticFeedback.lightImpact();
                  await openAppSettings();
                },
              ),

              SizedBox(height: r.sectionGap),

              SettingsSectionTitle(
                title: ElandStrings.of('backup_section').toUpperCase(),
              ),

              SettingsActionTile(
                icon: Icons.upload_file_rounded,
                title: ElandStrings.of('export_data'),
                subtitle: ElandStrings.of('export_data_sub'),
                onTap: () {
                  HapticFeedback.lightImpact();
                  BackupActions.export(context, ref);
                },
              ),

              SettingsActionTile(
                icon: Icons.download_rounded,
                title: ElandStrings.of('import_data'),
                subtitle: ElandStrings.of('import_data_sub'),
                onTap: () {
                  HapticFeedback.lightImpact();
                  BackupActions.import(context, ref);
                },
              ),

              SettingsActionTile(
                icon: Icons.cloud_done_rounded,
                title: ElandStrings.of('auto_backup_title'),
                subtitle: ElandStrings.of('auto_backup_sub'),
                trailing: const SizedBox.shrink(),
                onTap: () {},
              ),

              Divider(
                height: r.spacing(48),
                thickness: 1,
                indent: r.spacing(40),
                endIndent: r.spacing(40),
                color: primaryColor.withAlpha(90),
              ),

              SizedBox(height: r.compactGap),

              Center(
                child: Column(
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'ELAND',
                        style: TextStyle(
                          fontSize: r.font(40, maxScale: 1.08),
                          fontWeight: FontWeight.w900,
                          letterSpacing: 8.0,
                          color: theme.textTheme.headlineLarge?.color,
                        ),
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'ATHLETIC',
                        style: TextStyle(
                          fontSize: r.font(18, maxScale: 1.08),
                          fontWeight: FontWeight.w800,
                          letterSpacing: 4.0,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    SizedBox(height: r.spacing(4)),
                    Text(
                      settings.appVersion,
                      style: TextStyle(
                        fontSize: r.font(12),
                        fontWeight: FontWeight.w700,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                    SizedBox(height: r.spacing(20)),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: r.spacing(2),
                      ),
                      child: Text(
                        ElandStrings.of('brand_motto'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: r.font(15),
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: r.spacing(32)),

              SettingsInfoCard(
                title: ElandStrings.of('info_card_title').toUpperCase(),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ElandStrings.of('info_card_description'),
                      style: TextStyle(
                        fontSize: r.font(14),
                        height: 1.45,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                    SizedBox(height: r.spacing(20)),
                    Text(
                      ElandStrings.of('philosophy_title').toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: r.font(14),
                        color: theme.colorScheme.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: r.spacing(12)),
                    Text(
                      ElandStrings.of('philosophy_description'),
                      style: TextStyle(
                        fontSize: r.font(14),
                        height: 1.45,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: r.spacing(40)),

              Center(
                child: Column(
                  children: [
                    Text(
                      ElandStrings.of('credits_developed_by').toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: r.font(16),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                    SizedBox(height: r.spacing(8)),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'BAF93',
                        style: TextStyle(
                          fontSize: r.font(38, maxScale: 1.08),
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          color: theme.textTheme.headlineLarge?.color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Divider(
                height: r.spacing(48),
                thickness: 1,
                indent: r.spacing(40),
                endIndent: r.spacing(40),
                color: primaryColor.withAlpha(90),
              ),

              SizedBox(height: r.compactGap),

              SettingsActionTile(
                icon: Icons.code_rounded,
                title: ElandStrings.of('action_source_code'),
                subtitle: ElandStrings.of('action_source_code_sub'),
                onTap: () async {
                  HapticFeedback.lightImpact();
                  final Uri url = Uri.parse(
                    'https://github.com/baf93/eland_athletic',
                  );

                  await launchUrl(
                    url,
                    mode: LaunchMode.inAppBrowserView,
                  );
                },
              ),

              SettingsActionTile(
                icon: Icons.gavel_rounded,
                title: ElandStrings.of('action_license'),
                subtitle: ElandStrings.of('action_license_sub'),
                onTap: () async {
                  HapticFeedback.lightImpact();
                  final Uri url = Uri.parse(
                    'https://creativecommons.org/licenses/by-nc/4.0/',
                  );

                  await launchUrl(
                    url,
                    mode: LaunchMode.inAppBrowserView,
                  );
                },
              ),

              SizedBox(height: r.sectionGap),

              SettingsSectionTitle(
                title: ElandStrings.of('section_assets_resources')
                    .toUpperCase(),
              ),

              SettingsActionTile(
                icon: Icons.link_rounded,
                title: ElandStrings.of('action_tts_voice'),
                subtitle: '',
                onTap: () async {
                  HapticFeedback.lightImpact();
                  final Uri url = Uri.parse('https://ttsmp3.com/');

                  await launchUrl(
                    url,
                    mode: LaunchMode.inAppBrowserView,
                  );
                },
              ),

              SizedBox(height: r.sectionGap),

              Center(
                child: TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    showLicensePage(
                      context: context,
                      applicationName: ElandStrings.of('app_name_user'),
                      applicationVersion: settings.appVersion,
                      applicationLegalese: '© 2026 BAF93',
                    );
                  },
                  child: Text(
                    ElandStrings.of('button_third_party_licenses')
                        .toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: r.font(11),
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),

              SizedBox(height: r.sectionGap),
            ],
          ),
        ),
      ),
    );
  }
}