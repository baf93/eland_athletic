package com.eland.live_update;

import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.Icon;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;

import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.CopyOnWriteArraySet;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

/**
 * Posts the timer notification as an Android 16 "Live Update" (promoted
 * ongoing notification with ProgressStyle). The plugin is attached to every
 * Flutter engine in the process (UI and background service); action taps are
 * broadcast to all of them and handled by whichever registered a handler.
 */
public class ElandLiveUpdatePlugin implements FlutterPlugin, MethodChannel.MethodCallHandler {
  static final String CHANNEL = "eland_live_update";
  // Same contract as flutter_local_notifications, so a tap on the
  // notification is routed through its onDidReceiveNotificationResponse.
  private static final String FLN_SELECT_NOTIFICATION = "SELECT_NOTIFICATION";
  private static final String FLN_PAYLOAD = "payload";
  private static final String FLN_NOTIFICATION_ID = "notificationId";
  // Notification.EXTRA_REQUEST_PROMOTED_ONGOING (public from API 36.1).
  private static final String EXTRA_REQUEST_PROMOTED_ONGOING = "android.requestPromotedOngoing";

  private static final Set<ElandLiveUpdatePlugin> instances = new CopyOnWriteArraySet<>();

  private MethodChannel channel;
  private Context context;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    context = binding.getApplicationContext();
    channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL);
    channel.setMethodCallHandler(this);
    instances.add(this);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    instances.remove(this);
    channel.setMethodCallHandler(null);
    channel = null;
  }

  static void dispatchAction(String actionId) {
    new Handler(Looper.getMainLooper()).post(() -> {
      for (ElandLiveUpdatePlugin plugin : instances) {
        if (plugin.channel != null) {
          plugin.channel.invokeMethod("onAction", actionId);
        }
      }
    });
  }

  private static boolean isSupported() {
    return Build.VERSION.SDK_INT >= 36;
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    switch (call.method) {
      case "isSupported":
        result.success(isSupported());
        break;
      case "canPostPromoted":
        if (!isSupported()) {
          result.success(false);
        } else {
          NotificationManager nm = context.getSystemService(NotificationManager.class);
          result.success(nm.canPostPromotedNotifications());
        }
        break;
      case "show":
        if (!isSupported()) {
          result.error("unsupported", "Live Updates need Android 16", null);
          return;
        }
        try {
          show(call);
          result.success(null);
        } catch (Exception e) {
          result.error("show_failed", e.getMessage(), null);
        }
        break;
      default:
        result.notImplemented();
    }
  }

  private int drawable(String name) {
    return context.getResources().getIdentifier(name, "drawable", context.getPackageName());
  }

  @SuppressWarnings("unchecked")
  private void show(MethodCall call) {
    final int id = call.argument("id");
    final String channelId = call.argument("channelId");
    final String title = call.argument("title");
    final String body = call.argument("body");
    final String smallIcon = call.argument("smallIcon");
    final int color = ((Number) call.argument("color")).intValue();
    final String payload = call.argument("payload");
    final boolean chronometer = Boolean.TRUE.equals(call.argument("chronometer"));
    final boolean countDown = Boolean.TRUE.equals(call.argument("countDown"));
    final Number whenMs = call.argument("whenMs");
    final String shortText = call.argument("shortText");
    final List<Map<String, Object>> segments = call.argument("segments");
    final Number progress = call.argument("progress");
    final List<Map<String, Object>> actions = call.argument("actions");

    Intent launch = context.getPackageManager().getLaunchIntentForPackage(context.getPackageName());
    PendingIntent contentIntent = null;
    if (launch != null) {
      launch.setAction(FLN_SELECT_NOTIFICATION);
      launch.putExtra(FLN_NOTIFICATION_ID, id);
      launch.putExtra(FLN_PAYLOAD, payload);
      contentIntent = PendingIntent.getActivity(
          context, id, launch, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
    }

    Notification.Builder builder = new Notification.Builder(context, channelId)
        .setSmallIcon(drawable(smallIcon))
        .setContentTitle(title)
        .setContentText(body)
        .setOngoing(true)
        .setOnlyAlertOnce(true)
        .setCategory(Notification.CATEGORY_WORKOUT)
        .setVisibility(Notification.VISIBILITY_PUBLIC)
        .setColor(color)
        .setContentIntent(contentIntent);

    if (chronometer && whenMs != null) {
      builder.setWhen(whenMs.longValue())
          .setShowWhen(true)
          .setUsesChronometer(true)
          .setChronometerCountDown(countDown);
    } else {
      builder.setShowWhen(false);
    }
    if (shortText != null && !shortText.isEmpty()) {
      builder.setShortCriticalText(shortText);
    }

    // Without segments (stopwatch) the plain template is used: it is also
    // eligible for promotion and avoids an empty progress bar.
    if (segments != null && !segments.isEmpty()) {
      Notification.ProgressStyle style = new Notification.ProgressStyle().setStyledByProgress(true);
      for (Map<String, Object> s : segments) {
        int length = Math.max(1, ((Number) s.get("length")).intValue());
        style.addProgressSegment(
            new Notification.ProgressStyle.Segment(length).setColor(((Number) s.get("color")).intValue()));
      }
      style.setProgress(progress == null ? 0 : progress.intValue());
      builder.setStyle(style);
    }

    if (actions != null) {
      int requestCode = id * 10;
      for (Map<String, Object> a : actions) {
        String actionId = (String) a.get("id");
        Intent intent = new Intent(context, LiveUpdateActionReceiver.class)
            .setAction(LiveUpdateActionReceiver.ACTION)
            .putExtra(LiveUpdateActionReceiver.EXTRA_ACTION_ID, actionId);
        PendingIntent pi = PendingIntent.getBroadcast(
            context, ++requestCode, intent,
            PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
        builder.addAction(new Notification.Action.Builder(
            Icon.createWithResource(context, drawable((String) a.get("icon"))),
            (String) a.get("label"),
            pi).build());
      }
    }

    Bundle extras = new Bundle();
    extras.putBoolean(EXTRA_REQUEST_PROMOTED_ONGOING, true);
    builder.addExtras(extras);

    NotificationManager nm = context.getSystemService(NotificationManager.class);
    nm.notify(id, builder.build());
  }
}
