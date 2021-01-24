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

import top.defaults.colorpicker.ColorPickerPopup;
import top.defaults.colorpicker.ColorPickerView;

public class WidgetConfigurationActivity extends Activity {
    public static final String UPDATE_FILTER = "com.zem.pwswatcher.UPDATE";
    public static final String SHARED_PREFERENCES_NAME = "FlutterSharedPreferences";
    private static final String LIST_IDENTIFIER = "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu";
    private final String[] fontSizeText = {"extra-small", "small", "medium", "big", "extra-big"};
    private final float[] multiplier = {0.35f, 0.75f, 1, 1.25f, 1.65f};
    int mAppWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID;
    private ListView lvSources;
    private SeekBar sbFontSize;
    private TextView tvFontSize;
    private CheckBox cbHumidity;
    private CheckBox cbPressure;
    private CheckBox cbRain;
    private CheckBox cbWindSpeed;
    private Button btnBgColor;
    private Button btnTextColor;
    private Button btnConfirm;
    private Source selectedSource;
    private AppWidgetManager widgetManager;
    private RemoteViews views;
    private SourcesListAdapter rAdapter;
    private PendingIntent service;

    private int bgColor = android.graphics.Color.parseColor("#03A9F4");
    private int textColor = android.graphics.Color.parseColor("#FFFFFF");

    @Override
    public void onCreate(Bundle icicle) {
        super.onCreate(icicle);

        setResult(RESULT_CANCELED);
        setContentView(R.layout.activity_widget_configuration);

        this.lvSources = findViewById(R.id.lv_sources);
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
        String widgetSettingsRaw = sharedPref.getString("widget_" + mAppWidgetId, null);

        if(widgetSettingsRaw != null) {
            try{
                JSONObject widgetSettings = new JSONObject(widgetSettingsRaw);

                String rawSource = widgetSettings.getString("source");
                this.selectedSource = Source.fromJSON(rawSource);
                
                this.bgColor = widgetSettings.getInt("bgColor");
                this.textColor = widgetSettings.getInt("textColor");
            } catch(Exception e) {}
        }

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
            viewGroup.addView(View.inflate(this, R.layout.widget_settings, null));

            this.sbFontSize = findViewById(R.id.sb_fontsize);
            this.tvFontSize = findViewById(R.id.tv_fontsize);
            this.cbHumidity = findViewById(R.id.cb_humidity);
            this.cbPressure = findViewById(R.id.cb_pressure);
            this.cbRain = findViewById(R.id.cb_rain);
            this.cbWindSpeed = findViewById(R.id.cb_windspeed);
            
            if(widgetSettingsRaw != null) {
                try{
                    JSONObject widgetSettings = new JSONObject(widgetSettingsRaw);

                    this.cbHumidity.setChecked(widgetSettings.getBoolean("humidityVisible"));
                    this.cbPressure.setChecked(widgetSettings.getBoolean("pressureVisible"));
                    this.cbRain.setChecked(widgetSettings.getBoolean("rainVisible"));
                    this.cbWindSpeed.setChecked(widgetSettings.getBoolean("windspeedVisible"));

                    double multiplierValue = widgetSettings.getDouble("fontSizeMultiplier");
                    double[] doubleMultipliers = {0.35, 0.75, 1, 1.25, 1.65};

                    float fontSize = 16f;
                    int progress = findIndex(doubleMultipliers, multiplierValue);
                    this.sbFontSize.setProgress(progress);
                    this.tvFontSize.setText(fontSizeText[progress]);
                    this.tvFontSize.setTextSize(TypedValue.COMPLEX_UNIT_SP, fontSize * multiplier[progress]);
                } catch(Exception e) {
                }
            }

            SeekBar.OnSeekBarChangeListener seekBarChangeListener = new SeekBar.OnSeekBarChangeListener() {
                @Override
                public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                    float fontSize = 16f;

                    tvFontSize.setText(fontSizeText[progress]);
                    tvFontSize.setTextSize(TypedValue.COMPLEX_UNIT_SP, fontSize * multiplier[progress]);
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
            
            this.btnBgColor = findViewById(R.id.btn_bg_color);
            this.btnBgColor.setOnClickListener(new View.OnClickListener() {
                public void onClick(View v) {
                    new ColorPickerPopup.Builder(getApplicationContext())
                        .initialColor(bgColor)
                        .enableBrightness(true)
                        .enableAlpha(true)
                        .okTitle("Confirm")
                        .cancelTitle("Cancel")
                        .showIndicator(true)
                        .showValue(true)
                        .build()
                        .show(v, new ColorPickerPopup.ColorPickerObserver() {
                            @Override
                            public void onColorPicked(int color) {
                                btnBgColor.setBackgroundColor(color);
                                btnTextColor.setBackgroundColor(color);
                                bgColor = color;
                            }
                        });
                }
            });

            this.btnTextColor = findViewById(R.id.btn_text_color);
            this.btnTextColor.setOnClickListener(new View.OnClickListener() {
                public void onClick(View v) {
                    new ColorPickerPopup.Builder(getApplicationContext())
                        .initialColor(textColor)
                        .enableBrightness(true)
                        .enableAlpha(true)
                        .okTitle("Confirm")
                        .cancelTitle("Cancel")
                        .showIndicator(true)
                        .showValue(true)
                        .build()
                        .show(v, new ColorPickerPopup.ColorPickerObserver() {
                            @Override
                            public void onColorPicked(int color) {
                                btnBgColor.setTextColor(color);
                                btnTextColor.setTextColor(color);
                                textColor = color;
                            }
                        });
                }
            });

            this.btnConfirm = findViewById(R.id.btn_confirm);
            this.btnConfirm.setOnClickListener(new View.OnClickListener() {
                public void onClick(View v) {
                    completeActivity();
                }
            });

            this.btnBgColor.setBackgroundColor(this.bgColor);
            this.btnTextColor.setBackgroundColor(this.bgColor);
            this.btnBgColor.setTextColor(this.textColor);
            this.btnTextColor.setTextColor(this.textColor);
        });
    }

    private void completeActivity() {
        SharedPreferences sharedPrefs = getApplicationContext().getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE);
        try {
            JSONObject root = new JSONObject();
            root.put("source", this.selectedSource.toJSONObject());
            root.put("fontSizeMultiplier", this.multiplier[this.sbFontSize.getProgress()]);
            root.put("humidityVisible", this.cbHumidity.isChecked());
            root.put("pressureVisible", this.cbPressure.isChecked());
            root.put("rainVisible", this.cbRain.isChecked());
            root.put("windspeedVisible", this.cbWindSpeed.isChecked());
            root.put("bgColor", this.bgColor);
            root.put("textColor", this.textColor);
            sharedPrefs.edit().putString("widget_" + mAppWidgetId, root.toString()).apply();
            Log.d("PWSWatcher", "Added Widget #" + mAppWidgetId);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        Intent updateIntent = new Intent(getApplicationContext(), Widget.class);
        updateIntent.setAction(UPDATE_FILTER);
        int[] ids = widgetManager.getAppWidgetIds(new ComponentName(getApplicationContext(), Widget.class));
        updateIntent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids);
        getApplicationContext().sendBroadcast(updateIntent);
        Intent resultValue = new Intent();
        resultValue.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, mAppWidgetId);
        setResult(RESULT_OK, resultValue);
        finish();
    }
    
    private int findIndex(double arr[], double t) 
    {
        // if array is Null 
        if (arr == null) { 
            return -1; 
        } 
  
        // find length of array 
        int len = arr.length; 
        int i = 0; 
  
        // traverse in the array 
        while (i < len) { 
            // if the i-th element is t 
            // then return the index 
            if (arr[i] == t) { 
                return i; 
            } 
            else { 
                i = i + 1; 
            } 
        } 
        return -1; 
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
