package com.mapbox.mapboxgl;

import android.content.Context;

import com.mapbox.mapboxsdk.camera.CameraPosition;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.List;
import java.util.ArrayList;

public class MapboxMapFactory extends PlatformViewFactory {

  private final BinaryMessenger messenger;
  private final MapboxMapsPlugin.LifecycleProvider lifecycleProvider;

  public MapboxMapFactory(BinaryMessenger messenger, MapboxMapsPlugin.LifecycleProvider lifecycleProvider) {
    super(StandardMessageCodec.INSTANCE);
    this.messenger = messenger;
    this.lifecycleProvider = lifecycleProvider;
  }

  @Override
  public PlatformView create(Context context, int id, Object args) {
    Map<String, Object> params = (Map<String, Object>) args;
    final MapboxMapBuilder builder = new MapboxMapBuilder();

    Convert.interpretMapboxMapOptions(params.get("options"), builder, context);
    if (params.containsKey("initialCameraPosition")) {
      CameraPosition position = Convert.toCameraPosition(params.get("initialCameraPosition"));
      builder.setInitialCameraPosition(position);
    }
    if (params.containsKey("annotationOrder")) {
      List<String> annotations = Convert.toAnnotationOrder(params.get("annotationOrder"));
      builder.setAnnotationOrder(annotations);
    }
    if (params.containsKey("annotationConsumeTapEvents")) {
      List<String> annotations = Convert.toAnnotationConsumeTapEvents(params.get("annotationConsumeTapEvents"));
      builder.setAnnotationConsumeTapEvents(annotations);
    }
    return builder.build(id, context, messenger, lifecycleProvider, (String) params.get("accessToken"));
  }
}
