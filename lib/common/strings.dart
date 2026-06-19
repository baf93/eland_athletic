enum AppLanguage { it, en }

class ElandStrings {
  static AppLanguage currentLanguage = AppLanguage.en;
  static const AppLanguage _fallbackLanguage = AppLanguage.en;
  static const Map<AppLanguage, Map<String, String>> _localizedValues = {
    AppLanguage.en: {
      'app_name_user': 'Eland Athletic',
      'app_name_pro': 'Eland Pro',
      'app_motto': 'Stay Focused. Stay Fast. Stay ELAND.',
      'tab_focus': 'Focus',
      'tab_nutri': 'Nutrition',
      'tab_pt': 'Workout',
      'card_focus_title': 'Today Focus',
      'card_timer_title': 'Quick timers',
      'card_nutrition_title': 'Next Meal',
      'wip_function': 'Coming soon!'
    },

    AppLanguage.it: {
      'app_name_user': 'Eland Athletic',
      'app_name_pro': 'Eland Pro',
      'app_motto': 'Stay Focused. Stay Fast. Stay ELAND.',
      'tab_focus': 'Focus',
      'tab_nutri': 'Nutrizione',
      'tab_pt': 'Allenamento',
      'card_focus_title': 'Focus di Oggi',
      'card_timer_title': 'Timer rapidi',
      'card_nutrition_title': 'Prossimo Pasto',
      'wip_function': 'Funzionalità in arrivo!'
    },
  };

  static String of(String key) {
    final currentDict = _localizedValues[currentLanguage];
    if (currentDict != null && currentDict.containsKey(key)) {
      return currentDict[key]!;
    }

    final fallbackDict = _localizedValues[_fallbackLanguage];
    if (fallbackDict != null && fallbackDict.containsKey(key)) {
      return fallbackDict[key]!;
    }

    return key;
  }

  static void initLocale(String languageCode) {
    switch (languageCode) {
      case 'it':
        currentLanguage = AppLanguage.it;
        break;
      default:
        currentLanguage = AppLanguage.en;
        break;
    }
  }
}