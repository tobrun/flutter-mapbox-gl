part of mapbox_gl_web;

const _mapboxGlCssUrl =
    'https://api.tiles.mapbox.com/mapbox-gl-js/v1.6.1/mapbox-gl.css';

class MapboxMapController extends MapboxGlPlatform
    implements MapboxMapOptionsSink {
  late DivElement _mapElement;

  late Map<String, dynamic> _creationParams;
  late MapboxMap _map;

  List<String> annotationOrder = [];
  late SymbolManager symbolManager;
  late LineManager lineManager;
  late CircleManager circleManager;
  late FillManager fillManager;

  bool _trackCameraPosition = false;
  GeolocateControl? _geolocateControl;
  LatLng? _myLastLocation;

  String? _navigationControlPosition;
  NavigationControl? _navigationControl;

  @override
  Widget buildView(
      Map<String, dynamic> creationParams,
      OnPlatformViewCreatedCallback onPlatformViewCreated,
      Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers) {
    _creationParams = creationParams;
    _registerViewFactory(onPlatformViewCreated, this.hashCode);
    return HtmlElementView(
        viewType: 'plugins.flutter.io/mapbox_gl_${this.hashCode}');
  }

  void _registerViewFactory(Function(int) callback, int identifier) {
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
        'plugins.flutter.io/mapbox_gl_$identifier', (int viewId) {
      _mapElement = DivElement();
      callback(viewId);
      return _mapElement;
    });
  }

  @override
  Future<void> initPlatform(int id) async {
    await _addStylesheetToShadowRoot(_mapElement);
    if (_creationParams.containsKey('initialCameraPosition')) {
      var camera = _creationParams['initialCameraPosition'];
      if (_creationParams.containsKey('accessToken')) {
        Mapbox.accessToken = _creationParams['accessToken'];
      }
      _map = MapboxMap(
        MapOptions(
          container: _mapElement,
          style: 'mapbox://styles/mapbox/streets-v11',
          center: LngLat(camera['target'][1], camera['target'][0]),
          zoom: camera['zoom'],
          bearing: camera['bearing'],
          pitch: camera['tilt'],
        ),
      );
      _map.on('styleimagemissing', this._onStyleImageMissing);
      _map.on('load', _onStyleLoaded);
    }
    Convert.interpretMapboxMapOptions(_creationParams['options'], this);

    if (_creationParams.containsKey('annotationOrder')) {
      annotationOrder = _creationParams['annotationOrder'];
    }
  }

  Future<void> _addStylesheetToShadowRoot(HtmlElement e) async {
    LinkElement link = LinkElement()
      ..href = _mapboxGlCssUrl
      ..rel = 'stylesheet';
    e.append(link);

    await link.onLoad.first;
  }

  void _onStyleImageMissing(dynamic event) {
    _map.addImage(event.id, {
      "data": Uint8List.fromList([0, 0, 0, 0]),
      "height": 1,
      "width": 1
    });
    if (this.onStyleImageMissing != null) {
      this.onStyleImageMissing.call(event.id);
      return;
    }
    var density = context['window'].devicePixelRatio ?? 1;
    var imagePath = density == 1
        ? '/assets/assets/symbols/custom-icon.png'
        : '/assets/assets/symbols/$density.0x/custom-icon.png';
    _map.loadImage(imagePath, (error, image) {
      if (error != null) throw error;
      if (!_map.hasImage(event.id))
        _map.addImage(event.id, image, {'pixelRatio': density});
    });
  }

  @override
  Future<CameraPosition?> updateMapOptions(
      Map<String, dynamic> optionsUpdate) async {
    // FIX: why is called indefinitely? (map_ui page)
    Convert.interpretMapboxMapOptions(optionsUpdate, this);
    return _getCameraPosition();
  }

  @override
  Future<bool?> animateCamera(CameraUpdate cameraUpdate) async {
    final cameraOptions = Convert.toCameraOptions(cameraUpdate, _map);
    _map.flyTo(cameraOptions);
    return true;
  }

  @override
  Future<bool?> moveCamera(CameraUpdate cameraUpdate) async {
    final cameraOptions = Convert.toCameraOptions(cameraUpdate, _map);
    _map.jumpTo(cameraOptions);
    return true;
  }

  @override
  Future<void> updateMyLocationTrackingMode(
      MyLocationTrackingMode myLocationTrackingMode) async {
    setMyLocationTrackingMode(myLocationTrackingMode.index);
  }

  @override
  Future<void> matchMapLanguageWithDeviceDefault() async {
    setMapLanguage(ui.window.locale!.languageCode);
  }

  @override
  Future<void> setMapLanguage(String language) async {
    _map.setLayoutProperty(
      'country-label',
      'text-field',
      ['get', 'name_' + language],
    );
  }

  @override
  Future<void> setTelemetryEnabled(bool enabled) async {
    print('Telemetry not available in web');
    return;
  }

  @override
  Future<bool> getTelemetryEnabled() async {
    print('Telemetry not available in web');
    return false;
  }

  @override
  Future<List<Symbol>> addSymbols(List<SymbolOptions> options,
      [List<Map>? data]) async {
    Map<String, SymbolOptions> optionsById = {
      for (final o in options)
        symbolManager.add(Feature(
          geometry: Geometry(
            type: 'Point',
            coordinates: [o.geometry!.longitude, o.geometry!.latitude],
          ),
        )): o,
    };
    symbolManager.updateAll(optionsById);

    return optionsById
        .map((id, singleOptions) {
          int dataIndex = options.indexOf(singleOptions);
          Map? singleData = data != null && data.length >= dataIndex + 1
              ? data[dataIndex]
              : null;
          return MapEntry(id, Symbol(id, singleOptions, singleData));
        })
        .values
        .toList();
  }

  @override
  Future<void> updateSymbol(Symbol symbol, SymbolOptions changes) async {
    symbolManager.update(symbol.id, changes);
  }

  @override
  Future<void> removeSymbols(Iterable<String> symbolsIds) async {
    symbolManager.removeAll(symbolsIds);
  }

  @override
  Future<Line> addLine(LineOptions options, [Map? data]) async {
    String lineId = lineManager.add(Feature(
      geometry: Geometry(
        type: 'LineString',
        coordinates: options.geometry!
            .map((latLng) => [latLng.longitude, latLng.latitude])
            .toList(),
      ),
    ));
    lineManager.update(lineId, options);
    return Line(lineId, options, data);
  }

  @override
  Future<void> updateLine(Line line, LineOptions changes) async {
    lineManager.update(line.id, changes);
  }

  @override
  Future<void> removeLine(String lineId) async {
    lineManager.remove(lineId);
  }

  @override
  Future<void> removeLines(Iterable<String> ids) async {
    lineManager.removeAll(ids);
  }

  @override
  Future<Circle> addCircle(CircleOptions options, [Map? data]) async {
    String circleId = circleManager.add(Feature(
      geometry: Geometry(
        type: 'Point',
        coordinates: [options.geometry!.longitude, options.geometry!.latitude],
      ),
    ));
    circleManager.update(circleId, options);
    return Circle(circleId, options, data);
  }

  @override
  Future<void> updateCircle(Circle circle, CircleOptions changes) async {
    circleManager.update(circle.id, changes);
  }

  @override
  Future<LatLng> getCircleLatLng(Circle circle) async {
    var coordinates = circleManager.getFeature(circle.id)!.geometry.coordinates;
    return LatLng(coordinates[1], coordinates[0]);
  }

  @override
  Future<void> removeCircle(String circleId) async {
    circleManager.remove(circleId);
  }

  @override
  Future<void> removeCircles(Iterable<String> ids) async {
    circleManager.removeAll(ids);
  }

  Future<Fill> addFill(FillOptions options, [Map? data]) async {
    String fillId = fillManager.add(Feature(
      geometry: Geometry(
        type: 'Polygon',
        coordinates: Convert.fillGeometryToFeatureGeometry(options.geometry!),
      ),
    ));

    fillManager.update(fillId, options);
    return Fill(fillId, options, data);
  }

  Future<void> updateFill(Fill fill, FillOptions changes) async {
    fillManager.update(fill.id, changes);
  }

  Future<void> removeFill(String fillId) async {
    fillManager.remove(fillId);
  }

  @override
  Future<void> removeFills(Iterable<String> ids) async {
    fillManager.removeAll(ids);
  }

  @override
  Future<List> queryRenderedFeatures(
      Point<double> point, List<String> layerIds, List<Object>? filter) async {
    Map<String, dynamic> options = {};
    if (layerIds.length > 0) {
      options['layers'] = layerIds;
    }
    if (filter != null) {
      options['filter'] = filter;
    }
    return _map
        .queryRenderedFeatures([point, point], options)
        .map((feature) => {
              'type': 'Feature',
              'id': feature.id as int?,
              'geometry': {
                'type': feature.geometry.type,
                'coordinates': feature.geometry.coordinates,
              },
              'properties': feature.properties,
              'source': feature.source,
            })
        .toList();
  }

  @override
  Future<List> queryRenderedFeaturesInRect(
      Rect rect, List<String> layerIds, String? filter) async {
    Map<String, dynamic> options = {};
    if (layerIds.length > 0) {
      options['layers'] = layerIds;
    }
    if (filter != null) {
      options['filter'] = filter;
    }
    return _map
        .queryRenderedFeatures([
          Point(rect.left, rect.bottom),
          Point(rect.right, rect.top),
        ], options)
        .map((feature) => {
              'type': 'Feature',
              'id': feature.id as int?,
              'geometry': {
                'type': feature.geometry.type,
                'coordinates': feature.geometry.coordinates,
              },
              'properties': feature.properties,
              'source': feature.source,
            })
        .toList();
  }

  @override
  Future invalidateAmbientCache() async {
    print('Offline storage not available in web');
  }

  @override
  Future<LatLng?> requestMyLocationLatLng() async {
    return _myLastLocation;
  }

  @override
  Future<LatLngBounds> getVisibleRegion() async {
    final bounds = _map.getBounds();
    return LatLngBounds(
      southwest: LatLng(
        bounds.getSouthWest().lat as double,
        bounds.getSouthWest().lng as double,
      ),
      northeast: LatLng(
        bounds.getNorthEast().lat as double,
        bounds.getNorthEast().lng as double,
      ),
    );
  }

  @override
  Future<void> addImage(String name, Uint8List bytes,
      [bool sdf = false]) async {
    final photo = decodeImage(bytes)!;
    if (_map.hasImage(name)) {
      _map.removeImage(name);
    }
    _map.addImage(
      name,
      {
        'width': photo.width,
        'height': photo.height,
        'data': photo.getBytes(),
      },
      {'sdf': sdf},
    );
  }

  @override
  Future<void> setSymbolIconAllowOverlap(bool enable) async {
    //TODO: to implement
    print('setSymbolIconAllowOverlap not implemented yet');
  }

  @override
  Future<void> setSymbolIconIgnorePlacement(bool enable) async {
    //TODO: to implement
    print('setSymbolIconIgnorePlacement not implemented yet');
  }

  @override
  Future<void> setSymbolTextAllowOverlap(bool enable) async {
    //TODO: to implement
    print('setSymbolTextAllowOverlap not implemented yet');
  }

  @override
  Future<void> setSymbolTextIgnorePlacement(bool enable) async {
    //TODO: to implement
    print('setSymbolTextIgnorePlacement not implemented yet');
  }

  CameraPosition? _getCameraPosition() {
    if (_trackCameraPosition) {
      final center = _map.getCenter();
      return CameraPosition(
        bearing: _map.getBearing() as double,
        target: LatLng(center.lat as double, center.lng as double),
        tilt: _map.getPitch() as double,
        zoom: _map.getZoom() as double,
      );
    }
    return null;
  }

  void _onStyleLoaded(_) {
    for (final annotationType in annotationOrder) {
      switch (annotationType) {
        case 'AnnotationType.symbol':
          symbolManager = SymbolManager(
              map: _map,
              onTap: onSymbolTappedPlatform,
              onStyleImageMissing: this.onStyleImageMissing);
          break;
        case 'AnnotationType.line':
          lineManager = LineManager(map: _map, onTap: onLineTappedPlatform);
          break;
        case 'AnnotationType.circle':
          circleManager =
              CircleManager(map: _map, onTap: onCircleTappedPlatform);
          break;
        case 'AnnotationType.fill':
          fillManager = FillManager(map: _map, onTap: onFillTappedPlatform);
          break;
        default:
          print(
              "Unknown annotation type: \(annotationType), must be either 'fill', 'line', 'circle' or 'symbol'");
      }
    }

    onMapStyleLoadedPlatform(null);
    _map.on('click', _onMapClick);
    // long click not available in web, so it is mapped to double click
    _map.on('dblclick', _onMapLongClick);
    _map.on('movestart', _onCameraMoveStarted);
    _map.on('move', _onCameraMove);
    _map.on('moveend', _onCameraIdle);
    _map.on('resize', _onMapResize);
  }

  void _onMapResize(Event e) {
    Timer(Duration(microseconds: 10), () {
      var container = _map.getContainer();
      var canvas = _map.getCanvas();
      var widthMismatch = canvas.clientWidth != container.clientWidth;
      var heightMismatch = canvas.clientHeight != container.clientHeight;
      if (widthMismatch || heightMismatch) {
        _map.resize();
      }
    });
  }

  void _onMapClick(e) {
    onMapClickPlatform({
      'point': Point<double>(e.point.x, e.point.y),
      'latLng': LatLng(e.lngLat.lat, e.lngLat.lng),
    });
  }

  void _onMapLongClick(e) {
    onMapLongClickPlatform({
      'point': Point<double>(e.point.x, e.point.y),
      'latLng': LatLng(e.lngLat.lat, e.lngLat.lng),
    });
  }

  void _onCameraMoveStarted(_) {
    onCameraMoveStartedPlatform(null);
  }

  void _onCameraMove(_) {
    final center = _map.getCenter();
    var camera = CameraPosition(
      bearing: _map.getBearing() as double,
      target: LatLng(center.lat as double, center.lng as double),
      tilt: _map.getPitch() as double,
      zoom: _map.getZoom() as double,
    );
    onCameraMovePlatform(camera);
  }

  void _onCameraIdle(_) {
    final center = _map.getCenter();
    var camera = CameraPosition(
      bearing: _map.getBearing() as double,
      target: LatLng(center.lat as double, center.lng as double),
      tilt: _map.getPitch() as double,
      zoom: _map.getZoom() as double,
    );
    onCameraIdlePlatform(camera);
  }

  void _onCameraTrackingChanged(bool isTracking) {
    if (isTracking) {
      onCameraTrackingChangedPlatform(MyLocationTrackingMode.Tracking);
    } else {
      onCameraTrackingChangedPlatform(MyLocationTrackingMode.None);
    }
  }

  void _onCameraTrackingDismissed() {
    onCameraTrackingDismissedPlatform(null);
  }

  void _addGeolocateControl({bool trackUserLocation = false}) {
    _removeGeolocateControl();
    _geolocateControl = GeolocateControl(
      GeolocateControlOptions(
        positionOptions: PositionOptions(enableHighAccuracy: true),
        trackUserLocation: trackUserLocation,
        showAccuracyCircle: true,
        showUserLocation: true,
      ),
    );
    _geolocateControl!.on('geolocate', (e) {
      _myLastLocation = LatLng(e.coords.latitude, e.coords.longitude);
      onUserLocationUpdatedPlatform(UserLocation(
          position: LatLng(e.coords.latitude, e.coords.longitude),
          altitude: e.coords.altitude,
          bearing: e.coords.heading,
          speed: e.coords.speed,
          horizontalAccuracy: e.coords.accuracy,
          verticalAccuracy: e.coords.altitudeAccuracy,
          heading: null,
          timestamp: DateTime.fromMillisecondsSinceEpoch(e.timestamp)));
    });
    _geolocateControl!.on('trackuserlocationstart', (_) {
      _onCameraTrackingChanged(true);
    });
    _geolocateControl!.on('trackuserlocationend', (_) {
      _onCameraTrackingChanged(false);
      _onCameraTrackingDismissed();
    });
    _map.addControl(_geolocateControl, 'bottom-right');
  }

  void _removeGeolocateControl() {
    if (_geolocateControl != null) {
      _map.removeControl(_geolocateControl);
      _geolocateControl = null;
    }
  }

  void _updateNavigationControl({
    bool? compassEnabled,
    CompassViewPosition? position,
  }) {
    bool? prevShowCompass;
    if (_navigationControl != null) {
      prevShowCompass = _navigationControl!.options.showCompass;
    }
    String? prevPosition = _navigationControlPosition;

    String? positionString;
    switch (position) {
      case CompassViewPosition.TopRight:
        positionString = 'top-right';
        break;
      case CompassViewPosition.TopLeft:
        positionString = 'top-left';
        break;
      case CompassViewPosition.BottomRight:
        positionString = 'bottom-right';
        break;
      case CompassViewPosition.BottomLeft:
        positionString = 'bottom-left';
        break;
      default:
        positionString = null;
    }

    bool newShowComapss = compassEnabled ?? prevShowCompass ?? false;
    String? newPosition = positionString ?? prevPosition ?? null;

    _removeNavigationControl();
    _navigationControl = NavigationControl(NavigationControlOptions(
      showCompass: newShowComapss,
      showZoom: false,
      visualizePitch: false,
    ));

    if (newPosition == null) {
      _map.addControl(_navigationControl);
    } else {
      _map.addControl(_navigationControl, newPosition);
      _navigationControlPosition = newPosition;
    }
  }

  void _removeNavigationControl() {
    if (_navigationControl != null) {
      _map.removeControl(_navigationControl);
      _navigationControl = null;
    }
  }

  /*
   *  MapboxMapOptionsSink
   */
  @override
  void setAttributionButtonMargins(int x, int y) {
    print('setAttributionButtonMargins not available in web');
  }

  @override
  void setCameraTargetBounds(LatLngBounds? bounds) {
    if (bounds == null) {
      _map.setMaxBounds(null);
    } else {
      _map.setMaxBounds(
        LngLatBounds(
          LngLat(
            bounds.southwest.longitude,
            bounds.southwest.latitude,
          ),
          LngLat(
            bounds.northeast.longitude,
            bounds.northeast.latitude,
          ),
        ),
      );
    }
  }

  @override
  void setCompassEnabled(bool compassEnabled) {
    _updateNavigationControl(compassEnabled: compassEnabled);
  }

  @override
  void setCompassGravity(int gravity) {
    _updateNavigationControl(position: CompassViewPosition.values[gravity]);
  }

  @override
  void setCompassViewMargins(int x, int y) {
    print('setCompassViewMargins not available in web');
  }

  @override
  void setLogoViewMargins(int x, int y) {
    print('setLogoViewMargins not available in web');
  }

  @override
  void setMinMaxZoomPreference(num? min, num? max) {
    // FIX: why is called indefinitely? (map_ui page)
    _map.setMinZoom(min);
    _map.setMaxZoom(max);
  }

  @override
  void setMyLocationEnabled(bool myLocationEnabled) {
    if (myLocationEnabled) {
      _addGeolocateControl(trackUserLocation: false);
    } else {
      _removeGeolocateControl();
    }
  }

  @override
  void setMyLocationRenderMode(int myLocationRenderMode) {
    print('myLocationRenderMode not available in web');
  }

  @override
  void setMyLocationTrackingMode(int myLocationTrackingMode) {
    if (_geolocateControl == null) {
      //myLocationEnabled is false, ignore myLocationTrackingMode
      return;
    }
    if (myLocationTrackingMode == 0) {
      _addGeolocateControl(trackUserLocation: false);
    } else {
      print('Only one tracking mode available in web');
      _addGeolocateControl(trackUserLocation: true);
    }
  }

  @override
  void setRotateGesturesEnabled(bool rotateGesturesEnabled) {
    if (rotateGesturesEnabled) {
      _map.dragRotate.enable();
      _map.touchZoomRotate.enableRotation();
      _map.keyboard.enable();
    } else {
      _map.dragRotate.disable();
      _map.touchZoomRotate.disableRotation();
      _map.keyboard.disable();
    }
  }

  @override
  void setScrollGesturesEnabled(bool scrollGesturesEnabled) {
    if (scrollGesturesEnabled) {
      _map.dragPan.enable();
      _map.keyboard.enable();
    } else {
      _map.dragPan.disable();
      _map.keyboard.disable();
    }
  }

  @override
  void setStyleString(String? styleString) {
    _map.setStyle(styleString);
  }

  @override
  void setTiltGesturesEnabled(bool tiltGesturesEnabled) {
    if (tiltGesturesEnabled) {
      _map.dragRotate.enable();
      _map.keyboard.enable();
    } else {
      _map.dragRotate.disable();
      _map.keyboard.disable();
    }
  }

  @override
  void setTrackCameraPosition(bool trackCameraPosition) {
    _trackCameraPosition = trackCameraPosition;
  }

  @override
  void setZoomGesturesEnabled(bool zoomGesturesEnabled) {
    if (zoomGesturesEnabled) {
      _map.doubleClickZoom.enable();
      _map.boxZoom.enable();
      _map.scrollZoom.enable();
      _map.touchZoomRotate.enable();
      _map.keyboard.enable();
    } else {
      _map.doubleClickZoom.disable();
      _map.boxZoom.disable();
      _map.scrollZoom.disable();
      _map.touchZoomRotate.disable();
      _map.keyboard.disable();
    }
  }

  @override
  Future<Point> toScreenLocation(LatLng latLng) async {
    var screenPosition =
        _map.project(LngLat(latLng.longitude, latLng.latitude));
    return Point(screenPosition.x.round(), screenPosition.y.round());
  }

  @override
  Future<List<Point>> toScreenLocationBatch(Iterable<LatLng> latLngs) async {
    return latLngs.map((latLng) {
      var screenPosition =
          _map.project(LngLat(latLng.longitude, latLng.latitude));
      return Point(screenPosition.x.round(), screenPosition.y.round());
    }).toList(growable: false);
  }

  @override
  Future<LatLng> toLatLng(Point screenLocation) async {
    var lngLat =
        _map.unproject(mapbox.Point(screenLocation.x, screenLocation.y));
    return LatLng(lngLat.lat as double, lngLat.lng as double);
  }

  @override
  Future<double> getMetersPerPixelAtLatitude(double latitude) async {
    //https://wiki.openstreetmap.org/wiki/Zoom_levels
    var circumference = 40075017.686;
    var zoom = _map.getZoom();
    return circumference * cos(latitude * (pi / 180)) / pow(2, zoom + 9);
  }
}
