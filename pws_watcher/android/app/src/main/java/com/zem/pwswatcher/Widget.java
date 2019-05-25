package com.zem.pwswatcher;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.Context;
import android.content.Intent;
import android.content.ComponentName;
import android.content.SharedPreferences;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.SystemClock;
import android.util.Log;
import android.util.TypedValue;
import android.widget.RemoteViews;

import org.json.JSONException;
import org.xmlpull.v1.XmlPullParser;
import org.xmlpull.v1.XmlPullParserException;
import org.xmlpull.v1.XmlPullParserFactory;

import java.io.IOException;
import java.io.StringReader;
import java.util.Arrays;

import com.zem.pwswatcher.model.Source;

import org.json.JSONException;
import org.json.JSONObject;

import okhttp3.Call;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;

import java.util.ArrayList;
import java.util.List;

import static com.zem.pwswatcher.WidgetConfigurationActivity.SHARED_PREFERENCES_NAME;

import java.util.Calendar;

public class Widget extends AppWidgetProvider {
    static final String UPDATE_FILTER = "com.zem.pwswatcher.UPDATE";

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
    public void onReceive(Context context, Intent intent) {
        if (intent.getAction() == null)
            return;
        AppWidgetManager widgetManager = AppWidgetManager.getInstance(context);
        ComponentName widgetComponent = new ComponentName(context.getPackageName(), this.getClass().getName());
        int[] widgetId = widgetManager.getAppWidgetIds(widgetComponent);
        int widgetNum = widgetId.length;
        RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.widget);
        if (intent.getAction().equals(AppWidgetManager.ACTION_APPWIDGET_UPDATE)) {
            SharedPreferences sharedPrefs = context.getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE);
            Intent updateIntent = new Intent(context, Widget.class);
            updateIntent.setAction(UPDATE_FILTER);
            PendingIntent pendingUpdateIntent = PendingIntent.getBroadcast(context, 0, updateIntent, 0);
            AlarmManager alarmManager = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
            long refreshRate = sharedPrefs.getLong("flutter.widget_refresh_interval", 15);
            alarmManager.setRepeating(AlarmManager.ELAPSED_REALTIME, SystemClock.elapsedRealtime(), refreshRate * 60000, pendingUpdateIntent);
        } else if (intent.getAction().equals(UPDATE_FILTER)) {
            SharedPreferences sharedPrefs = context.getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE);
            for (int i = 0; i < widgetNum; i++) {
                String sourceJSON = sharedPrefs.getString("widget_" + widgetId[i], null);
                if (sourceJSON != null) {
                    Source source = null;
                    try {
                        JSONObject obj = new JSONObject(sourceJSON);
                        source = new Source(obj.getInt("id"), obj.getString("name"), obj.getString("url"));
                    } catch (JSONException ignored) {
                    }
                    if (source != null) {
                        if (source.getUrl().endsWith(".txt") || source.getUrl().endsWith(".xml")) {
                            DataElaborator dataElaborator = new DataElaborator(context, source, widgetId[i]);
                            dataElaborator.execute();
                        } else {
                            String originalSource = source.getUrl();
                            source.setUrl(originalSource + "/realtime.txt");
                            DataElaborator dataElaborator = new DataElaborator(context, source, widgetId[i]);
                            dataElaborator.execute();
                            source.setUrl(originalSource + "/realtime.xml");
                            dataElaborator = new DataElaborator(context, source, widgetId[i]);
                            dataElaborator.execute();
                        }
                    }
                }
            }
        } else if (intent.getAction().equals(AppWidgetManager.ACTION_APPWIDGET_DISABLED)) {
            Intent updateIntent = new Intent(context, Widget.class);
            updateIntent.setAction(UPDATE_FILTER);
            PendingIntent pendingUpdateIntent = PendingIntent.getBroadcast(context, 0, updateIntent, 0);
            AlarmManager alarmManager = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
            alarmManager.cancel(pendingUpdateIntent);
            SharedPreferences sharedPrefs = context.getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE);
            SharedPreferences.Editor editor = sharedPrefs.edit();
            for (int i = 0; i < widgetNum; i++) {
                editor.remove("widget_" + widgetId[i]);
                Log.d("PWSWatcher", "Deleted Widget #" + widgetId[i]);
            }
            editor.apply();
        } else if (intent.getAction().equals(AppWidgetManager.ACTION_APPWIDGET_OPTIONS_CHANGED)) {
            super.onReceive(context, intent);
        }
    }

    public static class DataElaborator extends AsyncTask<String, Void, String> {
        private Context context;
        private Source source;
        private int id;

        public DataElaborator(Context context, Source source, int id) {
            this.context = context;
            this.source = source;
            this.id = id;
        }

        @Override
        protected String doInBackground(String... params) {
            try {
                OkHttpClient client = new OkHttpClient.Builder().build();
                Request request = new Request.Builder()
                        .url(this.source.getUrl())
                        .build();
                Call call = client.newCall(request);
                Response response = call.execute();
                return response.body().string();
            } catch (IOException e) {
                e.printStackTrace();
                return null;
            }
        }

        @Override
        protected void onPostExecute(String resp) {
            if (resp == null)
                return;
            RemoteViews view = new RemoteViews(context.getPackageName(), R.layout.widget);
            boolean done = false;
            try {
                if (this.source.getUrl().endsWith(".txt")) {
                    done = visualizeRealtimeTXT(resp, view);
                } else if (this.source.getUrl().endsWith(".xml")) {
                    done = visualizeRealtimeXML(resp, view);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            if (done) {
                AppWidgetManager manager = AppWidgetManager.getInstance(context);
                manager.updateAppWidget(this.id, view);
            }
        }

        private boolean visualizeRealtimeTXT(String resp, RemoteViews view) {
            try {
                String[] values = resp.split(" ");
                view.setTextViewText(R.id.tv_location, this.source.getName());
                view.setTextViewText(R.id.tv_temperature, values[2] + values[14]);
                view.setTextViewText(R.id.tv_datetime, values[0] + " " + values[1]);
                return true;
            } catch (Exception ignored) {
            }
            return false;
        }

        private boolean visualizeRealtimeXML(String resp, RemoteViews view) {
            try {
                XmlPullParserFactory parserFactory;
                parserFactory = XmlPullParserFactory.newInstance();
                XmlPullParser parser = parserFactory.newPullParser();
                parser.setFeature(XmlPullParser.FEATURE_PROCESS_NAMESPACES, false);
                parser.setInput(new StringReader(resp));
                int eventType = parser.getEventType();
                String date = null, time = null, temp = null, tempunit = null;
                String[] attributes = {"misc", "realtime", "today", "yesterday", "record"};
                while (eventType != XmlPullParser.END_DOCUMENT) {
                    String eltName = null;
                    switch (eventType) {
                        case XmlPullParser.START_TAG:
                            eltName = parser.getName();
                            if ("misc".equals(eltName)) {
                                for (int i = 0; i < parser.getAttributeCount(); i++) {
                                    if (parser.getAttributeName(i).equals("data") && parser.getAttributeValue(i).equals("station_location")) {
                                        view.setTextViewText(R.id.tv_location, parser.nextText());
                                    }
                                }
                            }
                            if ("data".equals(eltName)) {
                                for (int i = 0; i < parser.getAttributeCount(); i++) {
                                    if (Arrays.asList(attributes).contains(parser.getAttributeName(i))) {
                                        if (parser.getAttributeValue(i).equals("temp")) {
                                            temp = parser.nextText();
                                        } else if (parser.getAttributeValue(i).equals("tempunit")) {
                                            tempunit = parser.nextText();
                                        } else if (parser.getAttributeValue(i).equals("station_date")) {
                                            date = parser.nextText();
                                        } else if (parser.getAttributeValue(i).equals("station_time")) {
                                            time = parser.nextText();
                                        } else if (parser.getAttributeValue(i).equals("location")) {
                                            view.setTextViewText(R.id.tv_location, parser.nextText());
                                        } else if (parser.getAttributeValue(i).equals("refresh_time")) {
                                            date = parser.nextText();
                                        }
                                    }
                                }
                            }
                            break;
                    }
                    eventType = parser.next();
                }
                view.setTextViewText(R.id.tv_temperature, ((temp != null) ? temp : "") + ((tempunit != null) ? tempunit : ""));
                view.setTextViewText(R.id.tv_datetime, ((date != null) ? date + " " : "") + ((time != null) ? time : ""));
                return true;
            } catch (Exception e) {
                e.printStackTrace();
            }
            return false;
        }
    }
}
