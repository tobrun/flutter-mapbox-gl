// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of mapbox_gl;

enum AnnotationType { fill, line, circle, symbol }

typedef void MapCreatedCallback(MapboxMapController controller);

class MapboxMap extends StatefulWidget {
  const MapboxMap({
    Key? key,
    required this.initialCameraPosition,
    this.accessToken,
    this.onMapCreated,
    this.onStyleLoadedCallback,
    this.gestureRecognizers,
    this.compassEnabled = true,
    this.cameraTargetBounds = CameraTargetBounds.unbounded,
    this.styleString,
    this.minMaxZoomPreference = MinMaxZoomPreference.unbounded,
    this.rotateGesturesEnabled = true,
    this.scrollGesturesEnabled = true,
    this.zoomGesturesEnabled = true,
    this.tiltGesturesEnabled = true,
    this.trackCameraPosition = false,
    this.myLocationEnabled = false,
    this.myLocationTrackingMode = MyLocationTrackingMode.None,
    this.myLocationRenderMode = MyLocationRenderMode.COMPASS,
    this.logoViewMargins,
    this.compassViewPosition,
    this.compassViewMargins,
    this.attributionButtonMargins,
    this.onMapClick,
    this.onUserLocationUpdated,
    this.onMapLongClick,
    this.onStyleImageMissing,
    this.onAttributionClick,
    this.onCameraTrackingDismissed,
    this.onCameraTrackingChanged,
    this.onCameraIdle,
    this.onMapIdle,
    this.annotationOrder = const [
      AnnotationType.line,
      AnnotationType.symbol,
      AnnotationType.circle,
      AnnotationType.fill,
    ],
    this.annotationConsumeTapEvents = const [
      AnnotationType.symbol,
      AnnotationType.fill,
      AnnotationType.line,
      AnnotationType.circle,
    ],
  })  : assert(annotationOrder.length == 4),
        assert(annotationConsumeTapEvents.length > 0),
        super(key: key);

  /// Defined the layer order of annotations displayed on map
  /// (must contain all annotation types, 4 items)
  final List<AnnotationType> annotationOrder;

  /// Defined the layer order of click annotations
  /// (must contain at least 1 annotation type, 4 items max)
  final List<AnnotationType> annotationConsumeTapEvents;

  /// If you want to use Mapbox hosted styles and map tiles, you need to provide a Mapbox access token.
  /// Obtain a free access token on [your Mapbox account page](https://www.mapbox.com/account/access-tokens/).
  /// The reccommended way is to use this parameter to set your access token, an alternative way to add your access tokens through external files is described in the plugin's wiki on Github.
  ///
  /// Note: You should not use this parameter AND set the access token through external files at the same time, and you should use the same token throughout the entire app.
  final String? accessToken;

  /// Please note: you should only add annotations (e.g. symbols or circles) after `onStyleLoadedCallback` has been called.
  final MapCreatedCallback? onMapCreated;

  /// Called when the map style has been successfully loaded and the annotation managers have been enabled.
  /// Please note: you should only add annotations (e.g. symbols or circles) after this callback has been called.
  final OnStyleLoadedCallback? onStyleLoadedCallback;

  /// The initial position of the map's camera.
  final CameraPosition initialCameraPosition;

  /// True if the map should show a compass when rotated.
  final bool compassEnabled;

  /// Geographical bounding box for the camera target.
  final CameraTargetBounds cameraTargetBounds;

  /// Style URL or Style JSON
  /// Can be a MapboxStyle constant, any Mapbox Style URL,
  /// or a StyleJSON (https://docs.mapbox.com/mapbox-gl-js/style-spec/)
  final String? styleString;

  /// Preferred bounds for the camera zoom level.
  ///
  /// Actual bounds depend on map data and device.
  final MinMaxZoomPreference minMaxZoomPreference;

  /// True if the map view should respond to rotate gestures.
  final bool rotateGesturesEnabled;

  /// True if the map view should respond to scroll gestures.
  final bool scrollGesturesEnabled;

  /// True if the map view should respond to zoom gestures.
  final bool zoomGesturesEnabled;

  /// True if the map view should respond to tilt gestures.
  final bool tiltGesturesEnabled;

  /// True if you want to be notified of map camera movements by the MapboxMapController. Default is false.
  ///
  /// If this is set to true and the user pans/zooms/rotates the map, MapboxMapController (which is a ChangeNotifier)
  /// will notify it's listeners and you can then get the new MapboxMapController.cameraPosition.
  final bool trackCameraPosition;

  /// True if a "My Location" layer should be shown on the map.
  ///
  /// This layer includes a location indicator at the current device location,
  /// as well as a My Location button.
  /// * The indicator is a small blue dot if the device is stationary, or a
  /// chevron if the device is moving.
  /// * The My Location button animates to focus on the user's current location
  /// if the user's location is currently known.
  ///
  /// Enabling this feature requires adding location permissions to both native
  /// platforms of your app.
  /// * On Android add either
  /// `<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />`
  /// or `<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />`
  /// to your `AndroidManifest.xml` file. `ACCESS_COARSE_LOCATION` returns a
  /// location with an accuracy approximately equivalent to a city block, while
  /// `ACCESS_FINE_LOCATION` returns as precise a location as possible, although
  /// it consumes more battery power. You will also need to request these
  /// permissions during run-time. If they are not granted, the My Location
  /// feature will fail silently.
  /// * On iOS add a `NSLocationWhenInUseUsageDescription` key to your
  /// `Info.plist` file. This will automatically prompt the user for permissions
  /// when the map tries to turn on the My Location layer.
  final bool myLocationEnabled;

  /// The mode used to let the map's camera follow the device's physical location.
  /// `myLocationEnabled` needs to be true for values other than `MyLocationTrackingMode.None` to work.
  final MyLocationTrackingMode myLocationTrackingMode;

  /// The mode to render the user location symbol
  final MyLocationRenderMode myLocationRenderMode;

  /// Set the layout margins for the Mapbox Logo
  final Point? logoViewMargins;

  /// Set the position for the Mapbox Compass
  final CompassViewPosition? compassViewPosition;

  /// Set the layout margins for the Mapbox Compass
  final Point? compassViewMargins;

  /// Set the layout margins for the Mapbox Attribution Buttons
  final Point? attributionButtonMargins;

  /// Which gestures should be consumed by the map.
  ///
  /// It is possible for other gesture recognizers to be competing with the map on pointer
  /// events, e.g if the map is inside a [ListView] the [ListView] will want to handle
  /// vertical drags. The map will claim gestures that are recognized by any of the
  /// recognizers on this list.
  ///
  /// When this set is empty or null, the map will only handle pointer events for gestures that
  /// were not claimed by any other gesture recognizer.
  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;

  final OnMapClickCallback? onMapClick;
  final OnMapClickCallback? onMapLongClick;
  final OnStyleImageMissingCallback? onStyleImageMissing;

  final OnAttributionClickCallback? onAttributionClick;

  /// While the `myLocationEnabled` property is set to `true`, this method is
  /// called whenever a new location update is received by the map view.
  final OnUserLocationUpdated? onUserLocationUpdated;

  /// Called when the map's camera no longer follows the physical device location, e.g. because the user moved the map
  final OnCameraTrackingDismissedCallback? onCameraTrackingDismissed;

  /// Called when the location tracking mode changes
  final OnCameraTrackingChangedCallback? onCameraTrackingChanged;

  // Called when camera movement has ended.
  final OnCameraIdleCallback? onCameraIdle;

  /// Called when map view is entering an idle state, and no more drawing will
  /// be necessary until new data is loaded or there is some interaction with
  /// the map.
  /// * No camera transitions are in progress
  /// * All currently requested tiles have loaded
  /// * All fade/transition animations have completed
  final OnMapIdleCallback? onMapIdle;

  @override
  State createState() => _MapboxMapState();
}

class _MapboxMapState extends State<MapboxMap> {
  final Completer<MapboxMapController> _controller =
      Completer<MapboxMapController>();

  late _MapboxMapOptions _mapboxMapOptions;
  final MapboxGlPlatform _mapboxGlPlatform = MapboxGlPlatform.createInstance();

  @override
  Widget build(BuildContext context) {
    final List<String> annotationOrder =
        widget.annotationOrder.map((e) => e.toString()).toList();
    final List<String> annotationConsumeTapEvents =
        widget.annotationConsumeTapEvents.map((e) => e.toString()).toList();

    final Map<String, dynamic> creationParams = <String, dynamic>{
      'initialCameraPosition': widget.initialCameraPosition.toMap(),
      'options': _MapboxMapOptions.fromWidget(widget).toMap(),
      'accessToken': widget.accessToken,
      'annotationOrder': annotationOrder,
      'annotationConsumeTapEvents': annotationConsumeTapEvents,
      'onAttributionClickOverride': widget.onAttributionClick != null,
    };
    return _mapboxGlPlatform.buildView(
        creationParams, onPlatformViewCreated, widget.gestureRecognizers);
  }

  @override
  void initState() {
    super.initState();
    _mapboxMapOptions = _MapboxMapOptions.fromWidget(widget);
  }

  @override
  void didUpdateWidget(MapboxMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final _MapboxMapOptions newOptions = _MapboxMapOptions.fromWidget(widget);
    final Map<String, dynamic> updates =
        _mapboxMapOptions.updatesMap(newOptions);
    _updateOptions(updates);
    _mapboxMapOptions = newOptions;
  }

  void _updateOptions(Map<String, dynamic> updates) async {
    if (updates.isEmpty) {
      return;
    }
    final MapboxMapController controller = await _controller.future;
    controller._updateMapOptions(updates);
  }

  Future<void> onPlatformViewCreated(int id) async {
    MapboxGlPlatform.addInstance(id, _mapboxGlPlatform);
    final MapboxMapController controller = MapboxMapController.init(
      id,
      widget.initialCameraPosition,
      onStyleLoadedCallback: () {
        if (_controller.isCompleted) {
          if (widget.onStyleLoadedCallback != null) {
            widget.onStyleLoadedCallback!();
          }
        } else {
          _controller.future.then((_) {
            if (widget.onStyleLoadedCallback != null) {
              widget.onStyleLoadedCallback!();
            }
          });
        }
      },
      onMapClick: widget.onMapClick,
      onUserLocationUpdated: widget.onUserLocationUpdated,
      onMapLongClick: widget.onMapLongClick,
      onAttributionClick: widget.onAttributionClick,
      onCameraTrackingDismissed: widget.onCameraTrackingDismissed,
      onCameraTrackingChanged: widget.onCameraTrackingChanged,
      onCameraIdle: widget.onCameraIdle,
      onMapIdle: widget.onMapIdle,
      onStyleImageMissing: widget.onStyleImageMissing,
    );
    await MapboxMapController.initPlatform(id);
    _controller.complete(controller);
    if (widget.onMapCreated != null) {
      widget.onMapCreated!(controller);
    }
  }
}

/// Configuration options for the MapboxMaps user interface.
///
/// When used to change configuration, null values will be interpreted as
/// "do not change this configuration option".
class _MapboxMapOptions {
  _MapboxMapOptions({
    this.compassEnabled,
    this.cameraTargetBounds,
    this.styleString,
    this.minMaxZoomPreference,
    this.rotateGesturesEnabled,
    this.scrollGesturesEnabled,
    this.tiltGesturesEnabled,
    this.trackCameraPosition,
    this.zoomGesturesEnabled,
    this.myLocationEnabled,
    this.myLocationTrackingMode,
    this.myLocationRenderMode,
    this.logoViewMargins,
    this.compassViewPosition,
    this.compassViewMargins,
    this.attributionButtonMargins,
  });

  static _MapboxMapOptions fromWidget(MapboxMap map) {
    return _MapboxMapOptions(
      compassEnabled: map.compassEnabled,
      cameraTargetBounds: map.cameraTargetBounds,
      styleString: map.styleString,
      minMaxZoomPreference: map.minMaxZoomPreference,
      rotateGesturesEnabled: map.rotateGesturesEnabled,
      scrollGesturesEnabled: map.scrollGesturesEnabled,
      tiltGesturesEnabled: map.tiltGesturesEnabled,
      trackCameraPosition: map.trackCameraPosition,
      zoomGesturesEnabled: map.zoomGesturesEnabled,
      myLocationEnabled: map.myLocationEnabled,
      myLocationTrackingMode: map.myLocationTrackingMode,
      myLocationRenderMode: map.myLocationRenderMode,
      logoViewMargins: map.logoViewMargins,
      compassViewPosition: map.compassViewPosition,
      compassViewMargins: map.compassViewMargins,
      attributionButtonMargins: map.attributionButtonMargins,
    );
  }

  final bool? compassEnabled;

  final CameraTargetBounds? cameraTargetBounds;

  final String? styleString;

  final MinMaxZoomPreference? minMaxZoomPreference;

  final bool? rotateGesturesEnabled;

  final bool? scrollGesturesEnabled;

  final bool? tiltGesturesEnabled;

  final bool? trackCameraPosition;

  final bool? zoomGesturesEnabled;

  final bool? myLocationEnabled;

  final MyLocationTrackingMode? myLocationTrackingMode;

  final MyLocationRenderMode? myLocationRenderMode;

  final Point? logoViewMargins;

  final CompassViewPosition? compassViewPosition;

  final Point? compassViewMargins;

  final Point? attributionButtonMargins;

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> optionsMap = <String, dynamic>{};

    void addIfNonNull(String fieldName, dynamic value) {
      if (value != null) {
        optionsMap[fieldName] = value;
      }
    }

    List<dynamic>? pointToArray(Point? fieldName) {
      if (fieldName != null) {
        return <dynamic>[fieldName.x, fieldName.y];
      }

      return null;
    }

    addIfNonNull('compassEnabled', compassEnabled);
    addIfNonNull('cameraTargetBounds', cameraTargetBounds?.toJson());
    addIfNonNull('styleString', styleString);
    addIfNonNull('minMaxZoomPreference', minMaxZoomPreference?.toJson());
    addIfNonNull('rotateGesturesEnabled', rotateGesturesEnabled);
    addIfNonNull('scrollGesturesEnabled', scrollGesturesEnabled);
    addIfNonNull('tiltGesturesEnabled', tiltGesturesEnabled);
    addIfNonNull('zoomGesturesEnabled', zoomGesturesEnabled);
    addIfNonNull('trackCameraPosition', trackCameraPosition);
    addIfNonNull('myLocationEnabled', myLocationEnabled);
    addIfNonNull('myLocationTrackingMode', myLocationTrackingMode?.index);
    addIfNonNull('myLocationRenderMode', myLocationRenderMode?.index);
    addIfNonNull('logoViewMargins', pointToArray(logoViewMargins));
    addIfNonNull('compassViewPosition', compassViewPosition?.index);
    addIfNonNull('compassViewMargins', pointToArray(compassViewMargins));
    addIfNonNull(
        'attributionButtonMargins', pointToArray(attributionButtonMargins));
    return optionsMap;
  }

  Map<String, dynamic> updatesMap(_MapboxMapOptions newOptions) {
    final Map<String, dynamic> prevOptionsMap = toMap();
    return newOptions.toMap()
      ..removeWhere(
          (String key, dynamic value) => prevOptionsMap[key] == value);
  }
}
