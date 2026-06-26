import 'package:flutter/material.dart';

// Definition of the Theme colors of the App for Dark and light mode
class ElandCustomColors extends ThemeExtension<ElandCustomColors> {
  final Color? timerBg;
  final Color? cardBorder;
  final Color? unselectedItems;

  const ElandCustomColors({
    required this.timerBg,
    required this.cardBorder,
    required this.unselectedItems
  });

  @override
  ThemeExtension<ElandCustomColors> copyWith({
    Color? timerBg,
    Color? cardBorder,
  }) {
    return ElandCustomColors(
      timerBg: timerBg ?? this.timerBg,
      cardBorder: cardBorder ?? this.cardBorder,
      unselectedItems: unselectedItems ?? unselectedItems
    );
  }

  @override
  ThemeExtension<ElandCustomColors> lerp(ThemeExtension<ElandCustomColors>? other, double t) {
    if (other is! ElandCustomColors) return this;
    return ElandCustomColors(
      timerBg: Color.lerp(timerBg, other.timerBg, t),
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t),
      unselectedItems: Color.lerp(unselectedItems, other.unselectedItems, t),
    );
  }
}

class ElandTheme {
  // Brand color for the app, used in both dark and light mode
  static const Color orangeAccent = Color(0xFFFF9500);

  // --- Dark Mode ---
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF000000), //0xFF121212
      cardColor: const Color(0xFF000000),
      dividerColor: Colors.white24,

      colorScheme: const ColorScheme.dark(
        primary: orangeAccent,
        secondary: orangeAccent,
        surface: Color(0xFF1E1E1E),
        error: Colors.red,
      ),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: Color(0xFFE0E0E0)),
        bodyMedium: TextStyle(color: Colors.white70),
      ),

      // Definition of custom colors for dark mode
      extensions: <ThemeExtension<dynamic>>[
        const ElandCustomColors(
          timerBg: orangeAccent,
          cardBorder: Colors.white24,
          unselectedItems: Colors.grey,
        ),
      ],
    );
  }

  // --- Light mode ---
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFFFFFFF), //0xFFF8F9FA
      cardColor: const Color(0xFFFFFFFF),
      dividerColor: Colors.black26,

      colorScheme: const ColorScheme.light(
        primary: orangeAccent,
        secondary: Color(0xFFE09030),
        surface: Colors.white,
        error: Colors.red,
      ),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: Color(0xFF111111), fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: Color(0xFF2D2D2D)),
        bodyMedium: TextStyle(color: Color(0xFF666666)),
      ),

      // Definition of custom colors for light mode
      extensions: <ThemeExtension<dynamic>>[
        const ElandCustomColors(
          timerBg: orangeAccent,
          cardBorder: Colors.black26,
          unselectedItems: Colors.black54,
        ),
      ],
    );
  }
}

class ElandColors {
  static const List<Color> customPalette = [
    Color(0xFFFF9500), // 1. Eland Orange (Base)
    Color(0xFFE74C3C), // 2. Sunset Red
    Color(0xFFFFC107), // 3. Lemon Gold
    Color(0xFF27AE60), // 4. Kelly Green
    Color(0xFF3498DB), // 5. Sky Blue
    Color(0xFF9B59B6), // 6. Electric Purple
  ];
}