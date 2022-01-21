package com.zem.pwswatcher.model;

import org.json.JSONException;
import org.json.JSONObject;

public class Source {
    private int id;
    private String name;
    private String url;
    private String parsingDateFormat;

    public Source(int id, String name, String url, String parsingDateFormat) {
        this.id = id;
        this.name = name;
        this.url = url;
        this.parsingDateFormat = parsingDateFormat;
    }

    public int getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public String getUrl() {
        return url;
    }

    public void setUrl(String url) {
        this.url = url;
    }

    public String getParsingDateFormat() {
        return parsingDateFormat;
    }

    public String toJSON() throws JSONException {
        JSONObject root = new JSONObject();
        root.put("id", this.id);
        root.put("name", this.name);
        root.put("url", this.url);
        root.put("parsingDateFormat", this.parsingDateFormat);
        return root.toString();
    }

    public JSONObject toJSONObject() throws JSONException {
        JSONObject root = new JSONObject();
        root.put("id", this.id);
        root.put("name", this.name);
        root.put("url", this.url);
        root.put("parsingDateFormat", this.parsingDateFormat);
        return root;
    }

    public static Source fromJSON(String json) throws JSONException {
        JSONObject root = new JSONObject(json);
        return new Source(root.getInt("id"), root.getString("name"), root.getString("url"), root.optString("parsingDateFormat", null));
    }
}