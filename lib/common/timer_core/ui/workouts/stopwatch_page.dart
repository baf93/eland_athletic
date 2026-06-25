import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/stopwatch_controller.dart';
import '../../providers/stopwatch_provider.dart';
import '../../models/timercore_enums.dart';

class StopwatchPage extends ConsumerStatefulWidget {
  const StopwatchPage({super.key});

  @override
  ConsumerState<StopwatchPage> createState() => _StopwatchPageState();
}

class _StopwatchPageState extends ConsumerState<StopwatchPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      StopwatchController.instance.launchStopwatch();
      StopwatchController.instance.requestStatus();
    });
  }

  // MM:SS.ms (Il mockup usa solo 2 cifre per i millisecondi / 10)
  String _formatDisplayTime(int m, int s, int ms) {
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}.${(ms ~/ 10).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stopwatchProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),

            // --- TEMPO PRINCIPALE ---
            Text(
              _formatDisplayTime(state.elapsedMinutes, state.elapsedSeconds, state.elapsedMilliseconds),
              style: const TextStyle(
                color: Color(0xFFEBDCC9),
                fontSize: 96,
                fontWeight: FontWeight.w300,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 40),

            // --- BOTTONI CIRCOLARI ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _circularButton(
                    state.status == TimerStatus.running ? Icons.pause : Icons.play_arrow,
                        () => state.status == TimerStatus.running ? StopwatchController.instance.pauseStopWatch() : StopwatchController.instance.resumeStopWatch(),
                    "PAUSA", const Color(0xFFEBDCC9)),
                _circularButton(Icons.close, () => StopwatchController.instance.stopStopWatch(), "ESCI", const Color(0xFFFF5252)),
                _circularButton(Icons.timer_outlined, () => StopwatchController.instance.recordLap(), "GIRO", const Color(0xFF4A90E2)),
              ],
            ),

            const SizedBox(height: 40),

            // --- BOX LISTA GIRI ---
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(35),
                ),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
                  reverse: true,
                  itemCount: state.laps.length,
                  separatorBuilder: (context, index) => Divider(color: Colors.white.withOpacity(0.08), height: 30),
                  itemBuilder: (context, index) {
                    final lap = state.laps[index];
                    final duration = Duration(milliseconds: lap.lapTimeMs);
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("GIRO ${state.laps.length - index}", // Numerazione invertita come da mockup
                            style: const TextStyle(color: Color(0xFFEBDCC9), fontSize: 18, fontWeight: FontWeight.w600)),
                        Text(_formatDisplayTime(duration.inMinutes % 60, duration.inSeconds % 60, duration.inMilliseconds),
                            style: const TextStyle(color: Color(0xFFEBDCC9), fontSize: 18, fontWeight: FontWeight.w600, fontFamily: 'monospace')),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _circularButton(IconData icon, VoidCallback onPressed, String label, Color labelColor) {
    return Column(
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.0),
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
        ),
        const SizedBox(height: 14),
        Text(label, style: TextStyle(color: labelColor, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
      ],
    );
  }
}