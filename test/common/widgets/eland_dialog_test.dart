import 'package:eland_athletic/common/widgets/eland_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/test_app.dart';

Widget dialogLauncher({required void Function(bool) onResult, bool showCancel = true}) {
  return Builder(
    builder: (context) => ElevatedButton(
      onPressed: () {
        showElandDialog(
          context: context,
          title: 'Exit',
          content: 'Do you really want to quit?',
          confirmText: 'Yes',
          cancelText: showCancel ? 'No' : null,
          onResult: onResult,
        );
      },
      child: const Text('OPEN'),
    ),
  );
}

void main() {
  group('showElandDialog', () {
    testWidgets('shows title content and actions', (tester) async {
      await tester.pumpWidget(buildTestApp(dialogLauncher(onResult: (_) {})));

      await tester.tap(find.text('OPEN'));
      await tester.pumpAndSettle();

      expect(find.text('EXIT'), findsOneWidget);
      expect(find.text('Do you really want to quit?'), findsOneWidget);
      expect(find.text('YES'), findsOneWidget);
      expect(find.text('NO'), findsOneWidget);
    });

    testWidgets('returns true on confirm and false on cancel', (tester) async {
      bool? result;

      await tester.pumpWidget(buildTestApp(dialogLauncher(onResult: (v) => result = v)));
      await tester.tap(find.text('OPEN'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('YES'));
      await tester.pumpAndSettle();
      expect(result, isTrue);

      result = null;
      await tester.tap(find.text('OPEN'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('NO'));
      await tester.pumpAndSettle();
      expect(result, isFalse);
    });

    testWidgets('can hide cancel button', (tester) async {
      await tester.pumpWidget(buildTestApp(dialogLauncher(onResult: (_) {}, showCancel: false)));
      await tester.tap(find.text('OPEN'));
      await tester.pumpAndSettle();

      expect(find.text('YES'), findsOneWidget);
      expect(find.text('NO'), findsNothing);
    });
  });
}
