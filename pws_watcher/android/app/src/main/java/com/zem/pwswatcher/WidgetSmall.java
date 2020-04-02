package com.zem.pwswatcher;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.Context;
import android.content.Intent;
import android.content.ComponentName;
import android.content.SharedPreferences;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.SystemClock;
import android.util.Log;
import android.widget.RemoteViews;

import org.json.JSONException;
import org.json.JSONObject;
import org.xmlpull.v1.XmlPullParser;
import org.xmlpull.v1.XmlPullParserFactory;

import java.math.BigDecimal;
import java.io.StringReader;
import java.util.Arrays;

import okhttp3.Call;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;

import com.zem.pwswatcher.model.Source;
import static com.zem.pwswatcher.WidgetSmallConfigurationActivity.SHARED_PREFERENCES_NAME;

public class WidgetSmall extends AppWidgetProvider {
    static final String UPDATE_FILTER = "com.zem.pwswatcher.UPDATE";
    private static final String onRefreshClick = "REFRESH_SMALL_TAG";
    static String prefTempUnit = "°C";
    private float fontSizeMultiplier = 1.0f;
    private int bgColor = android.graphics.Color.parseColor("#03A9F4");
    private int textColor = android.graphics.Color.parseColor("#FFFFFF");

    @Override
    public void onReceive(Context context, Intent intent) {
        if (intent.getAction() == null)
            return;
        AppWidgetManager widgetManager = AppWidgetManager.getInstance(context);
        ComponentName widgetComponent = new ComponentName(context.getPackageName(), this.getClass().getName());
        int[] widgetId = widgetManager.getAppWidgetIds(widgetComponent);
        int widgetNum = widgetId.length;
        if (intent.getAction().equals(AppWidgetManager.ACTION_APPWIDGET_UPDATE)) {
            SharedPreferences sharedPrefs = context.getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE);
            Intent updateIntent = new Intent(context, WidgetSmall.class);
            updateIntent.setAction(UPDATE_FILTER);
            PendingIntent pendingUpdateIntent = PendingIntent.getBroadcast(context, 0, updateIntent, 0);
            AlarmManager alarmManager = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
            long refreshRate = sharedPrefs.getLong("flutter.widget_refresh_interval", 15);
            alarmManager.setRepeating(AlarmManager.ELAPSED_REALTIME, SystemClock.elapsedRealtime(), refreshRate * 60000, pendingUpdateIntent);
        } else if (intent.getAction().equals(UPDATE_FILTER)) {
            SharedPreferences sharedPrefs = context.getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE);
            for (int i = 0; i < widgetNum; i++) {
                String sourceJSON = sharedPrefs.getString("widget_" + widgetId[i], null);
                WidgetSmall.prefTempUnit= sharedPrefs.getString("flutter.prefTempUnit", "°C");
                if (sourceJSON != null) {
                    Source source = null;
                    try {
                        JSONObject rootObj = new JSONObject(sourceJSON);
                        JSONObject sourceObj = rootObj.getJSONObject("source");
                        source = new Source(sourceObj.getInt("id"), sourceObj.getString("name"), sourceObj.getString("url"));
                        this.fontSizeMultiplier = BigDecimal.valueOf(rootObj.getDouble("fontSizeMultiplier")).floatValue();
                        this.bgColor = rootObj.getInt("bgColor");
                        this.textColor = rootObj.getInt("textColor");
                    } catch (JSONException ignored) {
                        ignored.printStackTrace();
                    }
                    if (source != null) {
                        if (source.getUrl().endsWith(".txt") || source.getUrl().endsWith(".xml") || source.getUrl().endsWith(".csv")) {
                            DataElaborator dataElaborator = new DataElaborator(context, source, widgetId[i], this.fontSizeMultiplier, this.bgColor, this.textColor);
                            dataElaborator.execute();
                        } else {
                            String originalSource = source.getUrl();
                            source.setUrl(originalSource + "/realtime.txt");
                            DataElaborator dataElaborator = new DataElaborator(context, source, widgetId[i], this.fontSizeMultiplier, this.bgColor, this.textColor);
                            dataElaborator.execute();
                            source.setUrl(originalSource + "/realtime.xml");
                            dataElaborator = new DataElaborator(context, source, widgetId[i], this.fontSizeMultiplier, this.bgColor, this.textColor);
                            dataElaborator.execute();
                            source.setUrl(originalSource + "/daily.csv");
                            dataElaborator = new DataElaborator(context, source, widgetId[i], this.fontSizeMultiplier, this.bgColor, this.textColor);
                            dataElaborator.execute();
                        }
                    }
                }
            }
        } else if (intent.getAction().equals(AppWidgetManager.ACTION_APPWIDGET_DISABLED)) {
            Intent updateIntent = new Intent(context, WidgetSmall.class);
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
        } else if (intent.getAction().equals(onRefreshClick)) {
            SharedPreferences sharedPrefs = context.getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE);
            for (int i = 0; i < widgetNum; i++) {
                String sourceJSON = sharedPrefs.getString("widget_" + widgetId[i], null);
                WidgetSmall.prefTempUnit= sharedPrefs.getString("flutter.prefTempUnit", "°C");
                if (sourceJSON != null) {
                    Source source = null;
                    try {
                        JSONObject rootObj = new JSONObject(sourceJSON);
                        JSONObject sourceObj = rootObj.getJSONObject("source");
                        source = new Source(sourceObj.getInt("id"), sourceObj.getString("name"), sourceObj.getString("url"));
                        this.fontSizeMultiplier = BigDecimal.valueOf(rootObj.getDouble("fontSizeMultiplier")).floatValue();
                        this.bgColor = rootObj.getInt("bgColor");
                        this.textColor = rootObj.getInt("textColor");
                    } catch (JSONException ignored) {
                        ignored.printStackTrace();
                    }
                    if (source != null) {
                        if (source.getUrl().endsWith(".txt") || source.getUrl().endsWith(".xml") || source.getUrl().endsWith(".csv")) {
                            DataElaborator dataElaborator = new DataElaborator(context, source, widgetId[i], this.fontSizeMultiplier, this.bgColor, this.textColor);
                            dataElaborator.execute();
                        } else {
                            String originalSource = source.getUrl();
                            source.setUrl(originalSource + "/realtime.txt");
                            DataElaborator dataElaborator = new DataElaborator(context, source, widgetId[i], this.fontSizeMultiplier, this.bgColor, this.textColor);
                            dataElaborator.execute();
                            source.setUrl(originalSource + "/realtime.xml");
                            dataElaborator = new DataElaborator(context, source, widgetId[i], this.fontSizeMultiplier, this.bgColor, this.textColor);
                            dataElaborator.execute();
                            source.setUrl(originalSource + "/daily.csv");
                            dataElaborator = new DataElaborator(context, source, widgetId[i], this.fontSizeMultiplier, this.bgColor, this.textColor);
                            dataElaborator.execute();
                        }
                    }
                }
            }
        }
    }

    public static class DataElaborator extends AsyncTask<String, Void, String> {
        private Context context;
        private Source source;
        private int id;
        private float fontSizeMultiplier;
        private int bgColor;
        private int textColor;

        public DataElaborator(Context context, Source source, int id, float fontSizeMultiplier, int bgColor, int textColor) {
            this.context = context;
            this.source = source;
            this.id = id;
            this.fontSizeMultiplier = fontSizeMultiplier;
            this.bgColor = bgColor;
            this.textColor = textColor;
        }

        @Override
        protected String doInBackground(String... params) {
            try {
                OkHttpClient client = new OkHttpClient.Builder().build();
                if(!this.source.getUrl().startsWith("http://") && !this.source.getUrl().startsWith("https://")) {
                    Request request = new Request.Builder()
                            .url("http://" + this.source.getUrl())
                            .build();
                    Call call = client.newCall(request);
                    Response response = call.execute();
                    if(response.code() == 200)
                        return response.body().string();
                    else {
                        request = new Request.Builder()
                                .url("https://" + this.source.getUrl())
                                .build();
                        call = client.newCall(request);
                        response = call.execute();
                        if(response.code() == 200)
                            return response.body().string();
                        else {
                            return null;
                        }
                    }
                } else {
                    Request request = new Request.Builder()
                            .url(this.source.getUrl())
                            .build();
                    Call call = client.newCall(request);
                    Response response = call.execute();
                    if(response.code() == 200)
                        return response.body().string();
                    else
                        return null;
                }
            } catch (Exception e) {
                e.printStackTrace();
                return null;
            }
        }

        @Override
        protected void onPostExecute(String resp) {
            if (resp == null)
                return;
            RemoteViews view = new RemoteViews(context.getPackageName(), R.layout.widget_small);
            boolean done = false;
            try {
                if (this.source.getUrl().endsWith("clientraw.txt")) {
                    done = visualizeClientRawTXT(resp, view);
                } else if (this.source.getUrl().endsWith(".txt")) {
                    done = visualizeRealtimeTXT(resp, view);
                } else if (this.source.getUrl().endsWith(".xml")) {
                    done = visualizeRealtimeXML(resp, view);
                } else if (this.source.getUrl().endsWith(".csv")) {
                    done = visualizeDailyCSV(resp, view);
                }
                setFontSizes(view);
                setColors(view);
                setOnClickListeners(view);
            } catch (Exception e) {
                e.printStackTrace();
            }
            if (done) {
                AppWidgetManager manager = AppWidgetManager.getInstance(context);
                manager.updateAppWidget(this.id, view);
            }
        }

        private boolean visualizeDailyCSV(String resp, RemoteViews view) {
            try {
                String[] lines = resp.split("\r\n");
                String[] units = lines[2].split(",");
                String[] values = lines[lines.length - 1].split(",");
                view.setTextViewText(R.id.tv_location, this.source.getName());
                view.setTextViewText(R.id.tv_temperature, convertTemperature(Double.parseDouble(values[7]), units[7], WidgetSmall.prefTempUnit) + WidgetSmall.prefTempUnit);
                return true;
            } catch (Exception ignored) {
            }
            return false;
        }

        private boolean visualizeClientRawTXT(String resp, RemoteViews view) {
            try {
                String[] values = resp.split(" ");
                view.setTextViewText(R.id.tv_location, this.source.getName());
                view.setTextViewText(R.id.tv_temperature, convertTemperature(Double.parseDouble(values[4]), "°C", WidgetSmall.prefTempUnit) + WidgetSmall.prefTempUnit);
                return true;
            } catch (Exception ignored) {
            }
            return false;
        }

        private boolean visualizeRealtimeTXT(String resp, RemoteViews view) {
            try {
                String[] values = resp.split(" ");
                view.setTextViewText(R.id.tv_location, this.source.getName());
                view.setTextViewText(R.id.tv_temperature, values[2] + (values[14].contains("°") ? "" : "°") + values[14]);
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
                String location = null, temp = null, tempunit = null, hum = null,
                    press = null, pressunit = null, rain = null, rainunit = null, wind = null, windunit = null;
                String[] attributes = {"misc", "realtime", "today", "yesterday", "record", "units"};
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
                                        } else if (parser.getAttributeValue(i).equals("hum")) {
                                            hum = parser.nextText();
                                        } else if (parser.getAttributeValue(i).equals("press") || parser.getAttributeValue(i).equals("barometer")) {
                                            press = parser.nextText();
                                        } else if (parser.getAttributeValue(i).equals("barunit")) {
                                            pressunit = parser.nextText();
                                        } else if (parser.getAttributeValue(i).equals("todaysrain") || parser.getAttributeValue(i).equals("today_rainfall")) {
                                            rain = parser.nextText();
                                        } else if (parser.getAttributeValue(i).equals("rainunit")) {
                                            rainunit = parser.nextText();
                                        } else if (parser.getAttributeValue(i).equals("windspeed") || parser.getAttributeValue(i).equals("avg_windspeed")) {
                                            wind = parser.nextText();
                                        } else if (parser.getAttributeValue(i).equals("windunit")) {
                                            windunit = parser.nextText();
                                        } else if (parser.getAttributeValue(i).equals("location")) {
                                            location = parser.nextText();
                                        }
                                    }
                                }
                            }
                            break;
                    }
                    eventType = parser.next();
                }
                view.setTextViewText(R.id.tv_location, (location != null) ? location : this.source.getName());
                view.setTextViewText(R.id.tv_temperature, ((temp != null) ? temp : "") + ((tempunit != null) ? (tempunit.contains("°") ? tempunit : "°" + tempunit) : ""));
                return true;
            } catch (Exception e) {
                e.printStackTrace();
            }
            return false;
        }

        private void setFontSizes(RemoteViews view) {
            view.setFloat(R.id.tv_location, "setTextSize", 18f * this.fontSizeMultiplier);
            view.setFloat(R.id.tv_temperature, "setTextSize", 24f * this.fontSizeMultiplier);
        }

        private void setColors(RemoteViews view) {
            view.setInt(R.id.rl_widget_container, "setBackgroundColor", this.bgColor);
            view.setInt(R.id.tv_location, "setTextColor", this.textColor);
            view.setInt(R.id.tv_temperature, "setTextColor", this.textColor);
            view.setInt(R.id.ib_setting, "setColorFilter", this.textColor);
            view.setInt(R.id.ib_refresh, "setColorFilter", this.textColor);
        }

        private void setOnClickListeners(RemoteViews view) {
            Intent configurationIntent = new Intent(context, WidgetSmallConfigurationActivity.class);
            configurationIntent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, this.id);
            configurationIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            configurationIntent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
            configurationIntent.setData(Uri.parse(configurationIntent.toUri(Intent.URI_INTENT_SCHEME)));
            PendingIntent configurationPendingIntent = PendingIntent.getActivity(context, 0, configurationIntent, PendingIntent.FLAG_UPDATE_CURRENT);
            view.setOnClickPendingIntent(R.id.ib_setting, configurationPendingIntent);
            view.setOnClickPendingIntent(R.id.ib_refresh, getPendingSelfIntent(context, onRefreshClick));
            Intent openAppIntent = new Intent(context, MainActivity.class);
            PendingIntent openAppPendingIntent = PendingIntent.getActivity(context, 0, openAppIntent, 0);
            view.setOnClickPendingIntent(R.id.rl_widget_container, openAppPendingIntent);
        }

        protected PendingIntent getPendingSelfIntent(Context context, String action) {
            Intent intent = new Intent(context, WidgetSmall.class);
            intent.setAction(action);
            return PendingIntent.getBroadcast(context, 0, intent, 0);
        }

        private double convertTemperature(double value, String unit, String preferred) {
            double toReturn = 0.0;
            String newUnit = unit.trim().replaceAll("/", "").replaceAll("°", "").toLowerCase();
            String newPref = preferred.trim().replaceAll("/", "").replaceAll("°", "").toLowerCase();
            if (newUnit.charAt(newUnit.length() - 1) != newPref.charAt(newPref.length() - 1)) {
                if (newUnit.charAt(newUnit.length() - 1) == 'f') {
                    toReturn = roundTo2Decimal(fToC(value));
                } else {
                    toReturn = roundTo2Decimal(cToF(value));
                }
            } else {
                toReturn = value;
            }
            return toReturn;
        }

        double roundTo2Decimal(double value) {
            return (double) Math.round(value * 100d) / 100d;
        }

        double fToC(double f) {
            return (f - 32) * 5 / 9;
        }

        double cToF(double c) {
            return (c * 9 / 5) + 32;
        }
    }
}
