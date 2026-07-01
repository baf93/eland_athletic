import 'package:eland_athletic/common/widgets/timer_row_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/test_app.dart';

void main() {
  group('TimerRowItem', () {
    testWidgets('renders icon, title and arrow', (tester) async {
      await tester.pumpWidget(
        buildTestApp(TimerRowItem(icon: Icons.timer, title: 'TABATA', onTap: () {})),
      );

      expect(find.byIcon(Icons.timer), findsOneWidget);
      expect(find.text('TABATA'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_ios_rounded), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        buildTestApp(TimerRowItem(icon: Icons.loop_rounded, title: 'EMOM', onTap: () => tapped = true)),
      );

      await tester.tap(find.text('EMOM'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('long title does not throw on small screen', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          TimerRowItem(icon: Icons.timer, title: 'VERY VERY VERY LONG TIMER TITLE', onTap: () {}),
          size: const Size(320, 640),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
