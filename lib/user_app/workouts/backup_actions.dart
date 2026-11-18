import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/strings.dart';
import '../../common/workouts/providers.dart';
import '../../common/workouts/ui/eland_ui.dart';
import '../providers/settings_provider.dart';

/// Export / import of all user data as a single JSON file.
class BackupActions {
  BackupActions._();

  /// Settings keys included in the backup file.
  static const List<String> settingsKeys = [
    'language',
    'preparationTime',
    'isDarkMode',
    'useMetricUnits',
    'soundEnabled',
    'hapticFeedback',
    'keepScreenOn',
    'primaryColor',
  ];

  static Future<void> export(BuildContext context, WidgetRef ref) async {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      final data = await ref.read(workoutRepositoryProvider).exportData(
        settings: {
          for (final key in settingsKeys)
            if (prefs.containsKey(key)) key: prefs.get(key),
        },
      );
      final bytes =
          Uint8List.fromList(utf8.encode(const JsonEncoder.withIndent('  ').convert(data)));
      final now = DateTime.now();
      final stamp =
          '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';

      final uri = await FilePicker.saveFile(
        fileName: 'eland_backup_$stamp.json',
        bytes: bytes,
        mimeType: 'application/json',
        dialogTitle: ElandStrings.of('export_data'),
      );
      if (uri != null && context.mounted) {
        showElandSnack(context, ElandStrings.of('export_done'));
      }
    } catch (e) {
      debugPrint('[ELAND] export failed: $e');
      if (context.mounted) showElandSnack(context, '$e');
    }
  }

  static Future<void> import(BuildContext context, WidgetRef ref) async {
    try {
      final file = await FilePicker.pickFile(
        dialogTitle: ElandStrings.of('import_data'),
        type: FileType.any,
      );
      if (file == null) return;

      final content = utf8.decode(await file.readAsBytes());
      final decoded = jsonDecode(content);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Invalid backup');
      }

      final result =
          await ref.read(workoutRepositoryProvider).importData(decoded);
      await _applySettings(ref, result.settings);

      await ref.read(customWorkoutsProvider.notifier).reload();
      await ref.read(historyProvider.notifier).reload();
      final workouts = ref.read(customWorkoutsProvider).value ?? const [];
      await ref.read(reminderSchedulerProvider).rescheduleAll(workouts);

      if (context.mounted) {
        showElandSnack(
          context,
          '${ElandStrings.of('import_done')}: ${result.workouts} · ${result.logs}',
        );
      }
    } on FormatException {
      if (context.mounted) {
        showElandSnack(context, ElandStrings.of('import_error'));
      }
    } catch (e) {
      debugPrint('[ELAND] import failed: $e');
      if (context.mounted) {
        showElandSnack(context, ElandStrings.of('import_error'));
      }
    }
  }

  static Future<void> _applySettings(
      WidgetRef ref, Map<String, Object?> settings) async {
    if (settings.isEmpty) return;
    final prefs = ref.read(sharedPreferencesProvider);
    for (final key in settingsKeys) {
      final value = settings[key];
      if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is int) {
        await prefs.setInt(key, value);
      } else if (value is String) {
        await prefs.setString(key, value);
      }
    }
    ref.invalidate(settingsProvider);
  }
}
