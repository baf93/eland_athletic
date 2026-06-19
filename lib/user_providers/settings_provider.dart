import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Modello dati per raggruppare le impostazioni
class SettingsState {
  final String language;
  final int preparationTime;
  final bool isDarkMode;
  final bool useMetricUnits;
  final bool soundEnabled;
  final bool hapticFeedback;
  final bool silentNotifications;
  final bool keepScreenOn;

  SettingsState({
    required this.language,
    required this.preparationTime,
    required this.isDarkMode,
    required this.useMetricUnits,
    required this.soundEnabled,
    required this.hapticFeedback,
    required this.silentNotifications,
    required this.keepScreenOn,
  });

  SettingsState copyWith({
    String? language,
    int? preparationTime,
    bool? isDarkMode,
    bool? useMetricUnits,
    bool? soundEnabled,
    bool? hapticFeedback,
    bool? silentNotifications,
    bool? keepScreenOn,
  }) {
    return SettingsState(
      language: language ?? this.language,
      preparationTime: preparationTime ?? this.preparationTime,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      useMetricUnits: useMetricUnits ?? this.useMetricUnits,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      silentNotifications: silentNotifications ?? this.silentNotifications,
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
    );
  }
}

// 1. IL tassello mancante: Dichiarazione del provider per SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Questo provider deve essere sovrascritto nel main');
});

// 2. Notifier moderno per Riverpod 2.x legato al provider
class SettingsNotifier extends Notifier<SettingsState> {
  late SharedPreferences _prefs;

  @override
  SettingsState build() {
    // Recupera in modo sicuro l'istanza iniettata nel main
    _prefs = ref.watch(sharedPreferencesProvider);

    return SettingsState(
      language: _prefs.getString('language') ?? 'IT',
      preparationTime: _prefs.getInt('preparationTime') ?? 10,
      isDarkMode: _prefs.getBool('isDarkMode') ?? true,
      useMetricUnits: _prefs.getBool('useMetricUnits') ?? true,
      soundEnabled: _prefs.getBool('soundEnabled') ?? true,
      hapticFeedback: _prefs.getBool('hapticFeedback') ?? false,
      silentNotifications: _prefs.getBool('silentNotifications') ?? false,
      keepScreenOn: _prefs.getBool('keepScreenOn') ?? true,
    );
  }

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

  void toggleSilentNotifications(bool value) {
    _prefs.setBool('silentNotifications', value);
    state = state.copyWith(silentNotifications: value);
  }

  void toggleKeepScreenOn(bool value) {
    _prefs.setBool('keepScreenOn', value);
    state = state.copyWith(keepScreenOn: value);
  }
}

// 3. Definizione del Provider Globale delle impostazioni
final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(() {
  return SettingsNotifier();
});