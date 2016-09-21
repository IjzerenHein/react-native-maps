package com.airbnb.android.react.maps;

import android.content.Context;

import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.Polyline;
import com.google.android.gms.maps.model.PolylineOptions;

import java.util.ArrayList;
import java.util.List;

public class AirMapGradientPolyline extends AirMapFeature {

    private PolylineOptions polylineOptions;
    private Polyline polyline;

    private List<LatLng> coordinates;
    private int[] colors;
    private float width;
    private boolean geodesic;
    private float zIndex;

    public AirMapGradientPolyline(Context context) {
        super(context);
    }

    public void setCoordinates(ReadableArray coordinates) {
        this.coordinates = new ArrayList<>(coordinates.size());
        for (int i = 0; i < coordinates.size(); i++) {
            ReadableMap coordinate = coordinates.getMap(i);
            this.coordinates.add(i,
                    new LatLng(coordinate.getDouble("latitude"), coordinate.getDouble("longitude")));
        }
        if (polyline != null) {
            polyline.setPoints(this.coordinates);
        }
    }

    public void setColors(ReadableArray colors) {
        this.colors = new int[colors.size()];
        for (int i = 0; i < colors.size(); i++) {
            int color = colors.getInt(i);
            this.colors[i] = color;
        }

        //this.color = color;
        if ((polyline != null) && (colors.size() > 0)) {
            polyline.setColor(colors.getInt(0));
        }
    }

    public void setWidth(float width) {
        this.width = width;
        if (polyline != null) {
            polyline.setWidth(width);
        }
    }

    public void setZIndex(float zIndex) {
        this.zIndex = zIndex;
        if (polyline != null) {
            polyline.setZIndex(zIndex);
        }
    }

    public void setGeodesic(boolean geodesic) {
        this.geodesic = geodesic;
        if (polyline != null) {
            polyline.setGeodesic(geodesic);
        }
    }

    public PolylineOptions getPolylineOptions() {
        if (polylineOptions == null) {
            polylineOptions = createPolylineOptions();
        }
        return polylineOptions;
    }

    private PolylineOptions createPolylineOptions() {
        PolylineOptions options = new PolylineOptions();
        options.addAll(coordinates);
        if (this.colors.length > 0) options.color(this.colors[0]);
        options.width(width);
        options.geodesic(geodesic);
        options.zIndex(zIndex);
        return options;
    }

    @Override
    public Object getFeature() {
        return polyline;
    }

    @Override
    public void addToMap(GoogleMap map) {
        polyline = map.addPolyline(getPolylineOptions());
    }

    @Override
    public void removeFromMap(GoogleMap map) {
        polyline.remove();
    }
}
