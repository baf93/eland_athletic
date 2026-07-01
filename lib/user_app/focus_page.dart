import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../common/eland_responsive.dart';
import '../common/strings.dart';
import '../common/widgets/eland_card.dart';
import 'timer_list_page.dart';
import 'settings_page.dart';

class FocusPage extends ConsumerWidget {
  const FocusPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final r = ElandResponsive(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: r.pageHorizontalPadding * 0.5,
          vertical: r.spacing(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.settings,
                    size: r.icon(26),
                  ),
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

            SizedBox(height: r.compactGap),

            // Branding
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'ELAND',
                style: TextStyle(
                  fontSize: r.font(54, maxScale: 1.08),
                  fontWeight: FontWeight.w900,
                  letterSpacing: 8.0,
                  color: theme.textTheme.headlineLarge?.color,
                ),
              ),
            ),

            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'ATHLETIC',
                style: TextStyle(
                  fontSize: r.font(18, maxScale: 1.08),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 5.0,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),

            SizedBox(height: r.spacing(12)),

            Text(
              ElandStrings.of('app_motto'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: r.font(14),
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
                letterSpacing: 0.2,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),

            SizedBox(height: r.spacing(32)),

            // --- CARD: Quick Timers ---
            ElandCard(
              title: ElandStrings.of('card_timer_title'),
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TimerListPage(),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 1,
                    margin: EdgeInsets.only(bottom: r.spacing(16)),
                    color: theme.dividerColor,
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "TABATA • EMOM • AMRAP • FOR TIME",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: r.font(12),
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.0,
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ),

                      SizedBox(width: r.spacing(12)),

                      Icon(
                        Icons.arrow_forward_ios,
                        size: r.icon(20),
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: r.cardGap),

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
                  fontSize: r.font(13),
                  fontStyle: FontStyle.italic,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
            ),

            SizedBox(height: r.cardGap),

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
                  fontSize: r.font(13),
                  fontStyle: FontStyle.italic,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
            ),

            /*
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
            */
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
      border: Border.all(color: Colors.white.withAlpha(50)),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 1,
      ),
    ),
  );
}