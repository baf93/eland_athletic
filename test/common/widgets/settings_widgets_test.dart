import 'package:eland_athletic/common/widgets/settings_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/test_app.dart';

void main() {
  group('Settings widgets', () {
    testWidgets('SettingsSectionTitle renders title', (tester) async {
      await tester.pumpWidget(buildTestApp(const SettingsSectionTitle(title: 'General')));

      expect(find.text('General'), findsOneWidget);
    });

    testWidgets('SettingsSwitchTile toggles value callback', (tester) async {
      bool value = false;

      await tester.pumpWidget(
        buildTestApp(
          SettingsSwitchTile(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Enable notifications',
            value: value,
            onChanged: (v) => value = v,
          ),
        ),
      );

      expect(find.text('Notifications'), findsOneWidget);
      await tester.tap(find.byType(Switch));
      await tester.pump();
      expect(value, isTrue);
    });

    testWidgets('SettingsDropdownTile renders selected value', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          SettingsDropdownTile<String>(
            icon: Icons.language,
            title: 'Language',
            subtitle: 'Choose language',
            value: 'en',
            items: const ['en', 'it'],
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('Language'), findsOneWidget);
      expect(find.text('EN'), findsOneWidget);
      expect(find.byIcon(Icons.expand_more), findsOneWidget);
    });

    testWidgets('SettingsActionTile calls onTap', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        buildTestApp(
          SettingsActionTile(
            icon: Icons.info,
            title: 'About',
            subtitle: 'App info',
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.text('About'));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('SettingsInfoCard renders content', (tester) async {
      await tester.pumpWidget(
        buildTestApp(const SettingsInfoCard(title: 'Philosophy', content: Text('Train hard'))),
      );

      expect(find.text('Philosophy'), findsOneWidget);
      expect(find.text('Train hard'), findsOneWidget);
    });

    testWidgets('SettingsColorSelector shows selected mark and calls selection callback', (tester) async {
      int selected = 0;

      await tester.pumpWidget(
        buildTestApp(
          SettingsColorSelector(
            icon: Icons.palette,
            title: 'Color',
            colors: const [Colors.red, Colors.green, Colors.blue],
            selectedIndex: selected,
            onColorSelected: (i) => selected = i,
          ),
        ),
      );

      expect(find.byIcon(Icons.check), findsOneWidget);
      await tester.tap(find.byType(GestureDetector).last);
      await tester.pump();
      expect(selected, 2);
    });
  });
}
