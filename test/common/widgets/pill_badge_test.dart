import 'package:eland_athletic/common/widgets/pill_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/test_app.dart';

void main() {
  group('PillBadge', () {
    testWidgets('renders uppercase text', (tester) async {
      await tester.pumpWidget(buildTestApp(const PillBadge(text: 'total time')));

      expect(find.text('TOTAL TIME'), findsOneWidget);
    });

    testWidgets('applies custom text style inputs', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const PillBadge(
            text: 'badge',
            textColor: Colors.red,
            fontSize: 22,
            backgroundColor: Colors.blue,
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('BADGE'));
      expect(text.style?.color, Colors.red);
      expect(text.style?.fontSize, 22);
    });

    testWidgets('long text does not throw on narrow layout', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const PillBadge(text: 'This is a very very very long badge text'),
          size: const Size(320, 640),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
