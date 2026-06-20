import 'package:flutter_background_service/flutter_background_service.dart';
import 'model/workout_interval.dart';

class WorkoutController {
  // Pattern Singleton per accedere facilmente dal resto dell'app
  WorkoutController._privateConstructor();
  static final WorkoutController instance = WorkoutController._privateConstructor();

  final FlutterBackgroundService _service = FlutterBackgroundService();

  /// Avvia l'allenamento inviando la coda al servizio in background.
  /// Il controller è agnostico: riceve una lista e la invia.
  Future<void> launchWorkout(List<WorkoutInterval> queue) async {
    // 1. Verifichiamo se il servizio è attivo, altrimenti lo avviamo
    if (!await _service.isRunning()) {
      await _service.startService();
    }

    // 2. Prepariamo i dati: trasformiamo la lista di oggetti in una lista di JSON
    final List<Map<String, dynamic>> jsonQueue = queue.map((interval) => interval.toJson()).toList();

    // 3. Inviamo il comando al servizio
    _service.invoke('startFullWorkout', {'queue': jsonQueue});
  }

  /// Comando per mettere in pausa l'allenamento
  void pauseWorkout() {
    _service.invoke('pause');
  }

  /// Comando per riprendere l'allenamento
  void resumeWorkout() {
    _service.invoke('resume');
  }

  /// Comando per terminare l'allenamento
  void stopWorkout() {
    _service.invoke('stop');
  }

  /// Richiede al servizio lo stato attuale (usato per risincronizzare la UI)
  void requestStatus() {
    _service.invoke('requestStatus');
  }
}