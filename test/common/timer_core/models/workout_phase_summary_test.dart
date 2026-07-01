import 'package:eland_athletic/common/timer_core/models/workout_phase_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WorkoutPhaseSummary', () {
    test('serializes and deserializes values', () {
      const original = WorkoutPhaseSummary(title: 'TABATA', details: '8R x 3S');

      final json = original.toJson();
      final restored = WorkoutPhaseSummary.fromJson(json);

      expect(json, {'title': 'TABATA', 'details': '8R x 3S'});
      expect(restored.title, original.title);
      expect(restored.details, original.details);
    });

    test('toString contains title and details', () {
      const summary = WorkoutPhaseSummary(title: 'AMRAP', details: '10M');

      expect(summary.toString(), '{title: AMRAP, details: 10M}');
    });
  });
}
