package com.zem.pwswatcher.model;

import org.json.JSONException;
import org.json.JSONObject;

public class Source {
    private int id;
    private String name;
    private String url;

    public Source(int id, String name, String url) {
        this.id = id;
        this.name = name;
        this.url = url;
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

    public String toJSON() throws JSONException {
        JSONObject root = new JSONObject();
        root.put("id", this.id);
        root.put("name", this.name);
        root.put("url", this.url);
        return root.toString();
    }

    public static Source fromJSON(String json) throws JSONException {
        JSONObject root = new JSONObject(json);
        return new Source(root.getInt("id"), root.getString("name"), root.getString("url"));
    }
}