import 'dart:ui';
import 'package:flutter/material.dart';
import 'common/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_pages/focus_page.dart';
import 'user_pages/nutri_page.dart';
import 'user_pages/pt_page.dart';
import 'common/strings.dart';
import 'user_providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();

  final String savedLanguage = sharedPrefs.getString('language') ?? PlatformDispatcher.instance.locale.languageCode;
  ElandStrings.initLocale(savedLanguage);
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPrefs),
      ],
      child: const ElandUserApp(),
    ),
  );
}

class ElandUserApp extends ConsumerWidget {
  const ElandUserApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    final settings = ref.watch(settingsProvider);

    ElandStrings.initLocale(settings.language);
    
    return MaterialApp(
      title: ElandStrings.of('app_name_user'),

      // Theme Injection
      theme: ElandTheme.lightTheme,
      darkTheme: ElandTheme.darkTheme,
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,

      home: UserDashboard(key: ValueKey(settings.language)),
    );
  }
}

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    FocusPage(),
    NutriPage(),
    PtPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final elandColors = Theme.of(context).extension<ElandCustomColors>()!;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: elandColors.cardBorder!,
              width: 1,
            ),
          ),
        ),
        // Remove the splashing effect
        child: Theme(
          data: Theme.of(context).copyWith(
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },

          // Configuration of the Bar
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: elandColors.unselectedItems,
          selectedFontSize: 14,
          unselectedFontSize: 11,
          iconSize: 24,
          elevation: 0,

          // Set icons and pages
          items: [
            BottomNavigationBarItem(
              icon: const Padding(
                padding: EdgeInsets.only(top: 4, bottom: 4),
                child: Icon(Icons.bolt_rounded),
              ),
              label: ElandStrings.of('tab_focus'),
            ),
            BottomNavigationBarItem(
              icon: const Padding(
                padding: EdgeInsets.only(top: 4, bottom: 4),
                child: Icon(Icons.set_meal_rounded),
              ),
              label: ElandStrings.of('tab_nutri'),
            ),
            BottomNavigationBarItem(
              icon: const Padding(
                padding: EdgeInsets.only(top: 4, bottom: 4),
                child: Icon(Icons.fitness_center_rounded),
              ),
              label: ElandStrings.of('tab_pt'),
            ),
          ],
        ),
      ),)
    );
  }
}