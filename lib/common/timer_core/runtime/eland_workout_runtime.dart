import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

import '../models/workout_interval.dart';
import '../models/workout_phase_summary.dart';
import 'workout_runtime_update.dart';

enum ElandWorkoutRuntimePlatform {
  android,
  ios,
  unsupported,
}

enum ElandWorkoutRuntimeStatus {
  idle,
  running,
  paused,
  ended,
}

class ElandWorkoutRuntimeState {
  final ElandWorkoutRuntimeStatus status;
  final String? workoutId;
  final String? workoutTitle;
  final int? remainingSeconds;
  final int? elapsedSeconds;
  final String? phaseTitle;
  final int? currentRound;
  final int? totalRound;
  final int? currentSet;
  final int? totalSet;

  const ElandWorkoutRuntimeState({
    required this.status,
    this.workoutId,
    this.workoutTitle,
    this.remainingSeconds,
    this.elapsedSeconds,
    this.phaseTitle,
    this.currentRound,
    this.totalRound,
    this.currentSet,
    this.totalSet,
  });

  Map<String, dynamic> toMap() {
    return {
      'status': status.name,
      'workoutId': workoutId,
      'workoutTitle': workoutTitle,
      'remainingSeconds': remainingSeconds,
      'elapsedSeconds': elapsedSeconds,
      'phaseTitle': phaseTitle,
      'currentRound': currentRound,
      'totalRound': totalRound,
      'currentSet': currentSet,
      'totalSet': totalSet,
    };
  }

  ElandWorkoutRuntimeState copyWith({
    ElandWorkoutRuntimeStatus? status,
    String? workoutId,
    String? workoutTitle,
    int? remainingSeconds,
    int? elapsedSeconds,
    String? phaseTitle,
    int? currentRound,
    int? totalRound,
    int? currentSet,
    int? totalSet,
  }) {
    return ElandWorkoutRuntimeState(
      status: status ?? this.status,
      workoutId: workoutId ?? this.workoutId,
      workoutTitle: workoutTitle ?? this.workoutTitle,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      phaseTitle: phaseTitle ?? this.phaseTitle,
      currentRound: currentRound ?? this.currentRound,
      totalRound: totalRound ?? this.totalRound,
      currentSet: currentSet ?? this.currentSet,
      totalSet: totalSet ?? this.totalSet,
    );
  }
}

abstract class ElandWorkoutRuntime {
  static ElandWorkoutRuntime create() {
    if (Platform.isAndroid) return AndroidWorkoutRuntime();
    if (Platform.isIOS) return IosWorkoutRuntime();
    return UnsupportedWorkoutRuntime();
  }

  ElandWorkoutRuntimePlatform get platform;

  Future<void> initialize();

  Future<void> launchWorkout(
      List<WorkoutInterval> queue,
      List<WorkoutPhaseSummary> uiPhaseSummary,
      );

  Future<void> start({
    required String workoutId,
    required String workoutTitle,
  });

  Future<void> update(ElandWorkoutRuntimeState state);

  Future<void> pause();

  Future<void> resume();

  Future<void> skipPhase();

  Future<void> stop();
}

class AndroidWorkoutRuntime implements ElandWorkoutRuntime {
  @override
  ElandWorkoutRuntimePlatform get platform => ElandWorkoutRuntimePlatform.android;

  final FlutterBackgroundService _service = FlutterBackgroundService();

  @override

  Future<void> initialize() async {
    _service.on('runtimeUpdate').listen((event) {
      if (event == null) return;

      final update = WorkoutRuntimeUpdate.fromMap(event);

      // Prossimo step:
      // qui aggiorneremo Android Live Update notification.
      // Per ora validiamo solo che il payload sia tipizzato.
      update.toMap();
    });

  }

  Future<void> _ensureServiceRunning() async {
    if (!await _service.isRunning()) {
      await _service.startService();

      final readyCompleter = Completer<void>();

      final subscription = _service.on('serviceReady').listen((event) {
        if (!readyCompleter.isCompleted) {
          readyCompleter.complete();
        }
      });

      await readyCompleter.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {},
      );

      await subscription.cancel();
    }
  }

  @override
  Future<void> launchWorkout(
      List<WorkoutInterval> queue,
      List<WorkoutPhaseSummary> uiPhaseSummary,
      ) async {
    await _ensureServiceRunning();

    final jsonQueue = queue.map((interval) => interval.toJson()).toList();

    final jsonUiPhaseList =
    uiPhaseSummary.map((phase) => phase.toJson()).toList();

    _service.invoke('startFullWorkout', {
      'queue': jsonQueue,
      'uiPhaseList': jsonUiPhaseList,
    });
  }

  @override
  Future<void> start({
    required String workoutId,
    required String workoutTitle,
  }) async {
    _service.invoke('runtimeStart', {
      'workoutId': workoutId,
      'workoutTitle': workoutTitle,
    });
  }

  @override
  Future<void> update(ElandWorkoutRuntimeState state) async {
    _service.invoke('runtimeUpdate', state.toMap());
  }

  @override
  Future<void> pause() async {
    _service.invoke('pause');
  }

  @override
  Future<void> resume() async {
    _service.invoke('resume');
  }

  @override
  Future<void> skipPhase() async {
    _service.invoke('skipPhase');
  }

  @override
  Future<void> stop() async {
    _service.invoke('stop');
  }
}

class IosWorkoutRuntime implements ElandWorkoutRuntime {
  final FlutterBackgroundService _service = FlutterBackgroundService();

  Future<void> _ensureServiceRunning() async {
    if (!await _service.isRunning()) {
      await _service.startService();

      final readyCompleter = Completer<void>();

      final subscription = _service.on('serviceReady').listen((event) {
        if (!readyCompleter.isCompleted) {
          readyCompleter.complete();
        }
      });

      await readyCompleter.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {},
      );

      await subscription.cancel();
    }
  }

  static const MethodChannel _channel = MethodChannel(
    'eland_athletic/workout_runtime',
  );

  @override
  ElandWorkoutRuntimePlatform get platform => ElandWorkoutRuntimePlatform.ios;

  @override
  Future<void> initialize() async {
    await _channel.invokeMethod('initialize');
    _service.on('runtimeUpdate').listen((event) {
      if (event == null) return;

      final update = WorkoutRuntimeUpdate.fromMap(event);
      _channel.invokeMethod('update', update.toMap());
    });
  }

  @override
  Future<void> launchWorkout(
      List<WorkoutInterval> queue,
      List<WorkoutPhaseSummary> uiPhaseSummary,
      ) async {
    if (queue.isEmpty) return;

    final first = queue.first;

    await start(
      workoutId: first.workoutId ?? '',
      workoutTitle: first.workoutTitle ?? '',
    );

    await _ensureServiceRunning();

    final jsonQueue = queue.map((interval) => interval.toJson()).toList();

    final jsonUiPhaseList =
    uiPhaseSummary.map((phase) => phase.toJson()).toList();

    _service.invoke('startFullWorkout', {
      'queue': jsonQueue,
      'uiPhaseList': jsonUiPhaseList,
    });
  }

  @override
  Future<void> start({
    required String workoutId,
    required String workoutTitle,
  }) async {
    await _channel.invokeMethod('start', {
      'workoutId': workoutId,
      'workoutTitle': workoutTitle,
    });
  }

  @override
  Future<void> update(ElandWorkoutRuntimeState state) async {
    await _channel.invokeMethod('update', state.toMap());
  }

  @override
  Future<void> pause() async {
    _service.invoke('pause');
    await _channel.invokeMethod('pause');
  }

  @override
  Future<void> resume() async {
    _service.invoke('resume');
    await _channel.invokeMethod('resume');
  }

  @override
  Future<void> skipPhase() async {
    _service.invoke('skipPhase');
    await _channel.invokeMethod('skipPhase');
  }

  @override
  Future<void> stop() async {
    _service.invoke('stop');
    await _channel.invokeMethod('stop');
  }
}

class UnsupportedWorkoutRuntime implements ElandWorkoutRuntime {
  @override
  ElandWorkoutRuntimePlatform get platform => ElandWorkoutRuntimePlatform.unsupported;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> launchWorkout(
      List<WorkoutInterval> queue,
      List<WorkoutPhaseSummary> uiPhaseSummary,
      ) async {}

  @override
  Future<void> start({
    required String workoutId,
    required String workoutTitle,
  }) async {}

  @override
  Future<void> update(ElandWorkoutRuntimeState state) async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> resume() async {}

  @override
  Future<void> skipPhase() async {}

  @override
  Future<void> stop() async {}
}