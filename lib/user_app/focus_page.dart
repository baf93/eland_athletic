import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                      HapticFeedback.lightImpact();
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

            // --- CARD: Quick Timers ---
            ElandCard(
              title: ElandStrings.of('card_timer_title'),
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TimerListPage()),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 1,
                    margin: const EdgeInsets.only(bottom: 16),
                    color: Theme.of(context).dividerColor,
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "TABATA • EMOM • AMRAP • FOR TIME",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.0,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),

                      Icon(
                        Icons.arrow_forward_ios,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),


            const SizedBox(height: 12),

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

            // --- CARD: NUTRITION (Next Meal) --- TODO: Implementare la card

            ElandCard(
              title: ElandStrings.of('card_nutrition_title'),
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
           /* ElandCard(
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
            ),*/

          ],
        ),
      ),
    );
  }
}

// Helper per i tag (mettilo fuori dal metodo build o come funzione privata)
Widget _buildTag(String text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.white.withAlpha(50)), // O colore neutro
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      text,
      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1),
    ),
  );
}