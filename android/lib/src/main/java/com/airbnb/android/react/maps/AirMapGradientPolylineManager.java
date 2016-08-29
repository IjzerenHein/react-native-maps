package com.airbnb.android.react.maps;

import android.content.Context;
import android.graphics.Color;
import android.os.Build;
import android.util.DisplayMetrics;
import android.view.WindowManager;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewGroupManager;
import com.facebook.react.uimanager.annotations.ReactProp;

public class AirMapGradientPolylineManager extends ViewGroupManager<AirMapGradientPolyline> {
    private final DisplayMetrics metrics;

    public AirMapGradientPolylineManager(ReactApplicationContext reactContext) {
        super();
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
            metrics = new DisplayMetrics();
            ((WindowManager) reactContext.getSystemService(Context.WINDOW_SERVICE))
                    .getDefaultDisplay()
                    .getRealMetrics(metrics);
        } else {
            metrics = reactContext.getResources().getDisplayMetrics();
        }
    }

    @Override
    public String getName() {
        return "AIRMapGradientPolyline";
    }

    @Override
    public AirMapGradientPolyline createViewInstance(ThemedReactContext context) {
        return new AirMapGradientPolyline(context);
    }

    @ReactProp(name = "coordinates")
    public void setCoordinate(AirMapGradientPolyline view, ReadableArray coordinates) {
        view.setCoordinates(coordinates);
    }

    @ReactProp(name = "strokeWidth", defaultFloat = 1f)
    public void setStrokeWidth(AirMapGradientPolyline view, float widthInPoints) {
        float widthInScreenPx = metrics.density * widthInPoints; // done for parity with iOS
        view.setWidth(widthInScreenPx);
    }

    @ReactProp(name = "strokeColors")
    public void setStrokeColors(AirMapGradientPolyline view, ReadableArray colors) {
        view.setColors(colors);
    }

    @ReactProp(name = "geodesic", defaultBoolean = false)
    public void setGeodesic(AirMapGradientPolyline view, boolean geodesic) {
        view.setGeodesic(geodesic);
    }

    @ReactProp(name = "zIndex", defaultFloat = 1.0f)
    public void setZIndex(AirMapGradientPolyline view, float zIndex) {
        view.setZIndex(zIndex);
    }
}
