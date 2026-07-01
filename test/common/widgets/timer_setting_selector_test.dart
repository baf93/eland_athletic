import 'package:eland_athletic/common/widgets/timer_setting_selector.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/test_app.dart';

void main() {
  group('TimerSettingSelector', () {
    testWidgets('renders label, value and buttons', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          TimerSettingSelector(label: 'work time', value: 20, onChanged: (_) {}),
        ),
      );

      expect(find.text('WORK TIME'), findsOneWidget);
      expect(find.text('20'), findsOneWidget);
      expect(find.byIcon(Icons.remove), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('increments and decrements through controls', (tester) async {
      var value = 20;

      await tester.pumpWidget(
        buildTestApp(
          TimerSettingSelector(
            label: 'rounds',
            value: value,
            onChanged: (v) => value = v,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(value, 21);

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();
      expect(value, 19);
    });

    testWidgets('respects min and max boundaries', (tester) async {
      var minValue = 1;
      await tester.pumpWidget(
        buildTestApp(
          TimerSettingSelector(label: 'min', value: minValue, min: 1, onChanged: (v) => minValue = v),
        ),
      );
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();
      expect(minValue, 1);

      var maxValue = 10;
      await tester.pumpWidget(
        buildTestApp(
          TimerSettingSelector(label: 'max', value: maxValue, max: 10, onChanged: (v) => maxValue = v),
        ),
      );
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(maxValue, 10);
    });

    testWidgets('opens picker when value is tapped', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          TimerSettingSelector(label: 'seconds', value: 10, min: 0, max: 20, onChanged: (_) {}),
        ),
      );

      await tester.tap(find.text('10'));
      await tester.pumpAndSettle();

      expect(find.byType(CupertinoPicker), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
    });
  });
}
