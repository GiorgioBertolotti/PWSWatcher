package com.zem.pwswatcher;

import android.app.Activity;
import android.app.AlarmManager;
import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.os.SystemClock;
import android.util.Base64;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.RemoteViews;
import android.widget.TextView;

import com.zem.pwswatcher.model.Source;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.util.ArrayList;
import java.util.List;

public class WidgetConfigurationActivity extends Activity {
    public static final String SHARED_PREFERENCES_NAME = "FlutterSharedPreferences";
    private static final String LIST_IDENTIFIER = "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu";
    int mAppWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID;
    private ListView lvSources;
    private AppWidgetManager widgetManager;
    private RemoteViews views;
    private SourcesListAdapter rAdapter;
    private PendingIntent service;

    @Override
    public void onCreate(Bundle icicle) {
        super.onCreate(icicle);
        setResult(RESULT_CANCELED);
        setContentView(R.layout.activity_widget_configuration);
        lvSources = findViewById(R.id.lv_sources);
        widgetManager = AppWidgetManager.getInstance(this);
        views = new RemoteViews(this.getPackageName(), R.layout.widget);
        Intent intent = getIntent();
        Bundle extras = intent.getExtras();
        if (extras != null) {
            mAppWidgetId = extras.getInt(AppWidgetManager.EXTRA_APPWIDGET_ID, AppWidgetManager.INVALID_APPWIDGET_ID);
        }
        if (mAppWidgetId == AppWidgetManager.INVALID_APPWIDGET_ID) {
            finish();
            return;
        }
        final SharedPreferences sharedPref = getApplicationContext().getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE);
        String stringValue = sharedPref.getString("flutter.sources", null);
        List<Source> sources = new ArrayList<>();
        if (stringValue != null) {
            List<String> sourcesJSON = null;
            if (stringValue.startsWith(LIST_IDENTIFIER)) {
                try {
                    sourcesJSON = decodeList(stringValue.substring(LIST_IDENTIFIER.length()));
                } catch (IOException ignored) {
                }
            }
            if (sourcesJSON == null) {
                sourcesJSON = new ArrayList<>();
            }
            for (String sourceJSON : sourcesJSON) {
                try {
                    JSONObject obj = new JSONObject(sourceJSON);
                    sources.add(new Source(obj.getInt("id"), obj.getString("name"), obj.getString("url")));
                } catch (JSONException e) {
                }
            }
        }
        this.rAdapter = new SourcesListAdapter(getApplicationContext(), sources);
        this.lvSources.setAdapter(this.rAdapter);
        this.lvSources.setOnItemClickListener((adapter, v, position, id) -> {
            Source source = rAdapter.getItem(position);
            final AlarmManager manager = (AlarmManager) getApplicationContext().getSystemService(Context.ALARM_SERVICE);
            final Intent i = new Intent(getApplicationContext(), WidgetUpdateService.class);
            try {
                i.putExtra("SOURCE", ((source != null) ? source.toJSON() : null));
                i.putExtra("ID", mAppWidgetId);
            } catch (JSONException e) {
            }
            if (service == null) {
                service = PendingIntent.getService(getApplicationContext(), 0, i, PendingIntent.FLAG_CANCEL_CURRENT);
            }
            SharedPreferences sharedPrefs = getApplicationContext().getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE);
            try {
                sharedPrefs.edit().putString("widget_" + mAppWidgetId, source.toJSON()).apply();
                Log.d("PWSWatcher", "Added Widget #" + mAppWidgetId);
            } catch (JSONException e) {
                e.printStackTrace();
            }
            long refreshRate = sharedPrefs.getLong("flutter.widget_refresh_interval", 15);
            manager.setRepeating(AlarmManager.ELAPSED_REALTIME, SystemClock.elapsedRealtime(), refreshRate * 60000, service);
            if(source.getUrl().endsWith(".txt") || source.getUrl().endsWith(".xml")) {
                WidgetUpdateService.DataElaborator dataElaborator = new WidgetUpdateService.DataElaborator(getApplicationContext(), source, mAppWidgetId);
                dataElaborator.execute();
            } else {
                String originalSource = source.getUrl();
                source.setUrl(originalSource + "/realtime.txt");
                WidgetUpdateService.DataElaborator dataElaborator = new WidgetUpdateService.DataElaborator(getApplicationContext(), source, mAppWidgetId);
                dataElaborator.execute();
                source.setUrl(originalSource + "/realtime.xml");
                dataElaborator = new WidgetUpdateService.DataElaborator(getApplicationContext(), source, mAppWidgetId);
                dataElaborator.execute();
            }
            widgetManager.updateAppWidget(mAppWidgetId, views);
            Intent resultValue = new Intent();
            resultValue.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, mAppWidgetId);
            setResult(RESULT_OK, resultValue);
            finish();
        });
    }

    private List<String> decodeList(String encodedList) throws IOException {
        ObjectInputStream stream = null;
        try {
            stream = new ObjectInputStream(new ByteArrayInputStream(Base64.decode(encodedList, 0)));
            return (List<String>) stream.readObject();
        } catch (ClassNotFoundException e) {
            throw new IOException(e);
        } finally {
            if (stream != null) {
                stream.close();
            }
        }
    }

    public class SourcesListAdapter extends ArrayAdapter<Source> {
        SourcesListAdapter(Context context, List<Source> reservationList) {
            super(context, 0, reservationList);
        }

        @Override
        public View getView(final int i, View view, ViewGroup viewGroup) {
            view = ((LayoutInflater) getContext().getSystemService(Context.LAYOUT_INFLATER_SERVICE)).inflate(R.layout.item_source, null);
            Source reservation = getItem(i);
            TextView tvName = view.findViewById(R.id.tv_source_name);
            TextView tvUrl = view.findViewById(R.id.tv_source_url);
            tvName.setText(reservation.getName());
            tvUrl.setText(reservation.getUrl());
            return view;
        }
    }
}
