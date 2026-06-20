import 'model/timer_enums.dart';

class AssetRegistry {
  // Ritorna il file di default se non c'è un override
  static String getAudioPath(AudioTriggerType type) {
    switch (type) {
      case AudioTriggerType.go: return 'start_beep';
      case AudioTriggerType.half: return 'halfway_tone';
      case AudioTriggerType.tenSeconds: return 'ten_sec_alert';
      case AudioTriggerType.countdown321: return 'countdown_tick';
      case AudioTriggerType.nextStage: return 'round_end';
      default: return 'none';
    }
  }
}