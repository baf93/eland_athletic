import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/stopwatch_controller.dart';
import '../../providers/stopwatch_provider.dart';
import '../../models/timercore_enums.dart';
import '../../../strings.dart';
import '../../../widgets/eland_dialog.dart';

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

    // Auto Scroll for Laps
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
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            HapticFeedback.heavyImpact();
            showElandDialog(
                context: context,
                title: ElandStrings.of('workout_abort_title').toUpperCase(),
                content: ElandStrings.of('workout_abort_desc'),
                cancelText: ElandStrings.of('cancel_btn').toUpperCase(),
                confirmText: ElandStrings.of('ok_btn').toUpperCase(),
                onResult: (confirmed) {
                  if(confirmed){
                    StopwatchController.instance.stopStopWatch();
                    Navigator.pop(context);
                  }
                }
            );
          },
        ),
        title: Text(
          ElandStrings.of('timer_stopwatch').toUpperCase(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
      ),


      body: Column(
        children: [

          /// -- TIMER BOX
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.primary, width: 2),
              ),
              child: FittedBox(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(fontWeight: FontWeight.w900, color: theme.textTheme.headlineLarge!.color, fontFeatures: [FontFeature.tabularFigures()]),
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

          const SizedBox(height: 15),

          // Laps Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(ElandStrings.of('lap_title').toUpperCase(),
                    style: TextStyle(color: theme.textTheme.headlineLarge!.color, fontSize: 16, letterSpacing: 2, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          const SizedBox(height: 10),
          Container(height: 1, color: theme.dividerColor),

          // Laps list
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: state.laps.length,
              separatorBuilder: (_, __) => Divider(color: theme.dividerColor, height: 20),
              itemBuilder: (context, index) {
                final lap = state.laps[index];
                final duration = Duration(milliseconds: lap.lapTimeMs);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${ElandStrings.of('lap').toUpperCase()} ${index + 1}", style: TextStyle(color: theme.textTheme.bodyMedium!.color, fontSize: 14, fontWeight: FontWeight.w600)),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(text: _formatMainTime(0, duration.inMinutes % 60, duration.inSeconds % 60), style: TextStyle(fontSize: 18, color: theme.textTheme.headlineLarge!.color)),
                          TextSpan(text: ".${(duration.inMilliseconds % 1000 ~/ 10).toString().padLeft(2, '0')}", style: TextStyle(fontSize: 14, color: theme.colorScheme.primary)),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // controls
          Container(
            decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, border: Border(top: BorderSide(color: theme.dividerColor, width: 1.0))),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _actionButton(
                    canReset ? Icons.refresh : Icons.close,
                    canReset ? theme.textTheme.bodyMedium!.color! : Colors.redAccent,
                    canReset ? ElandStrings.of('reset').toUpperCase() : ElandStrings.of('exit').toUpperCase(),
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