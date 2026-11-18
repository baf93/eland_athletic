import 'dart:async';

import 'package:eland_athletic/common/eland_responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
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

  StreamSubscription? _serviceStoppedSub;
  bool _exiting = false;

  @override
  void initState() {
    super.initState();
    // "Stop" pressed on the live notification: leave the page.
    _serviceStoppedSub =
        FlutterBackgroundService().on('serviceStopped').listen((_) {
      if (!mounted || _exiting) return;
      _exiting = true;
      Navigator.of(context).pop();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // The stopwatch is started by whoever opens this page; here we only
      // sync with it, so reopening from the notification does not reset it.
      StopwatchController.instance.requestStatus();

      final state = ref.read(stopwatchProvider);
      _previousLapCount = state.laps.length;
    });
  }

  @override
  void dispose() {
    _serviceStoppedSub?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleExit() {
    HapticFeedback.heavyImpact();
    showElandDialog(
      context: context,
      title: ElandStrings.of('workout_abort_title').toUpperCase(),
      content: ElandStrings.of('workout_abort_desc'),
      cancelText: ElandStrings.of('cancel_btn').toUpperCase(),
      confirmText: ElandStrings.of('ok_btn').toUpperCase(),
      onResult: (confirmed) {
        if (confirmed) {
          _exiting = true;
          StopwatchController.instance.stopStopWatch();
          Navigator.pop(context);
        }
      },
    );
  }

  String _formatMainTime(int h, int m, int s) {
    final sStr = s.toString().padLeft(2, '0');
    final mStr = m.toString().padLeft(2, '0');
    if (h > 0) return '${h.toString().padLeft(2, '0')}:$mStr:$sStr';
    return '$mStr:$sStr';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stopwatchProvider);
    final theme = Theme.of(context);
    final r = ElandResponsive(context);

    final isRunning = state.status == TimerStatus.running;
    final bool canReset = state.status == TimerStatus.paused &&
        (state.elapsedSeconds > 0 ||
            state.elapsedMinutes > 0 ||
            state.elapsedHours > 0);

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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleExit();
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: _handleExit,
          ),
          title: Text(
            ElandStrings.of('timer_stopwatch').toUpperCase(),
            style: TextStyle(
              fontSize: r.font(18),
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(r.spacing(12)),
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: r.spacing(22),
                  horizontal: r.spacing(22),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(r.radius(16)),
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: theme.textTheme.headlineLarge!.color,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                      children: [
                        TextSpan(
                          text: _formatMainTime(
                            state.elapsedHours,
                            state.elapsedMinutes,
                            state.elapsedSeconds,
                          ),
                          style: TextStyle(
                            fontSize: r.font(
                              92,
                              minScale: 0.78,
                              maxScale: 1.08,
                            ),
                          ),
                        ),
                        TextSpan(
                          text:
                          ".${(state.elapsedMilliseconds ~/ 10).toString().padLeft(2, '0')}",
                          style: TextStyle(
                            fontSize: r.font(
                              46,
                              minScale: 0.78,
                              maxScale: 1.08,
                            ),
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: r.spacing(18)),

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: r.pageHorizontalPadding,
              ),
              child: Row(
                children: [
                  Text(
                    ElandStrings.of('lap_title').toUpperCase(),
                    style: TextStyle(
                      color: theme.textTheme.headlineLarge!.color,
                      fontSize: r.font(16),
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: r.sectionGap),
            Container(height: 1, color: theme.dividerColor),
            SizedBox(height: r.compactGap),

            Expanded(
              child: ListView.separated(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(
                  horizontal: r.pageHorizontalPadding,
                  vertical: r.settingsGap,
                ),
                itemCount: state.laps.length,
                separatorBuilder: (_, __) => Divider(
                  color: theme.dividerColor,
                  height: r.spacing(26),
                ),
                itemBuilder: (context, index) {
                  final lap = state.laps[index];
                  final duration = Duration(milliseconds: lap.lapTimeMs);

                  final int h = duration.inHours;
                  final int m = duration.inMinutes % 60;
                  final int s = duration.inSeconds % 60;
                  final int ms = (duration.inMilliseconds % 1000) ~/ 10;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${ElandStrings.of('lap').toUpperCase()} ${index + 1}",
                        style: TextStyle(
                          color: theme.textTheme.bodyMedium!.color,
                          fontSize: r.font(15),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: h > 0
                                  ? '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}'
                                  : '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: r.font(20),
                                color: theme.textTheme.headlineLarge!.color,
                              ),
                            ),
                            TextSpan(
                              text: ".${ms.toString().padLeft(2, '0')}",
                              style: TextStyle(
                                fontSize: r.font(16),
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                border: Border(
                  top: BorderSide(
                    color: theme.dividerColor,
                    width: 1.0,
                  ),
                ),
              ),
              padding: EdgeInsets.fromLTRB(
                r.pageHorizontalPadding,
                r.spacing(22),
                r.pageHorizontalPadding,
                r.safeBottom + r.spacing(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _actionButton(
                    context,
                    canReset ? Icons.refresh : Icons.close,
                    canReset
                        ? theme.textTheme.bodyMedium!.color!
                        : Colors.redAccent,
                    canReset
                        ? ElandStrings.of('reset').toUpperCase()
                        : ElandStrings.of('exit').toUpperCase(),
                        () => canReset
                        ? StopwatchController.instance.resetStopWatch()
                        : _handleExit(),
                  ),

                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      isRunning
                          ? StopwatchController.instance.pauseStopWatch()
                          : StopwatchController.instance.resumeStopWatch();
                    },
                    child: Container(
                      padding: EdgeInsets.all(r.spacing(28)),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.primary,
                      ),
                      child: Icon(
                        isRunning ? Icons.pause : Icons.play_arrow,
                        color: Colors.black,
                        size: r.icon(40),
                      ),
                    ),
                  ),

                  _actionButton(
                    context,
                    Icons.timer_outlined,
                    theme.colorScheme.primary,
                    ElandStrings.of('lap'),
                        () => StopwatchController.instance.recordLap(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(
      BuildContext context,
      IconData icon,
      Color color,
      String label,
      VoidCallback onPressed,
      ) {
    final r = ElandResponsive(context);

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onPressed();
      },
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(r.spacing(18)),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 1.5),
            ),
            child: Icon(
              icon,
              color: color,
              size: r.icon(26),
            ),
          ),
          SizedBox(height: r.compactGap),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: r.font(12),
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}