import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../common/strings.dart';
import '../user_providers/settings_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          ElandStrings.of('settings_title') ?? 'IMPOSTAZIONI',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- SEZIONE: INTERFACCIA E LINGUA ---
              _buildSectionTitle(context, 'INTERFACCIA E LINGUA'),

              _buildDropdownSetting<String>(
                context: context,
                icon: Icons.language_rounded,
                title: 'Lingua',
                subtitle: 'Scegli la tua lingua preferita',
                value: settings.language,
                items: const ['IT', 'EN'],
                onChanged: (val) => settingsNotifier.updateLanguage(val!),
              ),

              _buildDropdownSetting<int>(
                context: context,
                icon: Icons.timer_outlined,
                title: 'Tempo Preparazione',
                subtitle: 'Secondi di preparazione predefiniti prima di ogni timer',
                value: settings.preparationTime,
                items: const [5, 10, 15, 20],
                onChanged: (val) => settingsNotifier.updatePreparationTime(val!),
              ),

              _buildSwitchSetting(
                context: context,
                icon: Icons.dark_mode_rounded,
                title: 'Modalità Tema',
                subtitle: 'Cambia tra modalità Scura e Chiara',
                value: settings.isDarkMode,
                onChanged: settingsNotifier.toggleDarkMode,
              ),

              _buildSwitchSetting(
                context: context,
                icon: Icons.fitness_center_rounded,
                title: 'Use metric units',
                subtitle: 'Store and display metrics in kg/cm',
                value: settings.useMetricUnits,
                onChanged: settingsNotifier.toggleMetricUnits,
              ),

              const SizedBox(height: 24),

              // --- SEZIONE: AVVISI E NOTIFICHE ---
              _buildSectionTitle(context, 'AVVISI E NOTIFICHE'),

              _buildSwitchSetting(
                context: context,
                icon: Icons.volume_up_rounded,
                title: 'Suoni e Audio',
                subtitle: 'Abilita beeps e avvisi vocali',
                value: settings.soundEnabled,
                onChanged: settingsNotifier.toggleSound,
              ),

              _buildSwitchSetting(
                context: context,
                icon: Icons.vibration_rounded,
                title: 'Feedback Aptico',
                subtitle: 'Vibra durante i countdown',
                value: settings.hapticFeedback,
                onChanged: settingsNotifier.toggleHaptic,
              ),

              _buildSwitchSetting(
                context: context,
                icon: Icons.notifications_off_rounded,
                title: 'Notifiche',
                subtitle: 'Abilita notifiche silenziose in background',
                value: settings.silentNotifications,
                onChanged: settingsNotifier.toggleSilentNotifications,
              ),

              _buildSwitchSetting(
                context: context,
                icon: Icons.phone_android_rounded,
                title: 'Mantieni schermo acceso',
                subtitle: 'Mantieni lo schermo acceso quando l\'app è in primo piano',
                value: settings.keepScreenOn,
                onChanged: settingsNotifier.toggleKeepScreenOn,
              ),

              const SizedBox(height: 16),
              _buildListTileAction(
                context: context,
                icon: Icons.verified_user_rounded,
                title: 'Permessi App',
                subtitle: 'Gestisci notifiche e ottimizzazione batteria',
                trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                onTap: () {},
              ),

              const Divider(height: 48, thickness: 1),

              // --- BRANDING INFO ---
              Center(
                child: Column(
                  children: [
                    Text(
                      'ELAND',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 6.0, color: theme.textTheme.headlineLarge?.color),
                    ),
                    Text(
                      'ATHLETIC',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 4.0, color: primaryColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'PRE-RELEASE',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: theme.textTheme.bodyMedium?.color?.withAlpha(120)),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        'Nessuna distrazione. Nessuna scusa. Solo tu e il tuo prossimo set.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontStyle: FontStyle.italic, color: theme.textTheme.bodyMedium?.color),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // --- CARD: PERCHÉ ELAND ---
              _buildInfoCard(
                context: context,
                title: 'ⓘ  PERCHÉ ELAND?',
                content: 'L\'eland è il più grande antilope al mondo, capace di incredibile resistenza e potenza esplosiva. Ho scelto questo nome perché ELAND è costruita per chi non ha bisogno di essere rumoroso per essere forte: è uno strumento minimale e robusto pensato per farti concentrare esclusivamente sulla tua resistenza e sui tuoi obiettivi.\n\nFILOSOFIA ELAND\n\nELAND è costruita sull\'efficienza. Seguo la filosofia KISS (Keep It Simple, Stupid): nessuna funzione inutile, solo ciò che serve per allenarti. I tuoi dati restano tuoi: l\'app è Privacy-oriented per design, non salva nulla su server esterni e sfrutta la trasparenza dell\'Open Source. Nessun account, nessun tracciamento, solo performance.',
              ),

              const SizedBox(height: 40),

              // --- BOTTOM CREDITS ---
              Center(
                child: Column(
                  children: [
                    Text('SVILUPPATO DA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: theme.textTheme.bodyMedium?.color?.withAlpha(180))),
                    const SizedBox(height: 8),
                    Text('BAF93', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 2.0, color: theme.textTheme.headlineLarge?.color)),
                    const SizedBox(height: 24),

                    // BOTTONE COFFEE PERSONALIZZATO
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.local_cafe_rounded),
                        label: const Text('OFFRIMI UN CAFFÈ', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0)),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              _buildListTileAction(
                context: context,
                icon: Icons.code_rounded,
                title: 'Codice Sorgente',
                subtitle: 'Visualizza il progetto su GitHub',
                onTap: () {},
              ),
              _buildListTileAction(
                context: context,
                icon: Icons.gavel_rounded,
                title: 'Licenza',
                subtitle: 'Visualizza la licenza Open Source',
                onTap: () {},
              ),

              const SizedBox(height: 24),
              _buildSectionTitle(context, 'ASSET E RISORSE'),

              _buildListTileAction(
                context: context,
                icon: Icons.link_rounded,
                title: 'La voce di ELAND (TTSMP3)',
                subtitle: '',
                onTap: () {},
              ),

              const SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'VISUALIZZA LICENZE TERZE PARTI',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: primaryColor, letterSpacing: 1.0),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // --- HELPERS DI LAYOUT ---

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.primary, letterSpacing: 1.5),
      ),
    );
  }

  Widget _buildSwitchSetting({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged, // <--- Sostituito e ripulito qui
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(160))),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildDropdownSetting<T>({required BuildContext context, required IconData icon, required String title, required String subtitle, required T value, required List<T> items, required ValueChanged<T?> onChanged}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(160))),
      trailing: DropdownButton<T>(
        value: value,
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down_rounded),
        style: TextStyle(fontWeight: FontWeight.w900, color: Theme.of(context).textTheme.headlineLarge?.color),
        items: items.map((T item) {
          return DropdownMenuItem<T>(value: item, child: Text(item.toString()));
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildListTileAction({required BuildContext context, required IconData icon, required String title, required String subtitle, Widget? trailing, required VoidCallback onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      subtitle: subtitle.isEmpty ? null : Text(subtitle, style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(160))),
      trailing: trailing ?? Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(100)),
      onTap: onTap,
    );
  }

  Widget _buildInfoCard({required BuildContext context, required String title, required String content}) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: theme.dividerColor.withAlpha(15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: theme.colorScheme.primary, letterSpacing: 1.0)),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(fontSize: 13, height: 1.4, color: theme.textTheme.bodyMedium?.color?.withAlpha(220)),
          ),
        ],
      ),
    );
  }
}