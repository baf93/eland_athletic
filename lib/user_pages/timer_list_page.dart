import 'package:flutter/material.dart';

class TimerListPage extends StatelessWidget {
  const TimerListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // PopScope intercetta il tasto indietro fisico/di sistema del telefono
    return PopScope(
      canPop: true, // Permette il ritorno alla pagina precedente
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          // Il pop è avvenuto con successo tramite gesto o tasto di sistema
          return;
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          // Questo assicura che il tasto indietro dell'AppBar usi la stessa logica pulita
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded), // Icona premium in stile iOS
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'I TUOI TIMER',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 1.2,
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.timer_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Schermata Timer Pronta',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}