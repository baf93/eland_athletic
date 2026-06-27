import 'package:flutter_background_service/flutter_background_service.dart';
import 'dart:async';

class StopwatchController {
  StopwatchController._privateConstructor();

  static final StopwatchController instance = StopwatchController._privateConstructor();

  final FlutterBackgroundService _service = FlutterBackgroundService();

  Future<void> launchStopwatch() async {
    if (!await _service.isRunning()) {
      print(" [+] Starting new service");
      await _service.startService();
      // Wait for the service to be running before sending data
      final Completer<void> readyCompleter = Completer<void>();

      final subscription = _service.on('serviceReady').listen((event) {
        if (!readyCompleter.isCompleted) {
          readyCompleter.complete();
        }
      });

      await readyCompleter.future.timeout(
        const Duration(seconds: 3),
        onTimeout: () => print(" [!] Service Start: Timeout waiting for service to be ready."),
      );
      await subscription.cancel();
    }

    _service.invoke('startStopWatch');
  }

  void pauseStopWatch(){
    _service.invoke('pause');
  }

  void resumeStopWatch(){
    _service.invoke('resume');
  }

  void stopStopWatch(){
    _service.invoke('stop');
  }

  void requestStatus(){
    _service.invoke('requestStatus');
  }

  void recordLap(){
    _service.invoke('recordLap');
  }

  void resetStopWatch(){
    _service.invoke('resetStopWatch');
  }
}

