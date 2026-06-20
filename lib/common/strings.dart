enum AppLanguage { it, en }

class ElandStrings {
  static AppLanguage currentLanguage = AppLanguage.en;
  static const AppLanguage _fallbackLanguage = AppLanguage.en;
  static const Map<AppLanguage, Map<String, String>> _localizedValues = {
    AppLanguage.en: {
      'app_name_user': 'Eland Athletic',
      'app_name_pro': 'Eland Pro',
      'app_motto': 'Stay Focused. Stay Fast. Stay ELAND.',

      //Home
      'tab_focus': 'Focus',
      'tab_nutri': 'Nutrition',
      'tab_pt': 'Workout',
      'card_focus_title': 'Today Focus',
      'card_timer_title': 'Quick timers',
      'card_nutrition_title': 'Next Meal',

      //Timer List
      'timer_list_desc': 'Pick your protocol, set the clock, and push your limits. Tabata, EMOM, AMRAP or For Time: everything you need to dominate!',

      //Settings page
      'setting_title': 'Settings',
      'interface_section': 'Interface and language',
      'setting_lang_title': 'Language',
      'setting_lang_subtitle': 'Choose the application language',
      'setting_prep_title': 'Preparation Time',
      'setting_prep_subtitle': 'Set the preparation time for your workouts',
      'setting_theme_title': 'Theme',
      'setting_theme_subtitle': 'Choose the application theme',
      'setting_metric_title': 'Metric System',
      'setting_metric_subtitle': 'Choose the metric system for your workouts',
      'section_alerts_notifications': 'Alerts and Notifications',
      'setting_alerts_title': 'Alerts',
      'setting_alerts_subtitle': 'Enable or disable alerts for your workouts',
      'setting_sound_title': 'Sound',
      'setting_sound_subtitle': 'Enable or disable sound for your workouts',
      'setting_haptic_title': 'Haptic Feedback',
      'setting_haptic_subtitle': 'Enable or disable haptic feedback for your workouts',
      'setting_notifications_title': 'Notifications',
      'setting_notifications_subtitle': 'Enable or disable notifications for your workouts',
      'setting_screen_title': 'Keep Screen On',
      'setting_screen_subtitle': 'Keep the screen on during your workouts',
      'action_permissions_title': 'Permissions',
      'action_permissions_subtitle': 'Manage the permissions of the App',
      'brand_motto': 'No distractions. No excuses. Just you and your next set.',
      'info_card_title': 'ⓘ Why ELAND?',
      'info_card_description': 'The Eland is the world\'s largest antelope, capable of incredible endurance and explosive power. I chose this name because ELAND is built for those who don\'t need to be loud to be strong: it\'s a minimal, robust tool designed to let you focus solely on your stamina and your goals.',
      'philosophy_title': 'ELAND Philosophy',
      'philosophy_description': 'ELAND is built for efficiency. I embrace the KISS (Keep It Simple, Stupid) principle: no clutter, just the tools you need to train. Your data stays yours: the app is Privacy-oriented by design, with zero external server reliance and the transparency of Open Source code. No accounts, no tracking, just performance.',
      'credits_developed_by': 'Developed by',
      'action_source_code': 'Source Code',
      'action_source_code_sub': 'Check out the source code on GitHub',
      'action_license': 'License',
      'action_license_sub': 'View the license of the application',
      'section_assets_resources': 'Asset and Resources',
      'action_tts_voice': 'Eland Voice',
      'button_third_party_licenses': 'Third Party Licenses',

      //Timer Name
      'timer_tabata': 'Tabata',
      'timer_emom': 'Emom',
      'timer_amrap': 'Amrap',
      'timer_fortime': 'For Time',
      'timer_countdown': 'Countdown',
      'timer_stopwatch': 'Stopwatch',

      //Timer Settings
      'total_min': 'Total Minutes',

      //Utils
      'start_btn': 'Start',
      'save_btn': 'Save',
      'wip_function': 'Coming soon!'
    },

    AppLanguage.it: {
      'app_name_user': 'Eland Athletic',
      'app_name_pro': 'Eland Pro',
      'app_motto': 'Stay Focused. Stay Fast. Stay ELAND.',

      //Home
      'tab_focus': 'Focus',
      'tab_nutri': 'Nutrizione',
      'tab_pt': 'Allenamento',
      'card_focus_title': 'Focus di Oggi',
      'card_timer_title': 'Timer rapidi',
      'card_nutrition_title': 'Prossimo Pasto',

      //Timer List
      'timer_list_desc': 'Scegli il tuo protocollo, imposta il tempo e sfida i tuoi limiti. Tabata, EMOM, AMRAP o For Time: l\'essenziale per spingere al massimo!',

      //Setting page
      'setting_title': 'Impostazioni',
      'interface_section': 'Interfaccia e lingua',
      'setting_lang_title': 'Lingua',
      'setting_lang_subtitle': 'Scegli la lingua dell\'applicazione',
      'setting_prep_title': 'Tempo di Preparazione',
      'setting_prep_subtitle': 'Imposta il tempo di preparazione per i tuoi allenamenti',
      'setting_theme_title': 'Tema',
      'setting_theme_subtitle': 'Scegli il tema dell\'applicazione',
      'setting_metric_title': 'Sistema Metrico',
      'setting_metric_subtitle': 'Scegli il sistema metrico per i tuoi allenamenti',
      'section_alerts_notifications': 'Avvisi e Notifiche',
      'setting_alerts_title': 'Avvisi',
      'setting_alerts_subtitle': 'Abilita o disabilita gli avvisi per i tuoi allenamenti',
      'setting_sound_title': 'Suono',
      'setting_sound_subtitle': 'Abilita o disabilita il suono per i tuoi allenamenti',
      'setting_haptic_title': 'Feedback Aptico',
      'setting_haptic_subtitle': 'Abilita o disabilita il feedback aptico per i tuoi allenamenti',
      'setting_notifications_title': 'Notifiche',
      'setting_notifications_subtitle': 'Abilita o disabilita le notifiche per i tuoi allenamenti',
      'setting_screen_title': 'Mantieni lo Schermo Acceso',
      'setting_screen_subtitle': 'Mantieni lo schermo acceso durante i tuoi allenamenti',
      'action_permissions_title': 'Permessi',
      'action_permissions_subtitle': 'Gestisci i permessi dell\'applicazione',
      'brand_motto': 'Nessuna distrazione. Nessuna scusa. Solo tu e il tuo prossimo set.',
      'info_card_title': 'ⓘ Perchè ELAND?',
      'info_card_description': 'L\'eland è il più grande antilope al mondo, capace di incredibile resistenza e potenza esplosiva. Ho scelto questo nome perché ELAND è costruita per chi non ha bisogno di essere rumoroso per essere forte: è uno strumento minimale e robusto pensato per farti concentrare esclusivamente sulla tua resistenza e sui tuoi obiettivi.',
      'philosophy_title': 'Filosofia ELAND',
      'philosophy_description': 'ELAND è costruita sull\'efficienza. Seguo la filosofia KISS (Keep It Simple, Stupid): nessuna funzione inutile, solo ciò che serve per allenarti. I tuoi dati restano tuoi: l\'app è Privacy-oriented per design, non salva nulla su server esterni e sfrutta la trasparenza dell\'Open Source. Nessun account, nessun tracciamento, solo performance.',
      'credits_developed_by': 'Sviluppato da',
      'action_source_code': 'Codice sorgente',
      'action_source_code_sub': 'Guarda il codice sorgente su GitHub',
      'action_license': 'Licenza',
      'action_license_sub': 'Visualizza la licenza dell\'applicazione',
      'section_assets_resources': 'Asset e Risorse',
      'action_tts_voice': 'Voce di Eland',
      'button_third_party_licenses': 'Licenze di Terze Parti',

      //Timer Name
      'timer_tabata': 'Tabata',
      'timer_emom': 'Emom',
      'timer_amrap': 'Amrap',
      'timer_fortime': 'For Time',
      'timer_countdown': 'Conto alla rovescia',
      'timer_stopwatch': 'Cronometro',

      //Timer Settings
      'total_min': 'Minuti Totali',

      //Utils
      'start_btn': 'Inizia',
      'save_btn': 'Salva',
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