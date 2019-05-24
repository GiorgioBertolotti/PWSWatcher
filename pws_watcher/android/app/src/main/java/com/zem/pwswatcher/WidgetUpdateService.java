package com.zem.pwswatcher;

import android.app.Service;
import android.appwidget.AppWidgetManager;
import android.content.Context;
import android.content.Intent;
import android.os.AsyncTask;
import android.os.IBinder;
import android.support.annotation.Nullable;
import android.widget.RemoteViews;

import com.zem.pwswatcher.model.Source;

import org.json.JSONException;
import org.xmlpull.v1.XmlPullParser;
import org.xmlpull.v1.XmlPullParserException;
import org.xmlpull.v1.XmlPullParserFactory;

import java.io.IOException;
import java.io.StringReader;
import java.util.Arrays;

import okhttp3.Call;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;

public class WidgetUpdateService extends Service {
    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Source source = null;
        Integer id = -1;
        if (intent != null && intent.getStringExtra("SOURCE") != null) {
            try {
                source = Source.fromJSON(intent.getStringExtra("SOURCE"));
                id = intent.getIntExtra("ID", -1);
            } catch (Exception ignored) {
            }
        }
        if (source != null && id != -1) {
            if(source.getUrl().endsWith(".txt") || source.getUrl().endsWith(".xml")) {
                DataElaborator dataElaborator = new DataElaborator(this, source, id);
                dataElaborator.execute();
            } else {
                String originalSource = source.getUrl();
                source.setUrl(originalSource + "/realtime.txt");
                DataElaborator dataElaborator = new DataElaborator(this, source, id);
                dataElaborator.execute();
                source.setUrl(originalSource + "/realtime.xml");
                dataElaborator = new DataElaborator(this, source, id);
                dataElaborator.execute();
            }
        }
        return super.onStartCommand(intent, flags, startId);
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
            if(done) {
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
            } catch(Exception ignored) {}
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
                String[] attributes = {"misc","realtime","today","yesterday","record"};
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
            } catch(Exception e) {
                e.printStackTrace();
            }
            return false;
        }
    }
}
