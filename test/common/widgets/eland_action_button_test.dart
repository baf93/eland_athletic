import 'package:eland_athletic/common/widgets/eland_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/test_app.dart';

void main() {
  group('ElandActionButton', () {
    testWidgets('renders icon and calls callback', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        buildTestApp(
          ElandActionButton(icon: Icons.play_arrow, onPressed: () => tapped = true),
        ),
      );

      expect(find.byIcon(Icons.play_arrow), findsOneWidget);

      await tester.tap(find.byType(InkWell));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('supports custom size and colors', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          ElandActionButton(
            icon: Icons.close,
            iconColor: Colors.redAccent,
            borderColor: Colors.green,
            size: 80,
            onPressed: () {},
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.close));
      expect(icon.color, Colors.redAccent);

      final inkSize = tester.getSize(find.byType(InkWell));
      expect(inkSize.width, 80);
      expect(inkSize.height, 80);
    });
  });
}
