import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/workout_controller.dart';
import '../providers/timer_provider.dart';
import '../models/timercore_enums.dart';
import '../models/timer_state.dart';
import '../../strings.dart';
import '../../widgets/progress_bar.dart';

class WorkoutPage extends ConsumerStatefulWidget {
  const WorkoutPage({super.key});

  @override
  ConsumerState<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends ConsumerState<WorkoutPage>{

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WorkoutController.instance.requestStatus();
    });
  }

  // Utilities functions
  void _openPhaseSummary(BuildContext context, TimerState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Necessario per altezze personalizzate
      backgroundColor: Colors.transparent,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.8, // 80% dell'altezza schermo
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF121212),
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              // Lineetta di chiusura (stile tipico)
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: state.workoutPhaseSummary.length,
                  itemBuilder: (context, index) {
                    final summary = state.workoutPhaseSummary[index];
                    bool isCurrent = index == state.currentPhaseIndex;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("FASE ${index + 1}",
                              style: TextStyle(color: isCurrent ? Colors.white : Colors.white30, fontSize: 16)),
                          Text(summary.title,
                              style: TextStyle(color: isCurrent ? const Color(0xFFE69138) : Colors.white60, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context){
    //Theme Injection
    final theme = Theme.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    // Watcher for TimerState
    final timerState = ref.watch(timerProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // --- APP BAR ---
      appBar: AppBar(backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => {
            WorkoutController.instance.stopWorkout(),
            Navigator.maybePop(context),
          }
        ),
        title: Text(
          '${timerState.workoutTitle} [${timerState.currentPhaseIndex}/${timerState.totalPhases}]'.toUpperCase() ,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          ElandSegmentedProgressBar(
            totalSegments: timerState.totalPhases,
            currentSegment: timerState.currentPhaseIndex,
            onTap: () => _openPhaseSummary(context, timerState),
          ),
        ],
      ),
    );
  }
}