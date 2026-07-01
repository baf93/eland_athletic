import 'package:eland_athletic/common/widgets/eland_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/test_app.dart';

void main() {
  group('ElandCard', () {
    testWidgets('renders title, optional subtitle and content', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const ElandCard(
            title: 'Workout',
            subtitle: 'Quick Timer',
            child: Text('Body'),
          ),
        ),
      );

      expect(find.text('WORKOUT'), findsOneWidget);
      expect(find.text('QUICK TIMER'), findsOneWidget);
      expect(find.text('Body'), findsOneWidget);
    });

    testWidgets('calls onTap only when provided', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        buildTestApp(
          ElandCard(
            title: 'Workout',
            onTap: () => tapped = true,
            child: const Text('Body'),
          ),
        ),
      );

      expect(find.byType(InkWell), findsOneWidget);
      await tester.tap(find.byType(InkWell));
      await tester.pump();
      expect(tapped, isTrue);

      await tester.pumpWidget(
        buildTestApp(
          const ElandCard(title: 'Workout', child: Text('Body')),
        ),
      );
      expect(find.byType(InkWell), findsNothing);
    });

    testWidgets('long title does not throw', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const ElandCard(
            title: 'This is a very very very long card title that should not overflow',
            child: Text('Body'),
          ),
          size: Size(320, 640),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
