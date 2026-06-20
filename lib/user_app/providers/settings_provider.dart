import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class SettingsState {
  final String language;
  final int preparationTime;
  final bool isDarkMode;
  final bool useMetricUnits;
  final bool soundEnabled;
  final bool hapticFeedback;
  final bool notifications;
  final bool keepScreenOn;
  final String appVersion;

  SettingsState({
    required this.language,
    required this.preparationTime,
    required this.isDarkMode,
    required this.useMetricUnits,
    required this.soundEnabled,
    required this.hapticFeedback,
    required this.notifications,
    required this.keepScreenOn,
    required this.appVersion,
  });

  SettingsState copyWith({
    String? language,
    int? preparationTime,
    bool? isDarkMode,
    bool? useMetricUnits,
    bool? soundEnabled,
    bool? hapticFeedback,
    bool? notifications,
    bool? keepScreenOn,
    String? appVersion,
  }) {
    return SettingsState(
      language: language ?? this.language,
      preparationTime: preparationTime ?? this.preparationTime,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      useMetricUnits: useMetricUnits ?? this.useMetricUnits,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      notifications: notifications ?? this.notifications,
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
      appVersion: appVersion ?? this.appVersion,
    );
  }
}


final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Shared Preferences Provider shall be overwritten in Main()');
});

// Notifier for Riverpod
class SettingsNotifier extends Notifier<SettingsState> {
  late SharedPreferences _prefs;

  @override
  SettingsState build() {
    // Get Main injected instances of sharedPreferences
    _prefs = ref.watch(sharedPreferencesProvider);


    _loadAppVersion();

    return SettingsState(
      language: _prefs.getString('language') ?? 'en',
      preparationTime: _prefs.getInt('preparationTime') ?? 10,
      isDarkMode: _prefs.getBool('isDarkMode') ?? true,
      useMetricUnits: _prefs.getBool('useMetricUnits') ?? true,
      soundEnabled: _prefs.getBool('soundEnabled') ?? true,
      hapticFeedback: _prefs.getBool('hapticFeedback') ?? true,
      notifications: _prefs.getBool('notifications') ?? false,
      keepScreenOn: _prefs.getBool('keepScreenOn') ?? true,
      appVersion: '...'
    );
  }

  //Dynamic loading of app version from pubspec
  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final versionString = "${packageInfo.version}+${packageInfo.buildNumber}";

      state = state.copyWith(appVersion: versionString);
    } catch (_) {
      state = state.copyWith(appVersion: 'N/A');
    }
  }

  // Methods for updating the settings
  void updateLanguage(String value) {
    _prefs.setString('language', value);
    state = state.copyWith(language: value);
  }

  void updatePreparationTime(int value) {
    _prefs.setInt('preparationTime', value);
    state = state.copyWith(preparationTime: value);
  }

  void toggleDarkMode(bool value) {
    _prefs.setBool('isDarkMode', value);
    state = state.copyWith(isDarkMode: value);
  }

  void toggleMetricUnits(bool value) {
    _prefs.setBool('useMetricUnits', value);
    state = state.copyWith(useMetricUnits: value);
  }

  void toggleSound(bool value) {
    _prefs.setBool('soundEnabled', value);
    state = state.copyWith(soundEnabled: value);
  }

  void toggleHaptic(bool value) {
    _prefs.setBool('hapticFeedback', value);
    state = state.copyWith(hapticFeedback: value);
  }

// Just In Time Permissions Handling for Notifications Toggle
  Future<void> toggleNotifications(bool value) async {
    if (!value) {
      await _prefs.setBool('notifications', false);
      state = state.copyWith(notifications: false);
      return;
    }

    final status = await Permission.notification.status;

    if (status.isGranted) {
      await _prefs.setBool('notifications', true);
      state = state.copyWith(notifications: true);
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
    } else {
      final result = await Permission.notification.request();

      if (result.isGranted) {
        await _prefs.setBool('notifications', true);
        state = state.copyWith(notifications: true);
      } else {
        await _prefs.setBool('notifications', false);
        state = state.copyWith(notifications: false);
      }
    }
  }

  void toggleKeepScreenOn(bool value) {
    _prefs.setBool('keepScreenOn', value);
    state = state.copyWith(keepScreenOn: value);
  }
}

// Global settings provider
final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(() {
  return SettingsNotifier();
});