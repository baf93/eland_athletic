import 'package:eland_athletic/common/strings.dart';
import 'package:eland_athletic/common/theme.dart';
import 'package:flutter/material.dart';

Widget buildTestApp(
  Widget child, {
  Size size = const Size(390, 844),
  ThemeData? theme,
}) {
  ElandStrings.initLocale('en');

  return MaterialApp(
    theme: theme ?? ElandTheme.lightTheme,
    home: MediaQuery(
      data: MediaQueryData(size: size),
      child: Scaffold(
        body: Center(child: child),
      ),
    ),
  );
}

Widget buildBareTestApp(
  Widget child, {
  Size size = const Size(390, 844),
  ThemeData? theme,
}) {
  ElandStrings.initLocale('en');

  return MaterialApp(
    theme: theme ?? ElandTheme.lightTheme,
    home: MediaQuery(
      data: MediaQueryData(size: size),
      child: child,
    ),
  );
}
