
import 'package:eland_athletic/common/eland_responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../strings.dart';
import '../../models/timer_state.dart';

class AmrapWorkoutWidget extends StatelessWidget {
  final TimerState timerState;
  final ValueNotifier<int> roundNotifier;

  const AmrapWorkoutWidget({
    super.key,
    required this.timerState,
    required this.roundNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = ElandResponsive(context);

    if (r.isLandscape) {
      return _buildLandscape(context, theme, r);
    }

    return _buildPortrait(context, theme, r);
  }

  Widget _buildLandscape(
      BuildContext context,
      ThemeData theme,
      ElandResponsive r,
      ) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(r.spacing(12)),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  roundNotifier.value++;
                },
                borderRadius: BorderRadius.circular(r.radius(20)),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(r.radius(20)),
                    border: Border.all(
                      color: theme.colorScheme.primary,
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _formatTime(timerState.remainingSeconds),
                            style: TextStyle(
                              fontSize: r.byUsableHeight(
                                0.13,
                                min: 34,
                                max: 54,
                              ),
                              fontWeight: FontWeight.w800,
                              color: theme.textTheme.headlineLarge?.color,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: r.compactGap),

                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: ValueListenableBuilder<int>(
                              valueListenable: roundNotifier,
                              builder: (context, value, _) {
                                return Text(
                                  "$value",
                                  style: TextStyle(
                                    fontSize: r.byUsableHeight(
                                      0.38,
                                      min: 80,
                                      max: 150,
                                    ),
                                    fontWeight: FontWeight.w900,
                                    color: theme.colorScheme.primary,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        SizedBox(
          width: r.byWidth(
            0.10,
            min: 60,
            max: 78,
          ),
          child: Center(
            child: SizedBox(
              width: r.byWidth(
                0.055,
                min: 42,
                max: 52,
              ),
              height: r.byUsableHeight(
                0.45,
                min: 140,
                max: 190,
              ),
              child: OutlinedButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  if (roundNotifier.value > 0) {
                    roundNotifier.value--;
                  }
                },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  side: BorderSide(
                    color: theme.dividerColor,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(r.radius(12)),
                  ),
                ),
                child: Icon(
                  Icons.undo,
                  size: r.icon(18),
                  color: Colors.redAccent,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPortrait(
      BuildContext context,
      ThemeData theme,
      ElandResponsive r,
      ) {
    return Column(
      children: [
        SizedBox(height: r.settingsGap),

        Text(
          _formatTime(timerState.remainingSeconds),
          style: TextStyle(
            fontSize: r.font(48, minScale: 0.9, maxScale: 1.1),
            fontWeight: FontWeight.w800,
            color: theme.textTheme.headlineLarge?.color,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),

        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: r.spacing(16),
              horizontal: r.pageHorizontalPadding,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  roundNotifier.value++;
                },
                borderRadius: BorderRadius.circular(r.radius(24)),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(r.radius(24)),
                    border: Border.all(
                      color: theme.colorScheme.primary,
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: ValueListenableBuilder<int>(
                      valueListenable: roundNotifier,
                      builder: (context, value, _) {
                        return FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "$value",
                            style: TextStyle(
                              fontSize: r.font(
                                144,
                                minScale: 0.78,
                                maxScale: 1.08,
                              ),
                              fontWeight: FontWeight.w900,
                              color: theme.colorScheme.primary,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        Padding(
          padding: EdgeInsets.only(
            bottom: r.settingsGap,
          ),
          child: OutlinedButton.icon(
            onPressed: () {
              HapticFeedback.selectionClick();
              if (roundNotifier.value > 0) {
                roundNotifier.value--;
              }
            },
            icon: Icon(
              Icons.undo,
              size: r.icon(16),
            ),
            label: Text(
              ElandStrings.of('remove_round').toUpperCase(),
              style: TextStyle(
                letterSpacing: 2,
                fontSize: r.font(12),
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.redAccent,
              side: BorderSide(
                color: theme.dividerColor,
                width: 1.5,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: r.spacing(24),
                vertical: r.spacing(12),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(r.radius(12)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(int s) {
    final absS = s.abs();

    return '${(absS ~/ 60).toString().padLeft(2, '0')}:${(absS % 60).toString().padLeft(2, '0')}';
  }
}