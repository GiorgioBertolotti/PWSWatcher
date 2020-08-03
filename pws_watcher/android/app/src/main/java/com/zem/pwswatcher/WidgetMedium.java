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
import android.os.Bundle;
import android.os.SystemClock;
import android.util.Log;
import android.util.TypedValue;
import android.view.View;
import android.widget.RemoteViews;
import android.os.Build;
import android.graphics.Color;

import org.json.JSONException;
import org.json.JSONObject;
import org.xmlpull.v1.XmlPullParser;
import org.xmlpull.v1.XmlPullParserFactory;

import java.math.BigDecimal;
import java.io.StringReader;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Date;

import okhttp3.Call;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;

import com.zem.pwswatcher.model.Source;
import static com.zem.pwswatcher.WidgetMediumConfigurationActivity.SHARED_PREFERENCES_NAME;

public class WidgetMedium extends AppWidgetProvider {
    static final String UPDATE_FILTER = "com.zem.pwswatcher.UPDATE";
    private static final String onRefreshClick = "REFRESH_TAG";
    static String prefWindUnit = "km/h";
    static String prefRainUnit = "mm";
    static String prefPressUnit = "mb";
    static String prefTempUnit = "°C";
    static String prefDewUnit = "°C";
    private float fontSizeMultiplier = 1.0f;
    private boolean humidityVisible = true;
    private boolean pressureVisible = true;
    private boolean rainVisible = true;
    private boolean windspeedVisible = true;
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
            Intent updateIntent = new Intent(context, WidgetMedium.class);
            updateIntent.setAction(UPDATE_FILTER);
            PendingIntent pendingUpdateIntent = PendingIntent.getBroadcast(context, 0, updateIntent, 0);
            AlarmManager alarmManager = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
            long refreshRate = sharedPrefs.getLong("flutter.widget_refresh_interval", 15);
            alarmManager.setRepeating(AlarmManager.ELAPSED_REALTIME, SystemClock.elapsedRealtime(), refreshRate * 60000, pendingUpdateIntent);
        } else if (intent.getAction().equals(UPDATE_FILTER)) {
            SharedPreferences sharedPrefs = context.getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE);
            for (int i = 0; i < widgetNum; i++) {
                String sourceJSON = sharedPrefs.getString("widget_" + widgetId[i], null);
                Widget.prefWindUnit = sharedPrefs.getString("flutter.prefWindUnit", "km/h");
                Widget.prefRainUnit= sharedPrefs.getString("flutter.prefRainUnit", "mm");
                Widget.prefPressUnit= sharedPrefs.getString("flutter.prefPressUnit", "mb");
                Widget.prefTempUnit= sharedPrefs.getString("flutter.prefTempUnit", "°C");
                Widget.prefDewUnit= sharedPrefs.getString("flutter.prefDewUnit", "°C");
                if (sourceJSON != null) {
                    Source source = null;
                    try {
                        JSONObject rootObj = new JSONObject(sourceJSON);
                        JSONObject sourceObj = rootObj.getJSONObject("source");
                        source = new Source(sourceObj.getInt("id"), sourceObj.getString("name"), sourceObj.getString("url"));
                        this.fontSizeMultiplier = BigDecimal.valueOf(rootObj.getDouble("fontSizeMultiplier")).floatValue();
                        this.humidityVisible = rootObj.getBoolean("humidityVisible");
                        this.pressureVisible = rootObj.getBoolean("pressureVisible");
                        this.rainVisible = rootObj.getBoolean("rainVisible");
                        this.windspeedVisible = rootObj.getBoolean("windspeedVisible");
                        this.bgColor = rootObj.getInt("bgColor");
                        this.textColor = rootObj.getInt("textColor");
                    } catch (JSONException ignored) {
                        ignored.printStackTrace();
                    }
                    if (source != null) {
                        if (source.getUrl().endsWith(".txt") || source.getUrl().endsWith(".xml") || source.getUrl().endsWith(".csv")) {
                            DataElaborator dataElaborator = new DataElaborator(context, source, widgetId[i], this.fontSizeMultiplier,
                                this.humidityVisible, this.pressureVisible, this.rainVisible, this.windspeedVisible, this.bgColor, this.textColor);
                            dataElaborator.execute();
                        } else {
                            String originalSource = source.getUrl();
                            source.setUrl(originalSource + "/realtime.txt");
                            DataElaborator dataElaborator = new DataElaborator(context, source, widgetId[i], this.fontSizeMultiplier,
                                this.humidityVisible, this.pressureVisible, this.rainVisible, this.windspeedVisible, this.bgColor, this.textColor);
                            dataElaborator.execute();
                            source.setUrl(originalSource + "/realtime.xml");
                            dataElaborator = new DataElaborator(context, source, widgetId[i], this.fontSizeMultiplier,
                                this.humidityVisible, this.pressureVisible, this.rainVisible, this.windspeedVisible, this.bgColor, this.textColor);
                            dataElaborator.execute();
                            source.setUrl(originalSource + "/daily.csv");
                            dataElaborator = new DataElaborator(context, source, widgetId[i], this.fontSizeMultiplier,
                                this.humidityVisible, this.pressureVisible, this.rainVisible, this.windspeedVisible, this.bgColor, this.textColor);
                            dataElaborator.execute();
                        }
                    }
                }
            }
        } else if (intent.getAction().equals(AppWidgetManager.ACTION_APPWIDGET_DISABLED)) {
            Intent updateIntent = new Intent(context, WidgetMedium.class);
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
                Widget.prefWindUnit = sharedPrefs.getString("flutter.prefWindUnit", "km/h");
                Widget.prefRainUnit= sharedPrefs.getString("flutter.prefRainUnit", "mm");
                Widget.prefPressUnit= sharedPrefs.getString("flutter.prefPressUnit", "mb");
                Widget.prefTempUnit= sharedPrefs.getString("flutter.prefTempUnit", "°C");
                Widget.prefDewUnit= sharedPrefs.getString("flutter.prefDewUnit", "°C");
                if (sourceJSON != null) {
                    Source source = null;
                    try {
                        JSONObject rootObj = new JSONObject(sourceJSON);
                        JSONObject sourceObj = rootObj.getJSONObject("source");
                        source = new Source(sourceObj.getInt("id"), sourceObj.getString("name"), sourceObj.getString("url"));
                        this.fontSizeMultiplier = BigDecimal.valueOf(rootObj.getDouble("fontSizeMultiplier")).floatValue();
                        this.humidityVisible = rootObj.getBoolean("humidityVisible");
                        this.pressureVisible = rootObj.getBoolean("pressureVisible");
                        this.rainVisible = rootObj.getBoolean("rainVisible");
                        this.windspeedVisible = rootObj.getBoolean("windspeedVisible");
                        this.bgColor = rootObj.getInt("bgColor");
                        this.textColor = rootObj.getInt("textColor");
                    } catch (JSONException ignored) {
                        ignored.printStackTrace();
                    }
                    if (source != null) {
                        if (source.getUrl().endsWith(".txt") || source.getUrl().endsWith(".xml") || source.getUrl().endsWith(".csv")) {
                            DataElaborator dataElaborator = new DataElaborator(context, source, widgetId[i], this.fontSizeMultiplier,
                                    this.humidityVisible, this.pressureVisible, this.rainVisible, this.windspeedVisible, this.bgColor, this.textColor);
                            dataElaborator.execute();
                        } else {
                            String originalSource = source.getUrl();
                            source.setUrl(originalSource + "/realtime.txt");
                            DataElaborator dataElaborator = new DataElaborator(context, source, widgetId[i], this.fontSizeMultiplier,
                                    this.humidityVisible, this.pressureVisible, this.rainVisible, this.windspeedVisible, this.bgColor, this.textColor);
                            dataElaborator.execute();
                            source.setUrl(originalSource + "/realtime.xml");
                            dataElaborator = new DataElaborator(context, source, widgetId[i], this.fontSizeMultiplier,
                                    this.humidityVisible, this.pressureVisible, this.rainVisible, this.windspeedVisible, this.bgColor, this.textColor);
                            dataElaborator.execute();
                            source.setUrl(originalSource + "/daily.csv");
                            dataElaborator = new DataElaborator(context, source, widgetId[i], this.fontSizeMultiplier,
                                    this.humidityVisible, this.pressureVisible, this.rainVisible, this.windspeedVisible, this.bgColor, this.textColor);
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
        private boolean humidityVisible = true;
        private boolean pressureVisible = true;
        private boolean rainVisible = true;
        private boolean windspeedVisible = true;
        private int bgColor;
        private int textColor;

        public DataElaborator(Context context, Source source, int id, float fontSizeMultiplier, boolean humidityVisible,
            boolean pressureVisible, boolean rainVisible, boolean windspeedVisible, int bgColor, int textColor) {
            this.context = context;
            this.source = source;
            this.id = id;
            this.fontSizeMultiplier = fontSizeMultiplier;
            this.humidityVisible = humidityVisible;
            this.pressureVisible = pressureVisible;
            this.rainVisible = rainVisible;
            this.windspeedVisible = windspeedVisible;
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
            RemoteViews view = new RemoteViews(context.getPackageName(), R.layout.widget_medium);
            boolean done = false;
            try {
                boolean isClientRawTxt = false;
                if (this.source.getUrl().endsWith("clientraw.txt")) {
                    done = visualizeClientRawTXT(resp, view);
                    isClientRawTxt = true;
                } else if (this.source.getUrl().endsWith(".txt")) {
                    done = visualizeRealtimeTXT(resp, view);
                } else if (this.source.getUrl().endsWith(".xml")) {
                    done = visualizeRealtimeXML(resp, view);
                } else if (this.source.getUrl().endsWith(".csv")) {
                    done = visualizeDailyCSV(resp, view);
                }
                setFontSizes(view);
                setVisibilities(view, isClientRawTxt);
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
                view.setTextViewText(R.id.tv_temperature, convertTemperature(Double.parseDouble(values[7]), units[7], Widget.prefTempUnit) + Widget.prefTempUnit);
                view.setTextViewText(R.id.tv_temperature_left, convertTemperature(Double.parseDouble(values[7]), units[7], Widget.prefTempUnit) + Widget.prefTempUnit);
                view.setTextViewText(R.id.tv_humidity, values[5] + "%");
                view.setTextViewText(R.id.tv_pressure, convertPressure(Double.parseDouble(values[8]), units[8], Widget.prefPressUnit) + Widget.prefPressUnit);
                view.setTextViewText(R.id.tv_rain, convertRain(Double.parseDouble(values[52]), units[52], Widget.prefRainUnit) + Widget.prefRainUnit);
                view.setTextViewText(R.id.tv_windspeed, convertWindSpeed(Double.parseDouble(values[2]), units[2], Widget.prefWindUnit) + Widget.prefWindUnit);
                String stringDate = null;
                try {
                    String date = lines[0] + " " + values[0];
                    date = date.trim().replace("/", "-").replace(".", "-").toUpperCase();
                    SimpleDateFormat format = new SimpleDateFormat("MM-dd-yy hh:mma");
                    Date newDate = format.parse(date);
                    stringDate = android.text.format.DateFormat.getDateFormat(context).format(newDate) + " " + android.text.format.DateFormat.getTimeFormat(context).format(newDate).replace(".000", "");
                } catch (Exception e) {
                    String date = lines[0] + " " + values[0];
                    stringDate = date.trim().replace("/", "-").replace(".", "-");
                }
                view.setTextViewText(R.id.tv_datetime, stringDate);
                return true;
            } catch (Exception ignored) {
            }
            return false;
        }

        private boolean visualizeClientRawTXT(String resp, RemoteViews view) {
            try {
                String[] values = resp.split(" ");
                view.setTextViewText(R.id.tv_location, this.source.getName());
                view.setTextViewText(R.id.tv_temperature, convertTemperature(Double.parseDouble(values[4]), "°C", Widget.prefTempUnit) + Widget.prefTempUnit);
                view.setTextViewText(R.id.tv_temperature_left, convertTemperature(Double.parseDouble(values[4]), "°C", Widget.prefTempUnit) + Widget.prefTempUnit);
                view.setTextViewText(R.id.tv_humidity, values[5] + "%");
                view.setTextViewText(R.id.tv_pressure, convertPressure(Double.parseDouble(values[6]), "hPa", Widget.prefPressUnit) + Widget.prefPressUnit);
                view.setTextViewText(R.id.tv_rain, convertRain(Double.parseDouble(values[7]), "mm", Widget.prefRainUnit) + Widget.prefRainUnit);
                view.setTextViewText(R.id.tv_windspeed, convertWindSpeed(Double.parseDouble(values[2]), "kts", Widget.prefWindUnit) + Widget.prefWindUnit);
                int currentConditionIcon = Integer.parseInt(values[48]);
                int[] currentConditionMapping = {R.drawable.sunny, R.drawable.clear_night, R.drawable.cloudy, R.drawable.cloudy, R.drawable.cloudy_night, R.drawable.sunny, R.drawable.fog, R.drawable.fog, R.drawable.heavy_rain, R.drawable.sunny, R.drawable.fog, R.drawable.fog_night, R.drawable.heavy_rain, R.drawable.cloudy_night, R.drawable.rain, R.drawable.heavy_rain, R.drawable.snow, R.drawable.storm, R.drawable.partly_cloudy, R.drawable.partly_cloudy, R.drawable.rain, R.drawable.heavy_rain, R.drawable.heavy_rain, R.drawable.snow, R.drawable.snow, R.drawable.snow, R.drawable.snow_melt, R.drawable.snow, R.drawable.sunny, R.drawable.storm, R.drawable.storm, R.drawable.storm, R.drawable.windy, R.drawable.windy, R.drawable.stopped_raining, R.drawable.rain, R.drawable.sunrise, R.drawable.sunset};
                int currentConditionAsset = currentConditionMapping[currentConditionIcon];
                view.setImageViewResource(R.id.iv_weather, currentConditionAsset);
                String stringDate = null;
                try {
                    String date = values[74] + " " + values[29]+ ":" + values[30]+ ":" + values[31];
                    date = date.trim().replace("/", "-").replace(".", "-");
                    SimpleDateFormat format = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss");
                    Date newDate = format.parse(date);
                    stringDate = android.text.format.DateFormat.getDateFormat(context).format(newDate) + " " + android.text.format.DateFormat.getTimeFormat(context).format(newDate).replace(".000", "");
                } catch (Exception e) {
                    String date = values[74] + " " + values[29]+ ":" + values[30]+ ":" + values[31];
                    stringDate = date.trim().replace("/", "-").replace(".", "-");
                }
                view.setTextViewText(R.id.tv_datetime, stringDate);
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
                view.setTextViewText(R.id.tv_temperature_left, values[2] + (values[14].contains("°") ? "" : "°") + values[14]);
                view.setTextViewText(R.id.tv_humidity, values[3] + "%");
                view.setTextViewText(R.id.tv_pressure, values[10] + " " +values[15]);
                view.setTextViewText(R.id.tv_rain, values[9] + " " + values[16]);
                view.setTextViewText(R.id.tv_windspeed, values[5] + " " + values[13]);
                String stringDate = null;
                try {
                    String date = values[0] + " " + values[1];
                    date = date.trim().replace("/", "-").replace(".", "-");
                    int year = Calendar.getInstance().get(Calendar.YEAR);
                    date = date.substring(0, 6) +
                            Integer.toString(year).substring(0, 2) +
                            date.substring(6);
                    date = date.substring(6, 10) + "-" + date.substring(3, 5) + "-" + date.substring(0, 2) + " " + date.substring(11);
                    SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                    Date newDate = format.parse(date);
                    stringDate = android.text.format.DateFormat.getDateFormat(context).format(newDate) + " " + android.text.format.DateFormat.getTimeFormat(context).format(newDate).replace(".000", "");
                } catch (Exception e) {
                    stringDate = values[0].trim() + " " + values[1].trim();
                }
                view.setTextViewText(R.id.tv_datetime, stringDate);
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
                String location = null, date = null, time = null, temp = null, tempunit = null, hum = null,
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
                                        } else if (parser.getAttributeValue(i).equals("station_date")) {
                                            date = parser.nextText();
                                        } else if (parser.getAttributeValue(i).equals("station_time")) {
                                            time = parser.nextText();
                                        } else if (parser.getAttributeValue(i).equals("location")) {
                                            location = parser.nextText();
                                        } else if (parser.getAttributeValue(i).equals("refresh_time")) {
                                            String tmpDatetime = parser.nextText();
                                            date = tmpDatetime.substring(0, 10);
                                            time = tmpDatetime.substring(12);
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
                view.setTextViewText(R.id.tv_temperature_left, ((temp != null) ? temp : "") + ((tempunit != null) ? (tempunit.contains("°") ? tempunit : "°" + tempunit) : ""));
                view.setTextViewText(R.id.tv_humidity, ((hum != null) ? (hum.contains("%") ? hum : hum + "%") : "-"));
                view.setTextViewText(R.id.tv_pressure, ((press != null) ? press : "-") + " " + ((pressunit != null) ? pressunit : ""));
                view.setTextViewText(R.id.tv_rain, ((rain != null) ? rain : "-") + " " + ((rainunit != null) ? rainunit : ""));
                view.setTextViewText(R.id.tv_windspeed, ((wind != null) ? wind : "-") + " " + ((windunit != null) ? windunit : ""));
                String stringDate = null;
                try {
                    String tmpDatetime = date.trim() + " " + time.trim();
                    tmpDatetime = tmpDatetime.trim().replace("/", "-").replace(".", "-");
                    SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                    Date newDate = format.parse(tmpDatetime);
                    stringDate = android.text.format.DateFormat.getDateFormat(context).format(newDate) + " " + android.text.format.DateFormat.getTimeFormat(context).format(newDate).replace(".000", "");
                } catch (Exception e) {
                    stringDate = ((date != null) ? (date.trim() + " ") : "") + ((time != null) ? time.trim() : "");
                }
                view.setTextViewText(R.id.tv_datetime, stringDate);
                return true;
            } catch (Exception e) {
                e.printStackTrace();
            }
            return false;
        }

        private void setFontSizes(RemoteViews view) {
            view.setFloat(R.id.tv_location, "setTextSize", 16f * this.fontSizeMultiplier);
            view.setFloat(R.id.tv_temperature, "setTextSize", 24f * this.fontSizeMultiplier);
            view.setFloat(R.id.tv_temperature_left, "setTextSize", 24f * this.fontSizeMultiplier);
            view.setFloat(R.id.tv_humidity, "setTextSize", 16f * this.fontSizeMultiplier);
            view.setFloat(R.id.tv_pressure, "setTextSize", 16f * this.fontSizeMultiplier);
            view.setFloat(R.id.tv_rain, "setTextSize", 16f * this.fontSizeMultiplier);
            view.setFloat(R.id.tv_windspeed, "setTextSize", 16f * this.fontSizeMultiplier);
            view.setFloat(R.id.tv_datetime, "setTextSize", 12f * this.fontSizeMultiplier);
        }

        private void setVisibilities(RemoteViews view, boolean isClientRawTxt) {
            if (this.humidityVisible)
                view.setViewVisibility(R.id.ll_humidity, View.VISIBLE);
            else
                view.setViewVisibility(R.id.ll_humidity, View.GONE);
            if (this.pressureVisible)
                view.setViewVisibility(R.id.ll_pressure, View.VISIBLE);
            else
                view.setViewVisibility(R.id.ll_pressure, View.GONE);
            if (this.rainVisible)
                view.setViewVisibility(R.id.ll_rain, View.VISIBLE);
            else
                view.setViewVisibility(R.id.ll_rain, View.GONE);
            if (this.windspeedVisible)
                view.setViewVisibility(R.id.ll_windspeed, View.VISIBLE);
            else
                view.setViewVisibility(R.id.ll_windspeed, View.GONE);
            if(isClientRawTxt) {
                view.setViewVisibility(R.id.tv_temperature, View.INVISIBLE);
                view.setViewVisibility(R.id.rl_temperature, View.VISIBLE);
            } else {
                view.setViewVisibility(R.id.tv_temperature, View.VISIBLE);
                view.setViewVisibility(R.id.rl_temperature, View.GONE);
            }
        }

        private void setColors(RemoteViews view) {
            view.setInt(R.id.iv_bg, "setColorFilter", this.bgColor);
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
                view.setInt(R.id.iv_bg, "setImageAlpha", Color.alpha(this.bgColor));
            } else {
                view.setInt(R.id.iv_bg, "setAlpha", Color.alpha(this.bgColor));
            }

            view.setInt(R.id.tv_location, "setTextColor", this.textColor);
            view.setInt(R.id.tv_temperature, "setTextColor", this.textColor);
            view.setInt(R.id.tv_temperature_left, "setTextColor", this.textColor);
            view.setInt(R.id.tv_humidity, "setTextColor", this.textColor);
            view.setInt(R.id.tv_pressure, "setTextColor", this.textColor);
            view.setInt(R.id.tv_rain, "setTextColor", this.textColor);
            view.setInt(R.id.tv_windspeed, "setTextColor", this.textColor);
            view.setInt(R.id.tv_datetime, "setTextColor", this.textColor);
            view.setInt(R.id.iv_humidity, "setColorFilter", this.textColor);
            view.setInt(R.id.iv_pressure, "setColorFilter", this.textColor);
            view.setInt(R.id.iv_rain, "setColorFilter", this.textColor);
            view.setInt(R.id.iv_windspeed, "setColorFilter", this.textColor);
            view.setInt(R.id.ib_setting, "setColorFilter", this.textColor);
            view.setInt(R.id.ib_refresh, "setColorFilter", this.textColor);
        }

        private void setOnClickListeners(RemoteViews view) {
            Intent configurationIntent = new Intent(context, WidgetMediumConfigurationActivity.class);
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
            Intent intent = new Intent(context, WidgetMedium.class);
            intent.setAction(action);
            return PendingIntent.getBroadcast(context, 0, intent, 0);
        }

        private double convertWindSpeed(double value, String unit, String preferred) {
            double kmh = 0.0;
            switch (unit.trim().replaceAll("/", "").toLowerCase()) {
            case "kts":
            case "kn":
                {
                kmh = ktsToKmh(value);
                break;
                }
            case "mph":
                {
                kmh = mphToKmh(value);
                break;
                }
            case "ms":
                {
                kmh = msToKmh(value);
                break;
                }
            default:
                {
                kmh = value;
                break;
                }
            }
            double toReturn = 0.0;
            switch (preferred.trim().replaceAll("/", "").toLowerCase()) {
            case "kts":
            case "kn":
                {
                toReturn = roundTo2Decimal(kmhToKts(kmh));
                break;
                }
            case "mph":
                {
                toReturn = roundTo2Decimal(kmhToMph(kmh));
                break;
                }
            case "ms":
                {
                toReturn = roundTo2Decimal(kmhToMs(kmh));
                break;
                }
            default:
                {
                toReturn = roundTo2Decimal(kmh);
                break;
                }
            }
            return toReturn;
        }

        private double convertRain(double value, String unit, String preferred) {
            double toReturn = 0.0;
            if (unit.trim().replaceAll("/", "").toLowerCase() != preferred.trim().replaceAll("/", "").toLowerCase()) {
                if (unit.trim().replaceAll("/", "").toLowerCase() == "mm") {
                    toReturn = roundTo2Decimal(mmToIn(value));
                } else {
                    toReturn = roundTo2Decimal(inToMm(value));
                }
            } else
                toReturn = value;
            return toReturn;
        }

        private double convertPressure(double value, String unit, String preferred) {
            double hPa;
            switch (unit.trim().replaceAll("/", "").toLowerCase()) {
            case "in":
            case "inhg":
                {
                hPa = inhgToHPa(value);
                break;
                }
            case "mb":
                {
                hPa = mbToHPa(value);
                break;
                }
            default:
                {
                hPa = value;
                break;
                }
            }
            double toReturn = 0.0;
            switch (preferred.trim().replaceAll("/", "").toLowerCase()) {
            case "in":
            case "inhg":
                {
                toReturn = roundTo2Decimal(hPaToInhg(hPa));
                break;
                }
            case "mb":
                {
                toReturn = roundTo2Decimal(hPaToMb(hPa));
                break;
                }
            default:
                {
                toReturn = roundTo2Decimal(hPa);
                break;
                }
            }
            return toReturn;
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

        double ktsToKmh(double kts) {
            return kts * 1.852;
        }

        double mphToKmh(double mph) {
            return mph * 1.60934;
        }

        double msToKmh(double ms) {
            return ms * 3.6;
        }

        double kmhToKts(double kmh) {
            return kmh / 1.852;
        }

        double kmhToMph(double kmh) {
            return kmh / 1.60934;
        }

        double kmhToMs(double kmh) {
            return kmh / 3.6;
        }

        double mmToIn(double mm) {
            return mm / 25.4;
        }

        double inToMm(double inc) {
            return inc * 25.4;
        }

        double inhgToHPa(double inhg) {
            return inhg * 33.86389;
        }

        double mbToHPa(double mb) {
            return mb;
        }

        double hPaToInhg(double pa) {
            return pa / 33.86389;
        }

        double hPaToMb(double pa) {
            return pa;
        }

        double fToC(double f) {
            return (f - 32) * 5 / 9;
        }

        double cToF(double c) {
            return (c * 9 / 5) + 32;
        }
    }
}
