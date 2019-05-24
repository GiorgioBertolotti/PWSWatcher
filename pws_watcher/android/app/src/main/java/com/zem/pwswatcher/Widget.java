package com.zem.pwswatcher;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.os.SystemClock;
import android.util.Log;
import android.util.TypedValue;
import android.widget.RemoteViews;

import com.zem.pwswatcher.model.Source;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

import static com.zem.pwswatcher.WidgetConfigurationActivity.SHARED_PREFERENCES_NAME;

public class Widget extends AppWidgetProvider {
    private List<Integer> services = new ArrayList<>();

    private void updateWidget(Context context, AppWidgetManager appWidgetManager, int appWidgetId, Bundle widgetInfo) {
        int minWidth = widgetInfo.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH);
        int width = widgetInfo.getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_WIDTH);
        int minHeight = widgetInfo.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT);
        int height = widgetInfo.getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_HEIGHT);
        int wCells = (int) ((minWidth + width) / 120);
        RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.widget);
        if (wCells > 2) {
            double prop = wCells / 3.0;
            views.setTextViewTextSize(R.id.tv_location, TypedValue.COMPLEX_UNIT_SP, (float) (14 * prop));
            views.setTextViewTextSize(R.id.tv_temperature, TypedValue.COMPLEX_UNIT_SP, (float) (18 * prop));
            views.setTextViewTextSize(R.id.tv_datetime, TypedValue.COMPLEX_UNIT_SP, (float) (14 * prop));
        } else {
            views.setTextViewTextSize(R.id.tv_location, TypedValue.COMPLEX_UNIT_SP, 14f);
            views.setTextViewTextSize(R.id.tv_temperature, TypedValue.COMPLEX_UNIT_SP, 18f);
            views.setTextViewTextSize(R.id.tv_datetime, TypedValue.COMPLEX_UNIT_SP, 14f);
        }
        appWidgetManager.updateAppWidget(appWidgetId, views);
    }

    @Override
    public void onAppWidgetOptionsChanged(Context context, AppWidgetManager appWidgetManager, int appWidgetId, Bundle widgetInfo) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, widgetInfo);
        updateWidget(context, appWidgetManager, appWidgetId, widgetInfo);
    }

    @Override
    public void onUpdate(Context context, AppWidgetManager widgetManager, int[] appWidgetIds) {
        super.onUpdate(context, widgetManager, appWidgetIds);
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
                        long refreshRate = sharedPrefs.getLong("flutter.widget_refresh_interval", 15);
                        manager.setRepeating(AlarmManager.ELAPSED_REALTIME, SystemClock.elapsedRealtime(), refreshRate * 60000, service);
                        if(source.getUrl().endsWith(".txt") || source.getUrl().endsWith(".xml")) {
                            WidgetUpdateService.DataElaborator dataElaborator = new WidgetUpdateService.DataElaborator(context, source, id);
                            dataElaborator.execute();
                        } else {
                            String originalSource = source.getUrl();
                            source.setUrl(originalSource + "/realtime.txt");
                            WidgetUpdateService.DataElaborator dataElaborator = new WidgetUpdateService.DataElaborator(context, source, id);
                            dataElaborator.execute();
                            source.setUrl(originalSource + "/realtime.xml");
                            dataElaborator = new WidgetUpdateService.DataElaborator(context, source, id);
                            dataElaborator.execute();
                        }
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
        super.onDeleted(context, appWidgetIds);
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
