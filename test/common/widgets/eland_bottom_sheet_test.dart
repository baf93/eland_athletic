import 'package:eland_athletic/common/widgets/eland_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/test_app.dart';

void main() {
  group('ElandBottomSheet', () {
    testWidgets('renders builder content and provides scroll controller', (tester) async {
      ScrollController? controller;

      await tester.pumpWidget(
        buildTestApp(
          ElandBottomSheet(
            builder: (c) {
              controller = c;
              return const Text('Sheet content');
            },
          ),
        ),
      );

      expect(find.text('Sheet content'), findsOneWidget);
      expect(find.byType(DraggableScrollableSheet), findsOneWidget);
      expect(controller, isNotNull);
    });

    testWidgets('uses provided initialChildSize', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          ElandBottomSheet(initialChildSize: 0.7, builder: (_) => const Text('Content')),
        ),
      );

      final sheet = tester.widget<DraggableScrollableSheet>(find.byType(DraggableScrollableSheet));
      expect(sheet.initialChildSize, 0.7);
    });

    testWidgets('uses orientation based defaults from MediaQuery', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          ElandBottomSheet(builder: (_) => const Text('Portrait')),
          size: const Size(390, 844),
        ),
      );
      var sheet = tester.widget<DraggableScrollableSheet>(find.byType(DraggableScrollableSheet));
      expect(sheet.initialChildSize, 0.60);
      expect(sheet.maxChildSize, 0.90);

      await tester.pumpWidget(
        buildTestApp(
          ElandBottomSheet(builder: (_) => const Text('Landscape')),
          size: const Size(844, 390),
        ),
      );
      sheet = tester.widget<DraggableScrollableSheet>(find.byType(DraggableScrollableSheet));
      expect(sheet.initialChildSize, 0.75);
      expect(sheet.maxChildSize, 0.95);
    });
  });
}
