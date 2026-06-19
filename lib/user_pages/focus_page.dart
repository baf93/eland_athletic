import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../common/strings.dart';
import '../common/widgets/eland_card.dart';
import 'timer_list_page.dart';
import 'settings_page.dart';

class FocusPage extends ConsumerWidget {
  const FocusPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.settings, size: 26),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),

            const SizedBox(height: 8),

            // Branding
            Text(
              'ELAND',
              style: TextStyle(
                fontSize: 54,
                fontWeight: FontWeight.w900,
                letterSpacing: 8.0,
                color: Theme.of(context).textTheme.headlineLarge?.color,
              ),
            ),

            Text(
              'ATHLETIC',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 5.0,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              ElandStrings.of('app_motto'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
                letterSpacing: 0.2,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),

            const SizedBox(height: 32),

            // --- CARD: Focus Workout --- TODO: Implementare la card
            ElandCard(
              title: ElandStrings.of('card_focus_title'),
              onTap: () {
                // TODO: Apri dettaglio allenamento
              },
              child: Text(
                ElandStrings.of('wip_function'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),


            const SizedBox(height: 12),

            // --- CARD: Quick Timers ---
            ElandCard(
              title: ElandStrings.of('card_timer_title'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TimerListPage(),
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tabata, EMOM, AMRAP, ...',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge
                  ),

                  const SizedBox(width: 16),

                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withAlpha(65),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      size: 26,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // --- CARD: NUTRITION (Next Meal) --- TODO: Implementare la card
            ElandCard(
              title: ElandStrings.of('card_nutrition_title'),
              subtitle: 'PRANZO - 13:00',
              onTap: () {
                // Navigazione o switch sul Tab Nutrizione dedicato
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Riso basmati con pollo e avocado',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '520 kcal  •  P: 35g  •  C: 60g  •  F: 12g',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(153),
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}