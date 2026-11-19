package com.eland.live_update;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

/** Receives taps on the Live Update action buttons and relays them to Dart. */
public class LiveUpdateActionReceiver extends BroadcastReceiver {
  static final String ACTION = "com.eland.live_update.ACTION";
  static final String EXTRA_ACTION_ID = "actionId";

  @Override
  public void onReceive(Context context, Intent intent) {
    if (!ACTION.equals(intent.getAction())) return;
    String actionId = intent.getStringExtra(EXTRA_ACTION_ID);
    if (actionId != null) {
      ElandLiveUpdatePlugin.dispatchAction(actionId);
    }
  }
}
