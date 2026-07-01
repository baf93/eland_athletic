import 'package:eland_athletic/common/eland_responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<ElandResponsive> pumpResponsive(
  WidgetTester tester,
  Size size,
) async {
  late ElandResponsive responsive;

  await tester.pumpWidget(
    MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: Builder(
          builder: (context) {
            responsive = ElandResponsive(context);
            return const SizedBox();
          },
        ),
      ),
    ),
  );

  return responsive;
}

void main() {
  group('ElandResponsive', () {
    testWidgets('classifies phone sizes', (tester) async {
      final small = await pumpResponsive(tester, const Size(320, 640));
      expect(small.isPhone, isTrue);
      expect(small.isSmallPhone, isTrue);
      expect(small.pageHorizontalPadding, 16);
      expect(small.primaryButtonHeight, 54);

      final regular = await pumpResponsive(tester, const Size(390, 844));
      expect(regular.isPhone, isTrue);
      expect(regular.isSmallPhone, isFalse);
      expect(regular.pageHorizontalPadding, 20);
    });

    testWidgets('classifies tablet and desktop sizes', (tester) async {
      final tablet = await pumpResponsive(tester, const Size(800, 1200));
      expect(tablet.isTablet, isTrue);
      expect(tablet.adaptive(1, 2, 3), 2);
      expect(tablet.iconButtonSize, 70);

      final desktop = await pumpResponsive(tester, const Size(1000, 1200));
      expect(desktop.isDesktop, isTrue);
      expect(desktop.adaptive(1, 2, 3), 3);
      expect(desktop.pageHorizontalPadding, 32);
    });

    testWidgets('detects orientation from MediaQuery size', (tester) async {
      final portrait = await pumpResponsive(tester, const Size(390, 844));
      expect(portrait.isPortrait, isTrue);
      expect(portrait.isLandscape, isFalse);

      final landscape = await pumpResponsive(tester, const Size(844, 390));
      expect(landscape.isLandscape, isTrue);
      expect(landscape.isPortrait, isFalse);
    });

    testWidgets('scaling helpers are clamped and deterministic', (tester) async {
      final regular = await pumpResponsive(tester, const Size(390, 844));
      expect(regular.scale(), 1.0);
      expect(regular.font(20), 20);
      expect(regular.icon(30), 30);
      expect(regular.spacing(10), 10);
      expect(regular.radius(16), 16);

      final small = await pumpResponsive(tester, const Size(320, 640));
      expect(small.scale(), 0.9);

      final large = await pumpResponsive(tester, const Size(1000, 1200));
      expect(large.scale(), 1.15);
    });

    testWidgets('dimension helpers return bounded values', (tester) async {
      final r = await pumpResponsive(tester, const Size(400, 800));

      expect(r.byHeight(0.5, min: 100, max: 1000), 400);
      expect(r.byWidth(0.5, min: 100, max: 1000), 200);
      expect(r.byHeight(0.9, min: 100, max: 300), 300);
      expect(r.percentWidth(0.25), 100);
      expect(r.clampDouble(30, min: 10, max: 20), 20);
    });
  });
}
