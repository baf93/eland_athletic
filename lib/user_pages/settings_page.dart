import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../common/strings.dart';
import '../user_providers/settings_provider.dart';
import '../common/widgets/settings_widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    //Initialize the RiverPod settings provider
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      //App Bar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          ElandStrings.of('setting_title').toUpperCase(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5),
        ),
        centerTitle: true,
      ),

      // Content
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // --- SECTION: INTERFACE AND LANGUAGE
              SettingsSectionTitle(title: ElandStrings.of('interface_section').toUpperCase()),

              SettingsDropdownTile<String>(
                icon: Icons.language_rounded,
                title: ElandStrings.of('setting_lang_title'),
                subtitle: ElandStrings.of('setting_lang_subtitle'),
                value: settings.language,
                items: const ['it', 'en'],
                onChanged: (val) => settingsNotifier.updateLanguage(val!),
              ),

              SettingsDropdownTile<int>(
                icon: Icons.timer_outlined,
                title: ElandStrings.of('setting_prep_title'),
                subtitle: ElandStrings.of('setting_prep_subtitle'),
                value: settings.preparationTime,
                items: const [5, 10, 15, 20],
                onChanged: (val) => settingsNotifier.updatePreparationTime(val!),
              ),

              SettingsSwitchTile(
                icon: Icons.dark_mode_rounded,
                title: ElandStrings.of('setting_theme_title'),
                subtitle: ElandStrings.of('setting_theme_subtitle'),
                value: settings.isDarkMode,
                onChanged: settingsNotifier.toggleDarkMode,
              ),

              SettingsSwitchTile(
                icon: Icons.fitness_center_rounded,
                title: ElandStrings.of('setting_metric_title'),
                subtitle: ElandStrings.of('setting_metric_subtitle'),
                value: settings.useMetricUnits,
                onChanged: settingsNotifier.toggleMetricUnits,
              ),

              const SizedBox(height: 24),

              // --- SECTION: ALERTS AND NOTIFICATIONS ---
              SettingsSectionTitle(title: ElandStrings.of('section_alerts_notifications').toUpperCase()),

              SettingsSwitchTile(
                icon: Icons.volume_up_rounded,
                title: ElandStrings.of('setting_sound_title'),
                subtitle: ElandStrings.of('setting_sound_subtitle'),
                value: settings.soundEnabled,
                onChanged: settingsNotifier.toggleSound,
              ),

              SettingsSwitchTile(
                icon: Icons.vibration_rounded,
                title: ElandStrings.of('setting_haptic_title'),
                subtitle: ElandStrings.of('setting_haptic_subtitle'),
                value: settings.hapticFeedback,
                onChanged: settingsNotifier.toggleHaptic,
              ),

              SettingsSwitchTile(
                icon: Icons.notifications_off_rounded,
                title: ElandStrings.of('setting_notifications_title'),
                subtitle: ElandStrings.of('setting_notifications_subtitle'),
                value: settings.notifications,
                onChanged: (bool value) {
                  settingsNotifier.toggleNotifications(value);
                }
              ),

              SettingsSwitchTile(
                icon: Icons.phone_android_rounded,
                title: ElandStrings.of('setting_screen_title'),
                subtitle: ElandStrings.of('setting_screen_subtitle'),
                value: settings.keepScreenOn,
                onChanged: settingsNotifier.toggleKeepScreenOn,
              ),

              const SizedBox(height: 16),

              SettingsActionTile(
                icon: Icons.verified_user_rounded,
                title: ElandStrings.of('action_permissions_title'),
                subtitle: ElandStrings.of('action_permissions_subtitle'),
                trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                onTap: () async {
                  await openAppSettings();
                },
              ),

              Divider(
                height: 48,
                thickness: 1,
                indent: 40,
                endIndent: 40,
                color: primaryColor.withAlpha(90),
              ),

              const SizedBox(height: 16),

              // --- BRAND INFO
              Center(
                child: Column(
                  children: [
                    Text(
                      'ELAND',
                      style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: 8.0, color: theme.textTheme.headlineLarge?.color),
                    ),
                    Text(
                      'ATHLETIC',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 4.0, color: primaryColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      settings.appVersion,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: theme.textTheme.bodyMedium?.color),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: Text(
                        ElandStrings.of('brand_motto'),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, fontStyle: FontStyle.italic, color: theme.textTheme.bodyMedium?.color),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // --- CARD: PERCHÉ ELAND ---
              SettingsInfoCard(
                title: ElandStrings.of('info_card_title').toUpperCase(), // Es: "ⓘ PERCHÉ ELAND?"
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ElandStrings.of('info_card_description'),
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.45,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      ElandStrings.of('philosophy_title').toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: theme.colorScheme.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      ElandStrings.of('philosophy_description'),
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.45,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // --- BOTTOM CREDITS ---
              Center(
                child: Column(
                  children: [
                    Text(
                      ElandStrings.of('credits_developed_by').toUpperCase(),
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: theme.textTheme.bodyMedium?.color),
                    ),
                    const SizedBox(height: 8),
                    Text('BAF93', style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900, letterSpacing: 2.0, color: theme.textTheme.headlineLarge?.color)),

                  ],
                ),
              ),

              Divider(
                height: 48,
                thickness: 1,
                indent: 40,
                endIndent: 40,
                color: primaryColor.withAlpha(90),
              ),

              const SizedBox(height: 16),

              SettingsActionTile(
                icon: Icons.code_rounded,
                title: ElandStrings.of('action_source_code'),
                subtitle: ElandStrings.of('action_source_code_sub'), //https://github.com/baf93/eland_athletic
                onTap: () async {
                  final Uri url = Uri.parse('https://github.com/baf93/eland_athletic');

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
                  final Uri url = Uri.parse('https://creativecommons.org/licenses/by-nc/4.0/');

                  await launchUrl(
                    url,
                    mode: LaunchMode.inAppBrowserView,
                  );
                },
              ),

              const SizedBox(height: 24),
              SettingsSectionTitle(title: ElandStrings.of('section_assets_resources').toUpperCase()),

              SettingsActionTile(
                icon: Icons.link_rounded,
                title: ElandStrings.of('action_tts_voice'),
                subtitle: '',
                onTap: () async {
                  final Uri url = Uri.parse('https://ttsmp3.com/');

                  await launchUrl(
                    url,
                    mode: LaunchMode.inAppBrowserView,
                  );
                },
              ),

              const SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: () {
                    showLicensePage(
                      context: context,
                      applicationName: ElandStrings.of('app_name_user'),
                      applicationVersion: settings.appVersion,
                      applicationLegalese: '© 2026 BAF93',
                    );
                  },
                  child: Text(
                    ElandStrings.of('button_third_party_licenses').toUpperCase(),
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: primaryColor, letterSpacing: 1.0),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}