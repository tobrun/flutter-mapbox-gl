// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.mapbox.mapboxgl;

import android.graphics.Point;

import com.mapbox.mapboxsdk.camera.CameraPosition;
import com.mapbox.mapboxsdk.camera.CameraUpdate;
import com.mapbox.mapboxsdk.camera.CameraUpdateFactory;
import com.mapbox.mapboxsdk.geometry.LatLng;
import com.mapbox.mapboxsdk.geometry.LatLngBounds;
import com.mapbox.mapboxsdk.log.Logger;
import com.mapbox.mapboxsdk.maps.MapboxMap;
import com.mapbox.mapboxsdk.style.expressions.Expression;
import com.mapbox.mapboxsdk.style.layers.PropertyFactory;
import com.mapbox.mapboxsdk.style.layers.PropertyValue;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.JSONUtil;

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
        return CameraUpdateFactory.newLatLngBounds(
          toLatLngBounds(data.get(1)), toPixels(data.get(2), density));
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

  private static List<LatLng> toLatLngList(Object o) {
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

  static void interpretMapboxMapOptions(Object o, MapboxMapOptionsSink sink) {
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
      sink.setLogoViewMargins(toInt(logoViewMarginsData.get(0)), toInt(logoViewMarginsData.get(1)));
    }
    final Object compassGravity = data.get("compassViewPosition");
    if(compassGravity != null){
      sink.setCompassGravity(toInt(compassGravity));
    }
    final Object compassViewMargins = data.get("compassViewMargins");
    if(compassViewMargins != null){
      final List compassViewMarginsData = toList(compassViewMargins);
      sink.setCompassViewMargins(toInt(compassViewMarginsData.get(0)), toInt(compassViewMarginsData.get(1)));
    }
    final Object attributionButtonMargins = data.get("attributionButtonMargins");
    if(attributionButtonMargins != null){
      final List attributionButtonMarginsData = toList(attributionButtonMargins);
      sink.setAttributionButtonMargins(toInt(attributionButtonMarginsData.get(0)), toInt(attributionButtonMarginsData.get(1)));
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

  static PropertyValue[] interpretSymbolLayerProperties(Object o) {
    final Map<String, String> data = (Map<String, String>) toMap(o);
    final List<PropertyValue> properties = new LinkedList();

    for (Map.Entry<String, String> entry : data.entrySet()) {
      Expression expression = Expression.Converter.convert(entry.getValue());
      switch (entry.getKey()) {
        case "icon-allow-overlap":
          properties.add(PropertyFactory.iconAllowOverlap(expression));
          break;
        case "icon-anchor":
          properties.add(PropertyFactory.iconAnchor(expression));
          break;
        case "icon-color":
          properties.add(PropertyFactory.iconColor(expression));
          break;
        case "icon-halo-blur":
          properties.add(PropertyFactory.iconHaloBlur(expression));
          break;
        case "icon-halo-color":
          properties.add(PropertyFactory.iconHaloColor(expression));
          break;
        case "icon-halo-width":
          properties.add(PropertyFactory.iconHaloWidth(expression));
          break;
        case "icon-ignore-placement":
          properties.add(PropertyFactory.iconIgnorePlacement(expression));
          break;
        case "icon-image":
          properties.add(PropertyFactory.iconImage(expression));
          break;
        case "icon-keep-upright":
          properties.add(PropertyFactory.iconKeepUpright(expression));
          break;
        case "icon-offset":
          properties.add(PropertyFactory.iconOffset(expression));
          break;
        case "icon-opacity":
          properties.add(PropertyFactory.iconOpacity(expression));
          break;
        case "icon-optional":
          properties.add(PropertyFactory.iconOptional(expression));
          break;
        case "icon-padding":
          properties.add(PropertyFactory.iconPadding(expression));
          break;
        case "icon-pitch-alignment":
          properties.add(PropertyFactory.iconPitchAlignment(expression));
          break;
        case "icon-rotate":
          properties.add(PropertyFactory.iconRotate(expression));
          break;
        case "icon-rotation-alignment":
          properties.add(PropertyFactory.iconRotationAlignment(expression));
          break;
        case "icon-size":
          properties.add(PropertyFactory.iconSize(expression));
          break;
        case "icon-text-fit":
          properties.add(PropertyFactory.iconTextFit(expression));
          break;
        case "icon-text-fit-padding":
          properties.add(PropertyFactory.iconTextFitPadding(expression));
          break;
        case "icon-translate":
          properties.add(PropertyFactory.iconTranslate(expression));
          break;
        case "icon-translate-anchor":
          properties.add(PropertyFactory.iconTranslateAnchor(expression));
          break;
        case "symbol-avoid-edges":
          properties.add(PropertyFactory.symbolAvoidEdges(expression));
          break;
        case "symbol-placement":
          properties.add(PropertyFactory.symbolPlacement(expression));
          break;
        case "symbol-sort-key":
          properties.add(PropertyFactory.symbolSortKey(expression));
          break;
        case "symbol-spacing":
          properties.add(PropertyFactory.symbolSpacing(expression));
          break;
        case "symbol-z-order":
          properties.add(PropertyFactory.symbolZOrder(expression));
          break;
        case "text-allow-overlap":
          properties.add(PropertyFactory.textAllowOverlap(expression));
          break;
        case "text-anchor":
          properties.add(PropertyFactory.textAnchor(expression));
          break;
        case "text-color":
          properties.add(PropertyFactory.textColor(expression));
          break;
        case "text-field":
          properties.add(PropertyFactory.textField(expression));
          break;
        case "text-font":
          properties.add(PropertyFactory.textFont(expression));
          break;
        case "text-halo-blur":
          properties.add(PropertyFactory.textHaloBlur(expression));
          break;
        case "text-halo-color":
          properties.add(PropertyFactory.textHaloColor(expression));
          break;
        case "text-halo-width":
          properties.add(PropertyFactory.textHaloWidth(expression));
          break;
        case "text-ignore-placement":
          properties.add(PropertyFactory.textIgnorePlacement(expression));
          break;
        case "text-justify":
          properties.add(PropertyFactory.textJustify(expression));
          break;
        case "text-keep-upright":
          properties.add(PropertyFactory.textKeepUpright(expression));
          break;
        case "text-letter-spacing":
          properties.add(PropertyFactory.textLetterSpacing(expression));
          break;
        case "text-line-height":
          properties.add(PropertyFactory.textLineHeight(expression));
          break;
        case "text-max-angle":
          properties.add(PropertyFactory.textMaxAngle(expression));
          break;
        case "text-max-width":
          properties.add(PropertyFactory.textMaxWidth(expression));
          break;
        case "text-offset":
          properties.add(PropertyFactory.textOffset(expression));
          break;
        case "text-opacity":
          properties.add(PropertyFactory.textOpacity(expression));
          break;
        case "text-optional":
          properties.add(PropertyFactory.textOptional(expression));
          break;
        case "text-padding":
          properties.add(PropertyFactory.textPadding(expression));
          break;
        case "text-pitch-alignment":
          properties.add(PropertyFactory.textPitchAlignment(expression));
          break;
        case "text-radial-offset":
          properties.add(PropertyFactory.textRadialOffset(expression));
          break;
        case "text-rotate":
          properties.add(PropertyFactory.textRotate(expression));
          break;
        case "text-rotation-alignment":
          properties.add(PropertyFactory.textRotationAlignment(expression));
          break;
        case "text-size":
          properties.add(PropertyFactory.textSize(expression));
          break;
        case "text-transform":
          properties.add(PropertyFactory.textTransform(expression));
          break;
        case "text-translate":
          properties.add(PropertyFactory.textTranslate(expression));
          break;
        case "text-translate-anchor":
          properties.add(PropertyFactory.textTranslateAnchor(expression));
          break;
        case "text-variable-anchor":
          properties.add(PropertyFactory.textVariableAnchor(expression));
          break;
        case "text-writing-mode":
          properties.add(PropertyFactory.textWritingMode(expression));
          break;
        default:
          break;
      }
    }
    
    return properties.toArray(new PropertyValue[properties.size()]);
  }

  static PropertyValue[] interpretLineLayerProperties(Object o) {
    final Map<String, String> data = (Map<String, String>) toMap(o);
    final List<PropertyValue> properties = new LinkedList();

    for (Map.Entry<String, String> entry : data.entrySet()) {
      Expression expression = Expression.Converter.convert(entry.getValue());
      switch(entry.getKey()) {
        case "line-blur":
          properties.add(PropertyFactory.lineBlur(expression));
          break;
        case "line-cap":
          properties.add(PropertyFactory.lineCap(expression));
          break;
        case "line-color":
          properties.add(PropertyFactory.lineColor(expression));
          break;
        case "line-dasharray":
          properties.add(PropertyFactory.lineDasharray(expression));
          break;
        case "line-gap-width":
          properties.add(PropertyFactory.lineGapWidth(expression));
          break;
        case "line-gradient":
          properties.add(PropertyFactory.lineGradient(expression));
          break;
        case "line-join":
          properties.add(PropertyFactory.lineJoin(expression));
          break;
        case "line-miter-limit":
          properties.add(PropertyFactory.lineMiterLimit(expression));
          break;
        case "line-offset":
          properties.add(PropertyFactory.lineOffset(expression));
          break;
        case "line-pattern":
          properties.add(PropertyFactory.linePattern(expression));
          break;
        case "line-round-limit":
          properties.add(PropertyFactory.lineRoundLimit(expression));
          break;
        case "line-translate":
          properties.add(PropertyFactory.lineTranslate(expression));
          break;
        case "line-translate-anchor":
          properties.add(PropertyFactory.lineTranslateAnchor(expression));
          break;
        case "line-width":
          properties.add(PropertyFactory.lineWidth(expression));
          break;
        default:
          break;
      }
    }

    return properties.toArray(new PropertyValue[properties.size()]);
  }
}