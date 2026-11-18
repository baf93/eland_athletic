import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// One coloured block of the Live Update progress bar.
class LiveUpdateSegment {
  final int length;
  final int color;

  const LiveUpdateSegment(this.length, this.color);

  Map<String, Object> toMap() => {'length': length, 'color': color};
}

/// A button on the Live Update notification.
class LiveUpdateAction {
  final String id;
  final String label;

  /// Drawable resource name (res/drawable) used as the button icon.
  final String icon;

  const LiveUpdateAction(this.id, this.label, this.icon);

  Map<String, Object> toMap() => {'id': id, 'label': label, 'icon': icon};
}

/// Android 16 Live Updates (promoted ongoing notifications).
///
/// On older Android versions [isSupported] is false and the caller keeps
/// using a regular notification.
class ElandLiveUpdate {
  static const MethodChannel _channel = MethodChannel('eland_live_update');

  static Future<bool> isSupported() async {
    if (kIsWeb || !Platform.isAndroid) return false;
    try {
      return await _channel.invokeMethod<bool>('isSupported') ?? false;
    } on MissingPluginException {
      return false;
    }
  }

  /// Whether the user currently allows this app to show Live Updates.
  static Future<bool> canPostPromoted() async {
    if (kIsWeb || !Platform.isAndroid) return false;
    return await _channel.invokeMethod<bool>('canPostPromoted') ?? false;
  }

  /// Receives the id of the action button tapped by the user.
  static void setActionHandler(void Function(String actionId) handler) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onAction' && call.arguments is String) {
        handler(call.arguments as String);
      }
    });
  }

  static Future<void> show({
    required int id,
    required String channelId,
    required String title,
    required String body,
    required String smallIcon,
    required int color,
    String? payload,
    bool chronometer = false,
    bool countDown = false,
    int? whenMs,
    String? shortText,
    List<LiveUpdateSegment> segments = const [],
    int progress = 0,
    List<LiveUpdateAction> actions = const [],
  }) {
    return _channel.invokeMethod('show', {
      'id': id,
      'channelId': channelId,
      'title': title,
      'body': body,
      'smallIcon': smallIcon,
      'color': color,
      'payload': payload,
      'chronometer': chronometer,
      'countDown': countDown,
      'whenMs': whenMs,
      'shortText': shortText,
      'segments': segments.map((s) => s.toMap()).toList(),
      'progress': progress,
      'actions': actions.map((a) => a.toMap()).toList(),
    });
  }
}
