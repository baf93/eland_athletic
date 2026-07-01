import 'package:eland_athletic/common/widgets/primary_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/test_app.dart';

void main() {
  group('PrimaryActionButton', () {
    testWidgets('calls onPressed when tapped', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        buildTestApp(
          PrimaryActionButton(
            label: 'start',
            onPressed: () => pressed = true,
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('renders label in portrait and hides it in landscape', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          PrimaryActionButton(label: 'start', icon: Icons.play_arrow, onPressed: () {}),
          size: const Size(390, 844),
        ),
      );

      expect(find.text('START'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);

      await tester.pumpWidget(
        buildTestApp(
          PrimaryActionButton(label: 'start', icon: Icons.play_arrow, onPressed: () {}),
          size: const Size(844, 390),
        ),
      );

      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      expect(find.text('START'), findsNothing);
    });

    testWidgets('can use custom fixed size', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          PrimaryActionButton(
            label: 'save',
            width: 180,
            height: 48,
            onPressed: () {},
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final size = button.style?.fixedSize?.resolve({});

      expect(size, const Size(180, 48));
    });
  });
}
