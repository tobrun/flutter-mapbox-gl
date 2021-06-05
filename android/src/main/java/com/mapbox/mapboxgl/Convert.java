// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.mapbox.mapboxgl;

import android.content.Context;
import android.graphics.Point;
import android.util.DisplayMetrics;

import com.mapbox.geojson.Polygon;
import com.mapbox.mapboxsdk.camera.CameraPosition;
import com.mapbox.mapboxsdk.camera.CameraUpdate;
import com.mapbox.mapboxsdk.camera.CameraUpdateFactory;
import com.mapbox.mapboxsdk.geometry.LatLng;
import com.mapbox.mapboxsdk.geometry.LatLngBounds;
import com.mapbox.mapboxsdk.log.Logger;
import com.mapbox.mapboxsdk.maps.MapboxMap;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Conversions between JSON-like values and MapboxMaps data types.
 */
class Convert {

  private final static String TAG = "Convert";

//  private static BitmapDescriptor toBitmapDescriptor(Object o) {
//    final List<?> data = toList(o);
//    switch (toString(data.get(0))) {
//      case "defaultMarker":
//        if (data.size() == 1) {
//          return BitmapDescriptorFactory.defaultMarker();
//        } else {
//          return BitmapDescriptorFactory.defaultMarker(toFloat(data.get(1)));
//        }
//      case "fromAsset":
//        if (data.size() == 2) {
//          return BitmapDescriptorFactory.fromAsset(
//              FlutterMain.getLookupKeyForAsset(toString(data.get(1))));
//        } else {
//          return BitmapDescriptorFactory.fromAsset(
//              FlutterMain.getLookupKeyForAsset(toString(data.get(1)), toString(data.get(2))));
//        }
//      default:
//        throw new IllegalArgumentException("Cannot interpret " + o + " as BitmapDescriptor");
//    }
//  }

  private static boolean toBoolean(Object o) {
    return (Boolean) o;
  }

  static CameraPosition toCameraPosition(Object o) {
    final Map<?, ?> data = toMap(o);
    final CameraPosition.Builder builder = new CameraPosition.Builder();
    builder.bearing(toFloat(data.get("bearing")));
    builder.target(toLatLng(data.get("target")));
    builder.tilt(toFloat(data.get("tilt")));
    builder.zoom(toFloat(data.get("zoom")));
    return builder.build();
  }

  static List<String> toAnnotationOrder(Object o) {
    final List<?> data = toList(o);
    List<String> annotations = new ArrayList();
    for (int index = 0; index < data.size(); index++) {
      annotations.add(toString(data.get(index)));
    }
    return annotations;
  }

  static List<String> toAnnotationConsumeTapEvents(Object o) {
    return toAnnotationOrder(o);
  }

  static boolean isScrollByCameraUpdate(Object o) {
    return toString(toList(o).get(0)).equals("scrollBy");
  }

  static CameraUpdate toCameraUpdate(Object o, MapboxMap mapboxMap, float density) {
    final List<?> data = toList(o);
    switch (toString(data.get(0))) {
      case "newCameraPosition":
        return CameraUpdateFactory.newCameraPosition(toCameraPosition(data.get(1)));
      case "newLatLng":
        return CameraUpdateFactory.newLatLng(toLatLng(data.get(1)));
      case "newLatLngBounds":
        return CameraUpdateFactory.newLatLngBounds(toLatLngBounds(data.get(1)), toPixels(data.get(2), density),
            toPixels(data.get(3), density), toPixels(data.get(4), density), toPixels(data.get(5), density));
      case "newLatLngZoom":
        return CameraUpdateFactory.newLatLngZoom(toLatLng(data.get(1)), toFloat(data.get(2)));
      case "scrollBy":
        mapboxMap.scrollBy(
          toFractionalPixels(data.get(1), density),
          toFractionalPixels(data.get(2), density)
        );
        return null;
      case "zoomBy":
        if (data.size() == 2) {
          return CameraUpdateFactory.zoomBy(toFloat(data.get(1)));
        } else {
          return CameraUpdateFactory.zoomBy(toFloat(data.get(1)), toPoint(data.get(2), density));
        }
      case "zoomIn":
        return CameraUpdateFactory.zoomIn();
      case "zoomOut":
        return CameraUpdateFactory.zoomOut();
      case "zoomTo":
        return CameraUpdateFactory.zoomTo(toFloat(data.get(1)));
      case "bearingTo":
        return CameraUpdateFactory.bearingTo(toFloat(data.get(1)));
      case "tiltTo":
        return CameraUpdateFactory.tiltTo(toFloat(data.get(1)));
      default:
        throw new IllegalArgumentException("Cannot interpret " + o + " as CameraUpdate");
    }
  }

  private static double toDouble(Object o) {
    return ((Number) o).doubleValue();
  }

  private static float toFloat(Object o) {
    return ((Number) o).floatValue();
  }

  private static Float toFloatWrapper(Object o) {
    return (o == null) ? null : toFloat(o);
  }

  static int toInt(Object o) {
    return ((Number) o).intValue();
  }

  static Object toJson(CameraPosition position) {
    if (position == null) {
      return null;
    }
    final Map<String, Object> data = new HashMap<>();
    data.put("bearing", position.bearing);
    data.put("target", toJson(position.target));
    data.put("tilt", position.tilt);
    data.put("zoom", position.zoom);
    return data;
  }

  private static Object toJson(LatLng latLng) {
    return Arrays.asList(latLng.getLatitude(), latLng.getLongitude());
  }

  private static LatLng toLatLng(Object o) {
    final List<?> data = toList(o);
    return new LatLng(toDouble(data.get(0)), toDouble(data.get(1)));
  }

  private static LatLngBounds toLatLngBounds(Object o) {
    if (o == null) {
      return null;
    }
    final List<?> data = toList(o);
    LatLng[] boundsArray = new LatLng[] {toLatLng(data.get(0)), toLatLng(data.get(1))};
    List<LatLng> bounds = Arrays.asList(boundsArray);
    LatLngBounds.Builder builder = new LatLngBounds.Builder();
    builder.includes(bounds);
    return builder.build();
  }

  static List<LatLng> toLatLngList(Object o) {
    if (o == null) {
      return null;
    }
    final List<?> data = toList(o);
    List<LatLng> latLngList = new ArrayList<>();
    for (int i=0; i<data.size(); i++) {
      final List<?> coords = toList(data.get(i));
      latLngList.add(new LatLng(toDouble(coords.get(0)), toDouble(coords.get(1))));
    }
    return latLngList;
  }

  private static List<List<LatLng>> toLatLngListList(Object o) {
    if (o == null) {
      return null;
    }
    final List<?> data = toList(o);
    List<List<LatLng>> latLngListList = new ArrayList<>();
    for (int i = 0; i < data.size(); i++) {
      List<LatLng> latLngList = toLatLngList(data.get(i));
      latLngListList.add(latLngList);
    }
    return latLngListList;
  }

  static Polygon interpretListLatLng(List<List<LatLng>> geometry) {
    List<List<com.mapbox.geojson.Point>> points = new ArrayList<>(geometry.size());
    for (List<LatLng> innerGeometry : geometry) {
      List<com.mapbox.geojson.Point> innerPoints = new ArrayList<>(innerGeometry.size());
      for (LatLng latLng : innerGeometry) {
        innerPoints.add(com.mapbox.geojson.Point.fromLngLat(latLng.getLongitude(), latLng.getLatitude()));
      }
      points.add(innerPoints);
    }
    return Polygon.fromLngLats(points);
  }

  private static List<?> toList(Object o) {
    return (List<?>) o;
  }

  static long toLong(Object o) {
    return ((Number) o).longValue();
  }

  static Map<?, ?> toMap(Object o) {
    return (Map<?, ?>) o;
  }

  private static float toFractionalPixels(Object o, float density) {
    return toFloat(o) * density;
  }

  static int toPixels(Object o, float density) {
    return (int) toFractionalPixels(o, density);
  }

  private static Point toPoint(Object o, float density) {
    final List<?> data = toList(o);
    return new Point(toPixels(data.get(0), density), toPixels(data.get(1), density));
  }

  private static String toString(Object o) {
    return (String) o;
  }

  static void interpretMapboxMapOptions(Object o, MapboxMapOptionsSink sink, Context context) {
    final DisplayMetrics metrics = context.getResources().getDisplayMetrics();
    final Map<?, ?> data = toMap(o);
    final Object cameraTargetBounds = data.get("cameraTargetBounds");
    if (cameraTargetBounds != null) {
      final List<?> targetData = toList(cameraTargetBounds);
      sink.setCameraTargetBounds(toLatLngBounds(targetData.get(0)));
    }
    final Object compassEnabled = data.get("compassEnabled");
    if (compassEnabled != null) {
      sink.setCompassEnabled(toBoolean(compassEnabled));
    }
    final Object styleString = data.get("styleString");
    if (styleString != null) {
      sink.setStyleString(toString(styleString));
    }
    final Object minMaxZoomPreference = data.get("minMaxZoomPreference");
    if (minMaxZoomPreference != null) {
      final List<?> zoomPreferenceData = toList(minMaxZoomPreference);
      sink.setMinMaxZoomPreference( //
        toFloatWrapper(zoomPreferenceData.get(0)), //
        toFloatWrapper(zoomPreferenceData.get(1)));
    }
    final Object rotateGesturesEnabled = data.get("rotateGesturesEnabled");
    if (rotateGesturesEnabled != null) {
      sink.setRotateGesturesEnabled(toBoolean(rotateGesturesEnabled));
    }
    final Object scrollGesturesEnabled = data.get("scrollGesturesEnabled");
    if (scrollGesturesEnabled != null) {
      sink.setScrollGesturesEnabled(toBoolean(scrollGesturesEnabled));
    }
    final Object tiltGesturesEnabled = data.get("tiltGesturesEnabled");
    if (tiltGesturesEnabled != null) {
      sink.setTiltGesturesEnabled(toBoolean(tiltGesturesEnabled));
    }
    final Object trackCameraPosition = data.get("trackCameraPosition");
    if (trackCameraPosition != null) {
      sink.setTrackCameraPosition(toBoolean(trackCameraPosition));
    }
    final Object zoomGesturesEnabled = data.get("zoomGesturesEnabled");
    if (zoomGesturesEnabled != null) {
      sink.setZoomGesturesEnabled(toBoolean(zoomGesturesEnabled));
    }
    final Object myLocationEnabled = data.get("myLocationEnabled");
    if (myLocationEnabled != null) {
      sink.setMyLocationEnabled(toBoolean(myLocationEnabled));
    }
    final Object myLocationTrackingMode = data.get("myLocationTrackingMode");
    if (myLocationTrackingMode != null) {
      sink.setMyLocationTrackingMode(toInt(myLocationTrackingMode));
    }
    final Object myLocationRenderMode = data.get("myLocationRenderMode");
    if (myLocationRenderMode != null) {
      sink.setMyLocationRenderMode(toInt(myLocationRenderMode));
    }
    final Object logoViewMargins = data.get("logoViewMargins");
    if(logoViewMargins != null){
      final List logoViewMarginsData = toList(logoViewMargins);
      final Point point = toPoint(logoViewMarginsData, metrics.density);
      sink.setLogoViewMargins(point.x, point.y);
    }
    final Object compassGravity = data.get("compassViewPosition");
    if(compassGravity != null){
      sink.setCompassGravity(toInt(compassGravity));
    }
    final Object compassViewMargins = data.get("compassViewMargins");
    if(compassViewMargins != null){
      final List compassViewMarginsData = toList(compassViewMargins);
      final Point point = toPoint(compassViewMarginsData, metrics.density);
      sink.setCompassViewMargins(point.x, point.y);
    }
    final Object attributionButtonMargins = data.get("attributionButtonMargins");
    if(attributionButtonMargins != null){
      final List attributionButtonMarginsData = toList(attributionButtonMargins);
      final Point point = toPoint(attributionButtonMarginsData, metrics.density);
      final int attributionButtonWidth = toPixels(21, metrics.density);
      sink.setAttributionButtonMargins(metrics.widthPixels - point.x - attributionButtonWidth, point.y);
    }
  }

  static void interpretSymbolOptions(Object o, SymbolOptionsSink sink) {
    final Map<?, ?> data = toMap(o);
    final Object iconSize = data.get("iconSize");
    if (iconSize != null) {
      sink.setIconSize(toFloat(iconSize));
    }
    final Object iconImage = data.get("iconImage");
    if (iconImage != null) {
      sink.setIconImage(toString(iconImage));
    }
    final Object iconRotate = data.get("iconRotate");
    if (iconRotate != null) {
      sink.setIconRotate(toFloat(iconRotate));
    }
    final Object iconOffset = data.get("iconOffset");
    if (iconOffset != null) {
      sink.setIconOffset(new float[] {toFloat(toList(iconOffset).get(0)), toFloat(toList(iconOffset).get(1))});
    }
    final Object iconAnchor = data.get("iconAnchor");
    if (iconAnchor != null) {
      sink.setIconAnchor(toString(iconAnchor));
    }
    final ArrayList fontNames = (ArrayList) data.get("fontNames");
    if (fontNames != null) {
      sink.setFontNames((String[]) fontNames.toArray(new String[0]));
    }
    final Object textField = data.get("textField");
    if (textField != null) {
      sink.setTextField(toString(textField));
    }
    final Object textSize = data.get("textSize");
    if (textSize != null) {
      sink.setTextSize(toFloat(textSize));
    }
    final Object textMaxWidth = data.get("textMaxWidth");
    if (textMaxWidth != null) {
      sink.setTextMaxWidth(toFloat(textMaxWidth));
    }
    final Object textLetterSpacing = data.get("textLetterSpacing");
    if (textLetterSpacing != null) {
      sink.setTextLetterSpacing(toFloat(textLetterSpacing));
    }
    final Object textJustify = data.get("textJustify");
    if (textJustify != null) {
      sink.setTextJustify(toString(textJustify));
    }
    final Object textAnchor = data.get("textAnchor");
    if (textAnchor != null) {
      sink.setTextAnchor(toString(textAnchor));
    }
    final Object textRotate = data.get("textRotate");
    if (textRotate != null) {
      sink.setTextRotate(toFloat(textRotate));
    }
    final Object textTransform = data.get("textTransform");
    if (textTransform != null) {
      sink.setTextTransform(toString(textTransform));
    }
    final Object textOffset = data.get("textOffset");
    if (textOffset != null) {
      sink.setTextOffset(new float[] {toFloat(toList(textOffset).get(0)), toFloat(toList(textOffset).get(1))});
    }
    final Object iconOpacity = data.get("iconOpacity");
    if (iconOpacity != null) {
      sink.setIconOpacity(toFloat(iconOpacity));
    }
    final Object iconColor = data.get("iconColor");
    if (iconColor != null) {
      sink.setIconColor(toString(iconColor));
    }
    final Object iconHaloColor = data.get("iconHaloColor");
    if (iconHaloColor != null) {
      sink.setIconHaloColor(toString(iconHaloColor));
    }
    final Object iconHaloWidth = data.get("iconHaloWidth");
    if (iconHaloWidth != null) {
      sink.setIconHaloWidth(toFloat(iconHaloWidth));
    }
    final Object iconHaloBlur = data.get("iconHaloBlur");
    if (iconHaloBlur != null) {
      sink.setIconHaloBlur(toFloat(iconHaloBlur));
    }
    final Object textOpacity = data.get("textOpacity");
    if (textOpacity != null) {
      sink.setTextOpacity(toFloat(textOpacity));
    }
    final Object textColor = data.get("textColor");
    if (textColor != null) {
      sink.setTextColor(toString(textColor));
    }
    final Object textHaloColor = data.get("textHaloColor");
    if (textHaloColor != null) {
      sink.setTextHaloColor(toString(textHaloColor));
    }
    final Object textHaloWidth = data.get("textHaloWidth");
    if (textHaloWidth != null) {
      sink.setTextHaloWidth(toFloat(textHaloWidth));
    }
    final Object textHaloBlur = data.get("textHaloBlur");
    if (textHaloBlur != null) {
      sink.setTextHaloBlur(toFloat(textHaloBlur));
    }
    final Object geometry = data.get("geometry");
    if (geometry != null) {
      sink.setGeometry(toLatLng(geometry));
    }
    final Object symbolSortKey = data.get("zIndex");
    if (symbolSortKey != null) {
      sink.setSymbolSortKey(toFloat(symbolSortKey));
    }
    final Object draggable = data.get("draggable");
    if (draggable != null) {
      sink.setDraggable(toBoolean(draggable));
    }
  }

  static void interpretCircleOptions(Object o, CircleOptionsSink sink) {
    final Map<?, ?> data = toMap(o);
    final Object circleRadius = data.get("circleRadius");
    if (circleRadius != null) {
      sink.setCircleRadius(toFloat(circleRadius));
    }
    final Object circleColor = data.get("circleColor");
    if (circleColor != null) {
      sink.setCircleColor(toString(circleColor));
    }
    final Object circleBlur = data.get("circleBlur");
    if (circleBlur != null) {
      sink.setCircleBlur(toFloat(circleBlur));
    }
    final Object circleOpacity = data.get("circleOpacity");
    if (circleOpacity != null) {
      sink.setCircleOpacity(toFloat(circleOpacity));
    }
    final Object circleStrokeWidth = data.get("circleStrokeWidth");
    if (circleStrokeWidth != null) {
      sink.setCircleStrokeWidth(toFloat(circleStrokeWidth));
    }
    final Object circleStrokeColor = data.get("circleStrokeColor");
    if (circleStrokeColor != null) {
      sink.setCircleStrokeColor(toString(circleStrokeColor));
    }
    final Object circleStrokeOpacity = data.get("circleStrokeOpacity");
    if (circleStrokeOpacity != null) {
      sink.setCircleStrokeOpacity(toFloat(circleStrokeOpacity));
    }
    final Object geometry = data.get("geometry");
    if (geometry != null) {
      sink.setGeometry(toLatLng(geometry));
    }
    final Object draggable = data.get("draggable");
    if (draggable != null) {
      sink.setDraggable(toBoolean(draggable));
    }
  }
  static void interpretLineOptions(Object o, LineOptionsSink sink) {
    final Map<?, ?> data = toMap(o);
    final Object lineJoin = data.get("lineJoin");
    if (lineJoin != null) {
      Logger.e(TAG, "setLineJoin" +  lineJoin);
      sink.setLineJoin(toString(lineJoin));
    }
    final Object lineOpacity = data.get("lineOpacity");
    if (lineOpacity != null) {
      Logger.e(TAG, "setLineOpacity" + lineOpacity);
      sink.setLineOpacity(toFloat(lineOpacity));
    }
    final Object lineColor = data.get("lineColor");
    if (lineColor != null) {
      Logger.e(TAG, "setLineColor" +  lineColor);
      sink.setLineColor(toString(lineColor));
    }
    final Object lineWidth = data.get("lineWidth");
    if (lineWidth != null) {
      Logger.e(TAG, "setLineWidth" + lineWidth);
      sink.setLineWidth(toFloat(lineWidth));
    }
    final Object lineGapWidth = data.get("lineGapWidth");
    if (lineGapWidth != null) {
      Logger.e(TAG, "setLineGapWidth" + lineGapWidth);
      sink.setLineGapWidth(toFloat(lineGapWidth));
    }
    final Object lineOffset = data.get("lineOffset");
    if (lineOffset != null) {
      Logger.e(TAG, "setLineOffset" + lineOffset);
      sink.setLineOffset(toFloat(lineOffset));
    }
    final Object lineBlur = data.get("lineBlur");
    if (lineBlur != null) {
      Logger.e(TAG, "setLineBlur" + lineBlur);
      sink.setLineBlur(toFloat(lineBlur));
    }
    final Object linePattern = data.get("linePattern");
    if (linePattern != null) {
      Logger.e(TAG, "setLinePattern" +  linePattern);
      sink.setLinePattern(toString(linePattern));
    }
    final Object geometry = data.get("geometry");
    if (geometry != null) {
      Logger.e(TAG, "SetGeometry");
      sink.setGeometry(toLatLngList(geometry));
    }
    final Object draggable = data.get("draggable");
    if (draggable != null) {
      Logger.e(TAG, "SetDraggable");
      sink.setDraggable(toBoolean(draggable));
    }
  }

  static void interpretFillOptions(Object o, FillOptionsSink sink) {
    final Map<?, ?> data = toMap(o);
    final Object fillOpacity = data.get("fillOpacity");
    if (fillOpacity != null) {
      sink.setFillOpacity(toFloat(fillOpacity));
    }
    final Object fillColor = data.get("fillColor");
    if (fillColor != null) {
      sink.setFillColor(toString(fillColor));
    }
    final Object fillOutlineColor = data.get("fillOutlineColor");
    if (fillOutlineColor != null) {
      sink.setFillOutlineColor(toString(fillOutlineColor));
    }
    final Object fillPattern = data.get("fillPattern");
    if (fillPattern != null) {
      sink.setFillPattern(toString(fillPattern));
    }
    final Object geometry = data.get("geometry");
    if (geometry != null) {
      sink.setGeometry(toLatLngListList(geometry));
    }
    final Object draggable = data.get("draggable");
    if (draggable != null) {
      sink.setDraggable(toBoolean(draggable));
    }
  }
}