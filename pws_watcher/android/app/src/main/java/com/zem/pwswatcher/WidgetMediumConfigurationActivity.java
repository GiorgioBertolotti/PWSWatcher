package com.zem.pwswatcher;

import android.app.Activity;
import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.util.Base64;
import android.util.Log;
import android.util.TypedValue;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.SeekBar;
import android.widget.CheckBox;
import android.widget.Button;
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
import android.content.ComponentName;

public class WidgetMediumConfigurationActivity extends Activity {
    public static final String UPDATE_FILTER = "com.zem.pwswatcher.UPDATE";
    public static final String SHARED_PREFERENCES_NAME = "FlutterSharedPreferences";
    private static final String LIST_IDENTIFIER = "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu";
    int mAppWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID;
    private ListView lvSources;
    private SeekBar sbFontSize;
    private TextView tvFontSize;
    private CheckBox cbHumidity;
    private CheckBox cbPressure;
    private CheckBox cbRain;
    private CheckBox cbWindSpeed;
    private Button btnConfirm;
    private Source selectedSource;
    private AppWidgetManager widgetManager;
    private RemoteViews views;
    private SourcesListAdapter rAdapter;
    private PendingIntent service;

    @Override
    public void onCreate(Bundle icicle) {
        super.onCreate(icicle);
        setResult(RESULT_CANCELED);
        setContentView(R.layout.activity_widget_configuration);
        this.lvSources = findViewById(R.id.lv_sources);
        widgetManager = AppWidgetManager.getInstance(this);
        views = new RemoteViews(this.getPackageName(), R.layout.widget_medium);
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
        this.lvSources.setEmptyView(findViewById(R.id.tv_empty_list));
        this.lvSources.setOnItemClickListener((adapter, v, position, id) -> {
            this.selectedSource = rAdapter.getItem(position);
            final ViewGroup viewGroup = (ViewGroup) findViewById(R.id.ll_activity_container);
            viewGroup.removeAllViews();
            viewGroup.addView(View.inflate(this, R.layout.widget_medium_settings, null));
            this.sbFontSize = findViewById(R.id.sb_fontsize);
            this.tvFontSize = findViewById(R.id.tv_fontsize);
            this.cbHumidity = findViewById(R.id.cb_humidity);
            this.cbPressure = findViewById(R.id.cb_pressure);
            this.cbRain = findViewById(R.id.cb_rain);
            this.cbWindSpeed = findViewById(R.id.cb_windspeed);
            SeekBar.OnSeekBarChangeListener seekBarChangeListener = new SeekBar.OnSeekBarChangeListener() {
                @Override
                public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                    float fontSize = 16f;
                    if (progress == 0) {
                        tvFontSize.setText("extra-small");
                        tvFontSize.setTextSize(TypedValue.COMPLEX_UNIT_SP, fontSize * 0.35f);
                    } else if (progress == 1) {
                        tvFontSize.setText("small");
                        tvFontSize.setTextSize(TypedValue.COMPLEX_UNIT_SP, fontSize * 0.75f);
                    } else if (progress == 2) {
                        tvFontSize.setText("medium");
                        tvFontSize.setTextSize(TypedValue.COMPLEX_UNIT_SP, fontSize);
                    } else if (progress == 3) {
                        tvFontSize.setText("big");
                        tvFontSize.setTextSize(TypedValue.COMPLEX_UNIT_SP, fontSize * 1.25f);
                    } else {
                        tvFontSize.setText("extra-big");
                        tvFontSize.setTextSize(TypedValue.COMPLEX_UNIT_SP, fontSize * 1.65f);
                    }
                }
                @Override
                public void onStartTrackingTouch(SeekBar seekBar) {
                    // called when the user first touches the SeekBar
                }
                @Override
                public void onStopTrackingTouch(SeekBar seekBar) {
                    // called after the user finishes moving the SeekBar
                }
            };
            this.sbFontSize.setOnSeekBarChangeListener(seekBarChangeListener);
            this.btnConfirm = findViewById(R.id.btn_confirm);
            this.btnConfirm.setOnClickListener(new View.OnClickListener() {
                public void onClick(View v) {
                    completeActivity();
                }
            });
        });
    }

    private void completeActivity() {
        SharedPreferences sharedPrefs = getApplicationContext().getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE);
        try {
            JSONObject root = new JSONObject();
            root.put("source", this.selectedSource.toJSONObject());
            switch (this.sbFontSize.getProgress()) {
                case 0:
                    root.put("fontSizeMultiplier", 0.35);
                    break;
                case 1:
                    root.put("fontSizeMultiplier", 0.75);
                    break;
                case 2:
                    root.put("fontSizeMultiplier", 1.0);
                    break;
                case 3:
                    root.put("fontSizeMultiplier", 1.25);
                    break;
                case 4:
                    root.put("fontSizeMultiplier", 1.65);
                    break;
                default:
                    root.put("fontSizeMultiplier", 1.0);
                    break;
            }
            root.put("humidityVisible", this.cbHumidity.isChecked());
            root.put("pressureVisible", this.cbPressure.isChecked());
            root.put("rainVisible", this.cbRain.isChecked());
            root.put("windspeedVisible", this.cbWindSpeed.isChecked());
            sharedPrefs.edit().putString("widget_" + mAppWidgetId, root.toString()).apply();
            Log.d("PWSWatcher", "Added Widget #" + mAppWidgetId);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        Intent updateIntent = new Intent(getApplicationContext(), WidgetMedium.class);
        updateIntent.setAction(UPDATE_FILTER);
        int[] ids = widgetManager.getAppWidgetIds(new ComponentName(getApplicationContext(), WidgetMedium.class));
        updateIntent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids);
        getApplicationContext().sendBroadcast(updateIntent);
        Intent resultValue = new Intent();
        resultValue.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, mAppWidgetId);
        setResult(RESULT_OK, resultValue);
        finish();
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
