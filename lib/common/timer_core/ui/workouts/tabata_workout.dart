import 'package:flutter/material.dart';
import '../../models/timer_state.dart';
import '../../models/timercore_enums.dart';

class TabataWorkoutWidget extends StatelessWidget {
  final TimerState timerState;

  const TabataWorkoutWidget({super.key, required this.timerState});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWork = timerState.intervalType == IntervalType.work;
    final isCooldown = timerState.intervalType == IntervalType.cooldown;
    final Color color = isWork ? theme.colorScheme.error : (isCooldown ? theme.colorScheme.primary : theme.colorScheme.tertiary);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. INFO: Rigidità ELAND
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _labelValue("SET", "${timerState.currentSet}/${timerState.totalSet}"),
              _labelValue("ROUND", "${timerState.currentRound}/${timerState.totalRound}"),
            ],
          ),

          const SizedBox(height: 48),

          // 2. TIMING: Il cuore grafico
          Text(
            isCooldown ? "COOLDOWN" : (isWork ? "WORK" : "REST"),
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 8),
          ),
          const SizedBox(height: 8),
          Text(
            _formatTime(timerState.remainingSeconds),
            style: const TextStyle(fontSize: 120, fontWeight: FontWeight.w900, height: 1, fontFeatures: [FontFeature.tabularFigures()]),
          ),

          // 3. PROGRESSO: Minimalismo puro (solo una riga, niente cerchi complessi)
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: timerState.intervalProgress,
            backgroundColor: theme.colorScheme.onSurface.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 2,
          ),

          const SizedBox(height: 32),

          // 4. MOTIVAZIONE: Minimalismo
          Text(
            _getMotivation(timerState.intervalType).toUpperCase(),
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 4),
          ),
        ],
      ),
    );
  }

  Widget _labelValue(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 4)),
      Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
    ],
  );

  String _getMotivation(IntervalType phase) => phase == IntervalType.work ? "PUSH" : (phase == IntervalType.rest ? "RECOVER" : "SLOW");

  String _formatTime(int s) {
    final absS = s.abs();
    return '${(absS ~/ 60).toString().padLeft(2, '0')}:${(absS % 60).toString().padLeft(2, '0')}';
  }
}