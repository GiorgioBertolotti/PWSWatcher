package com.zem.widgettest;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.SystemClock;
import android.util.Log;
import android.widget.RemoteViews;

import com.zem.widgettest.model.Source;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

import static com.zem.widgettest.WidgetConfigurationActivity.SHARED_PREFERENCES_NAME;

public class Widget extends AppWidgetProvider {
    private List<Integer> services = new ArrayList<>();

    @Override
    public void onUpdate(Context context, AppWidgetManager widgetManager, int[] appWidgetIds) {
        for (int id : appWidgetIds) {
            if (!services.contains(id)) {
                services.add(id);
                SharedPreferences sharedPrefs = context.getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE);
                String sourceJSON = sharedPrefs.getString("widget_" + id, null);
                if (sourceJSON != null) {
                    Source source = null;
                    try {
                        JSONObject obj = new JSONObject(sourceJSON);
                        source = new Source(obj.getInt("id"), obj.getString("name"), obj.getString("url"));
                    } catch (JSONException ignored) {
                    }
                    if (source != null) {
                        final AlarmManager manager = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
                        final Intent i = new Intent(context, WidgetUpdateService.class);
                        try {
                            i.putExtra("SOURCE", source.toJSON());
                            i.putExtra("ID", id);
                        } catch (JSONException e) {
                        }
                        PendingIntent service = PendingIntent.getService(context, 0, i, PendingIntent.FLAG_CANCEL_CURRENT);
                        int refreshRate = sharedPrefs.getInt("flutter.widget_refresh_interval", 1);
                        manager.setRepeating(AlarmManager.ELAPSED_REALTIME, SystemClock.elapsedRealtime(), refreshRate * 60000, service);
                        WidgetUpdateService.DataElaborator dataElaborator = new WidgetUpdateService.DataElaborator(context, source, id);
                        dataElaborator.execute();
                        RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.widget);
                        widgetManager.updateAppWidget(id, views);
                        Log.d("PWSWatcher", "Started Widget #" + id);
                    }
                }
            }
        }
    }

    @Override
    public void onDeleted(Context context, int[] appWidgetIds) {
        SharedPreferences sharedPrefs = context.getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPrefs.edit();
        for (int id : appWidgetIds) {
            editor.remove("widget_" + id);
            if (services.contains(id))
                services.remove(id);
            Log.d("PWSWatcher", "Deleted Widget #" + id);
        }
        editor.apply();
    }
}
