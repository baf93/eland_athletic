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
      unselectedItems: unselectedItems ?? this.unselectedItems
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
  static const Color orangeAccent = Color(0xFFFFB04A);

  // --- Dark Mode ---
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121212),

      colorScheme: const ColorScheme.dark(
        primary: orangeAccent,
        secondary: orangeAccent,
        surface: Color(0xFF1E1E1E),
      ),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: Color(0xFFE0E0E0)),
        bodyMedium: TextStyle(color: Colors.grey),
      ),

      // Definition of custom colors for dark mode
      extensions: <ThemeExtension<dynamic>>[
        const ElandCustomColors(
          timerBg: orangeAccent,
          cardBorder: Colors.white10,
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
      scaffoldBackgroundColor: const Color(0xFFF8F9FA),

      colorScheme: const ColorScheme.light(
        primary: orangeAccent,
        secondary: Color(0xFFE09030),
        surface: Colors.white,
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
          cardBorder: Color(0xFFE2E8F0),
          unselectedItems: Colors.grey,
        ),
      ],
    );
  }
}