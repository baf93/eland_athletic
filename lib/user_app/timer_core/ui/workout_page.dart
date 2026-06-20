import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import '../workout_controller.dart';
import '../model/timer_state.dart'; // Assicurati di importare i tuoi modelli

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  // Stati locali per la UI
  String _title = "Preparazione...";
  String _timeRemaining = "00:00";
  double _progress = 0.0;
  bool _isLastInterval = false;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();

    debugPrint("*** QUI");

    // Ascolta gli aggiornamenti dal background service
    FlutterBackgroundService().on('update').listen((event) {
      debugPrint("****** HERE");
      if (!mounted || event == null) return;

      setState(() {
        _title = event['title'] ?? _title;
        _timeRemaining = _formatTime(event['remainingSeconds'] ?? 0);
        _progress = (event['intervalProgress'] as num?)?.toDouble() ?? 0.0;
        _isLastInterval = event['isLastInterval'] ?? false;

        // Se il servizio invia 'completed', chiudiamo la pagina
        if (event['status'] == 'completed') {
          Navigator.of(context).pop();
        }
      });
    });

    WorkoutController.instance.requestStatus();
  }

  String _formatTime(int s) {
    final absS = s.abs();
    return '${(absS ~/ 60).toString().padLeft(2, '0')}:${(absS % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // Sfondo che garantisce visibilità (dark mode o light mode gestita dal tema)
      backgroundColor: colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Titolo FASE
              Text(
                _title.toUpperCase(),
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 50),

              // Cerchio di progresso e timer centrale
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 280,
                    height: 280,
                    child: CircularProgressIndicator(
                      value: _progress,
                      strokeWidth: 10,
                      color: colorScheme.primary, // Colore principale del tema
                      backgroundColor: colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  Text(
                    _timeRemaining,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                      fontFeatures: const [FontFeature.tabularFigures()], // Timer stabile
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Indicatore "Ultimo intervallo"
              if (_isLastInterval)
                Text(
                  "ULTIMO INTERVALLO",
                  style: TextStyle(color: colorScheme.error, fontWeight: FontWeight.bold),
                ),

              const SizedBox(height: 50),

              // Controlli
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 64,
                    icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                    color: colorScheme.onSurface,
                    onPressed: () {
                      setState(() => _isPaused = !_isPaused);
                      _isPaused
                          ? WorkoutController.instance.pauseWorkout()
                          : WorkoutController.instance.resumeWorkout();
                    },
                  ),
                  const SizedBox(width: 40),
                  IconButton(
                    iconSize: 64,
                    icon: const Icon(Icons.stop),
                    color: colorScheme.error,
                    onPressed: () {
                      WorkoutController.instance.stopWorkout();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}