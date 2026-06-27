import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/stopwatch_controller.dart';
import '../../providers/stopwatch_provider.dart';
import '../../models/timercore_enums.dart';
import '../../../strings.dart';

class StopwatchPage extends ConsumerStatefulWidget {
  const StopwatchPage({super.key});

  @override
  ConsumerState<StopwatchPage> createState() => _StopwatchPageState();
}

class _StopwatchPageState extends ConsumerState<StopwatchPage> {
  final ScrollController _scrollController = ScrollController();
  int _previousLapCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      StopwatchController.instance.launchStopwatch();
      StopwatchController.instance.requestStatus();

      final state = ref.read(stopwatchProvider);
      _previousLapCount = state.laps.length;
    });
  }

  String _formatMainTime(int h, int m, int s) {
    String sStr = s.toString().padLeft(2, '0');
    String mStr = m.toString().padLeft(2, '0');
    if (h > 0) return '${h.toString().padLeft(2, '0')}:$mStr:$sStr';
    return '$mStr:$sStr';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stopwatchProvider);
    final theme = Theme.of(context);
    final isRunning = state.status == TimerStatus.running;
    final bool canReset = state.status == TimerStatus.paused &&
        (state.elapsedSeconds > 0 || state.elapsedMinutes > 0 || state.elapsedHours > 0);

    // Gestione auto-scroll con ritardo per garantire il rendering della lista
    if (state.laps.length > _previousLapCount) {
      _previousLapCount = state.laps.length;
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(ElandStrings.of('stopwatch').toUpperCase(),
            style: const TextStyle(fontSize: 14, letterSpacing: 2, fontWeight: FontWeight.w900)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // 1. TIMER BOX
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: theme.colorScheme.primary.withOpacity(0.5), width: 2),
              ),
              child: FittedBox(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontFeatures: [FontFeature.tabularFigures()]),
                    children: [
                      TextSpan(text: _formatMainTime(state.elapsedHours, state.elapsedMinutes, state.elapsedSeconds), style: const TextStyle(fontSize: 84)),
                      TextSpan(
                        text: ".${(state.elapsedMilliseconds ~/ 10).toString().padLeft(2, '0')}",
                        style: TextStyle(fontSize: 42, color: theme.colorScheme.primary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 2. INTESTAZIONE LAPS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Row(
              children: [
                Text(ElandStrings.of('laps').toUpperCase(),
                    style: TextStyle(color: theme.colorScheme.primary, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          // 3. LISTA LAPS
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: state.laps.length,
              separatorBuilder: (_, __) => Divider(color: Colors.white.withOpacity(0.08), height: 20),
              itemBuilder: (context, index) {
                final lap = state.laps[index];
                final duration = Duration(milliseconds: lap.lapTimeMs);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("LAP ${index + 1}", style: TextStyle(color: Colors.white.withOpacity(0.4), fontWeight: FontWeight.w600)),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(text: _formatMainTime(0, duration.inMinutes % 60, duration.inSeconds % 60), style: const TextStyle(color: Colors.white)),
                          TextSpan(text: ".${(duration.inMilliseconds % 1000 ~/ 10).toString().padLeft(2, '0')}", style: TextStyle(color: theme.colorScheme.primary)),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // 4. CONTROLLI
          Container(
            decoration: BoxDecoration(color: Colors.black, border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1), width: 1.0))),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _actionButton(
                    canReset ? Icons.refresh : Icons.close,
                    canReset ? Colors.amber : Colors.white.withOpacity(0.5),
                    canReset ? "RESET" : ElandStrings.of('exit'),
                        () => canReset ? StopwatchController.instance.resetStopWatch() : StopwatchController.instance.stopStopWatch()),

                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    isRunning ? StopwatchController.instance.pauseStopWatch() : StopwatchController.instance.resumeStopWatch();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(shape: BoxShape.circle, color: theme.colorScheme.primary),
                    child: Icon(isRunning ? Icons.pause : Icons.play_arrow, color: Colors.black, size: 36),
                  ),
                ),

                _actionButton(Icons.timer_outlined, theme.colorScheme.primary, ElandStrings.of('lap'),
                        () => StopwatchController.instance.recordLap()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, Color color, String label, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: color, width: 1.5)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label.toUpperCase(), style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
        ],
      ),
    );
  }
}