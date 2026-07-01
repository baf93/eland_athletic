import 'package:flutter/material.dart';

class ElandResponsive {
  final BuildContext context;

  const ElandResponsive(this.context);

  Size get size => MediaQuery.sizeOf(context);

  double get width => size.width;
  double get height => size.height;
  double get shortestSide => size.shortestSide;
  double get longestSide => size.longestSide;

  EdgeInsets get safePadding => MediaQuery.paddingOf(context);
  double get safeTop => safePadding.top;
  double get safeBottom => safePadding.bottom;

  double get usableHeight => height - safeTop - safeBottom;

  Orientation get orientation => MediaQuery.orientationOf(context);
  bool get isPortrait => orientation == Orientation.portrait;
  bool get isLandscape => orientation == Orientation.landscape;

  bool get isPhone => shortestSide < 600;
  bool get isTablet => shortestSide >= 600 && shortestSide < 900;
  bool get isDesktop => shortestSide >= 900;

  bool get isSmallPhone => shortestSide < 360;
  bool get isLargePhone => shortestSide >= 430 && isPhone;

  double scale({
    double min = 0.9,
    double max = 1.15,
    double base = 390,
  }) {
    return (shortestSide / base).clamp(min, max);
  }

  double font(
      double value, {
        double minScale = 0.9,
        double maxScale = 1.15,
      }) {
    return value * scale(
      min: minScale,
      max: maxScale,
    );
  }

  double icon(
      double value, {
        double minScale = 0.9,
        double maxScale = 1.2,
      }) {
    return value * scale(
      min: minScale,
      max: maxScale,
    );
  }

  double spacing(
      double value, {
        double minScale = 0.85,
        double maxScale = 1.15,
      }) {
    return value * scale(
      min: minScale,
      max: maxScale,
    );
  }

  double radius(
      double value, {
        double minScale = 0.9,
        double maxScale = 1.15,
      }) {
    return value * scale(
      min: minScale,
      max: maxScale,
    );
  }

  double byHeight(
      double factor, {
        required double min,
        required double max,
      }) {
    return (height * factor).clamp(min, max);
  }

  double byUsableHeight(
      double factor, {
        required double min,
        required double max,
      }) {
    return (usableHeight * factor).clamp(min, max);
  }

  double byWidth(
      double factor, {
        required double min,
        required double max,
      }) {
    return (width * factor).clamp(min, max);
  }

  double percentHeight(double percent) {
    return usableHeight * percent;
  }

  double percentWidth(double percent) {
    return width * percent;
  }

  double adaptive(
      double phone,
      double tablet,
      double desktop,
      ) {
    if (isDesktop) return desktop;
    if (isTablet) return tablet;
    return phone;
  }

  double clampDouble(
      double value, {
        required double min,
        required double max,
      }) {
    return value.clamp(min, max);
  }

  double get pageHorizontalPadding {
    if (isSmallPhone) return 16;
    if (isDesktop) return 32;
    return 20;
  }

  double get pageVerticalPadding {
    if (isSmallPhone) return 6;
    return 8;
  }

  EdgeInsets get pagePadding => EdgeInsets.symmetric(
    horizontal: pageHorizontalPadding,
    vertical: pageVerticalPadding,
  );

  double get compactGap => isSmallPhone ? 6 : 8;
  double get settingsGap => isSmallPhone ? 8 : 10;
  double get sectionGap => isSmallPhone ? 12 : 14;
  double get cardGap => isSmallPhone ? 10 : 12;

  double get primaryButtonHeight => isSmallPhone ? 54 : 60;

  double get bottomButtonTopPadding => isSmallPhone ? 4 : 6;
  double get bottomButtonBottomPadding => isSmallPhone ? 6 : 8;

  double get iconButtonSize => adaptive(65, 70, 76);

  double get dialogButtonHeight => adaptive(44, 48, 52);

  double get appBarHeight => adaptive(56, 60, 64);

  double get listTileHeight => adaptive(56, 60, 64);

  EdgeInsets get bottomButtonPadding => EdgeInsets.only(
    top: bottomButtonTopPadding,
    bottom: bottomButtonBottomPadding,
  );
}