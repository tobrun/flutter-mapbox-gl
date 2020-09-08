part of mapbox_gl_platform_interface;

class MethodChannelMapboxGl extends MapboxGlPlatform {
  MethodChannel _channel;

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'infoWindow#onTap':
        final String symbolId = call.arguments['symbol'];
        if (symbolId != null) {
          onInfoWindowTappedPlatform(symbolId);
        }
        break;
      case 'symbol#onTap':
        final String symbolId = call.arguments['symbol'];
        if (symbolId != null) {
          onSymbolTappedPlatform(symbolId);
        }
        break;
      case 'line#onTap':
        final String lineId = call.arguments['line'];
        if (lineId != null) {
          onLineTappedPlatform(lineId);
        }
        break;
      case 'circle#onTap':
        final String circleId = call.arguments['circle'];
        if (circleId != null) {
          onCircleTappedPlatform(circleId);
        }
        break;
      case 'camera#onMoveStarted':
        onCameraMoveStartedPlatform(null);
        break;
      case 'camera#onMove':
        final CameraPosition cameraPosition =
            CameraPosition.fromMap(call.arguments['position']);
        onCameraMovePlatform(cameraPosition);
        break;
      case 'camera#onIdle':
        onCameraIdlePlatform(null);
        break;
      case 'map#onStyleLoaded':
        onMapStyleLoadedPlatform(null);
        break;
      case 'map#onMapClick':
        final double x = call.arguments['x'];
        final double y = call.arguments['y'];
        final double lng = call.arguments['lng'];
        final double lat = call.arguments['lat'];
        onMapClickPlatform(
            {'point': Point<double>(x, y), 'latLng': LatLng(lat, lng)});
        break;
      case 'map#onMapLongClick':
        final double x = call.arguments['x'];
        final double y = call.arguments['y'];
        final double lng = call.arguments['lng'];
        final double lat = call.arguments['lat'];
        onMapLongClickPlatform(
            {'point': Point<double>(x, y), 'latLng': LatLng(lat, lng)});

        break;
      case 'map#onCameraTrackingChanged':
        final int mode = call.arguments['mode'];
        onCameraTrackingChangedPlatform(MyLocationTrackingMode.values[mode]);
        break;
      case 'map#onCameraTrackingDismissed':
        onCameraTrackingDismissedPlatform(null);
        break;
      case 'map#onIdle':
        onMapIdlePlatform(null);
        break;
      default:
        throw MissingPluginException();
    }
  }

  @override
  Future<void> initPlatform(int id) async {
    assert(id != null);
    _channel = MethodChannel('plugins.flutter.io/mapbox_maps_$id');
    await _channel.invokeMethod('map#waitForMap');
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  @override
  Widget buildView(
      Map<String, dynamic> creationParams,
      Function onPlatformViewCreated,
      Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'plugins.flutter.io/mapbox_gl',
        onPlatformViewCreated: onPlatformViewCreated,
        gestureRecognizers: gestureRecognizers,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: 'plugins.flutter.io/mapbox_gl',
        onPlatformViewCreated: onPlatformViewCreated,
        gestureRecognizers: gestureRecognizers,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
    return Text(
        '$defaultTargetPlatform is not yet supported by the maps plugin');
  }

  @override
  Future<CameraPosition> updateMapOptions(
      Map<String, dynamic> optionsUpdate) async {
    final dynamic json = await _channel.invokeMethod(
      'map#update',
      <String, dynamic>{
        'options': optionsUpdate,
      },
    );
    return CameraPosition.fromMap(json);
  }

  @override
  Future<bool> animateCamera(cameraUpdate) async {
    return await _channel.invokeMethod('camera#animate', <String, dynamic>{
      'cameraUpdate': cameraUpdate.toJson(),
    });
  }

  @override
  Future<bool> moveCamera(CameraUpdate cameraUpdate) async {
    return await _channel.invokeMethod('camera#move', <String, dynamic>{
      'cameraUpdate': cameraUpdate.toJson(),
    });
  }

  @override
  Future<void> updateMyLocationTrackingMode(
      MyLocationTrackingMode myLocationTrackingMode) async {
    await _channel
        .invokeMethod('map#updateMyLocationTrackingMode', <String, dynamic>{
      'mode': myLocationTrackingMode.index,
    });
  }

  @override
  Future<void> matchMapLanguageWithDeviceDefault() async {
    await _channel.invokeMethod('map#matchMapLanguageWithDeviceDefault');
  }

  @override
  Future<void> updateContentInsets(EdgeInsets insets, bool animated) async {
    await _channel.invokeMethod('map#updateContentInsets', <String, dynamic>{
      'bounds': <String, double>{
        'top': insets.top,
        'left': insets.left,
        'bottom': insets.bottom,
        'right': insets.right,
      },
      'animated': animated,
    });
  }

  @override
  Future<void> setMapLanguage(String language) async {
    await _channel.invokeMethod('map#setMapLanguage', <String, dynamic>{
      'language': language,
    });
  }

  @override
  Future<void> setTelemetryEnabled(bool enabled) async {
    await _channel.invokeMethod('map#setTelemetryEnabled', <String, dynamic>{
      'enabled': enabled,
    });
  }

  @override
  Future<bool> getTelemetryEnabled() async {
    return await _channel.invokeMethod('map#getTelemetryEnabled');
  }

  @override
  Future<List<Symbol>> addSymbols(List<SymbolOptions> options, [List<Map> data]) async {
    final List<dynamic> symbolIds = await _channel.invokeMethod(
      'symbols#addAll',
      <String, dynamic>{
        'options': options.map((o) => o.toJson()).toList(),
      },
    );
    final List<Symbol> symbols = symbolIds.asMap().map(
            (i, id) => MapEntry(
            i,
            Symbol(
                id,
                options.elementAt(i),
                data != null && data.length > i ? data.elementAt(i) : null
            )
        )
    ).values.toList();

    return symbols;
  }

  @override
  Future<void> updateSymbol(Symbol symbol, SymbolOptions changes) async {
    await _channel.invokeMethod('symbol#update', <String, dynamic>{
      'symbol': symbol.id,
      'options': changes.toJson(),
    });
  }

  @override
  Future<LatLng> getSymbolLatLng(Symbol symbol) async{
    Map mapLatLng =
        await _channel.invokeMethod('symbol#getGeometry', <String, dynamic>{
      'symbol': symbol._id,
    });
    LatLng symbolLatLng =
        new LatLng(mapLatLng['latitude'], mapLatLng['longitude']);
    return symbolLatLng;
  }

  @override
  Future<void> removeSymbols(Iterable<String> ids) async {
    await _channel.invokeMethod('symbols#removeAll', <String, dynamic>{
      'symbols': ids.toList(),
    });
  }

  @override
  Future<Line> addLine(LineOptions options, [Map data]) async {
    final String lineId = await _channel.invokeMethod(
      'line#add',
      <String, dynamic>{
        'options': options.toJson(),
      },
    );
    return Line(lineId, options, data);
  }

  @override
  Future<void> updateLine(Line line, LineOptions changes) async {
    await _channel.invokeMethod('line#update', <String, dynamic>{
      'line': line.id,
      'options': changes.toJson(),
    });
  }

  @override
  Future<List<LatLng>> getLineLatLngs(Line line) async{
    List latLngList =
        await _channel.invokeMethod('line#getGeometry', <String, dynamic>{
      'line': line._id,
    });
    List<LatLng> resultList = [];
    for (var latLng in latLngList) {
      resultList.add(LatLng(latLng['latitude'], latLng['longitude']));
    }
    return resultList;
  }

  @override
  Future<void> removeLine(String lineId) async {
    await _channel.invokeMethod('line#remove', <String, dynamic>{
      'line': lineId,
    });
  }

  @override
  Future<Circle> addCircle(CircleOptions options, [Map data]) async {
    final String circleId = await _channel.invokeMethod(
      'circle#add',
      <String, dynamic>{
        'options': options.toJson(),
      },
    );
    return Circle(circleId, options, data);
  }

  @override
  Future<void> updateCircle(Circle circle, CircleOptions changes) async {
    await _channel.invokeMethod('circle#update', <String, dynamic>{
      'circle': circle.id,
      'options': changes.toJson(),
    });
  }

  @override
  Future<LatLng> getCircleLatLng(Circle circle) async {
    Map mapLatLng =
        await _channel.invokeMethod('circle#getGeometry', <String, dynamic>{
      'circle': circle.id,
    });
    return LatLng(mapLatLng['latitude'], mapLatLng['longitude']);
  }

  @override
  Future<void> removeCircle(String circleId) async {
    await _channel.invokeMethod('circle#remove', <String, dynamic>{
      'circle': circleId,
    });
  }

  @override
  Future<List> queryRenderedFeatures(
      Point<double> point, List<String> layerIds, List<Object> filter) async {
    try {
      final Map<Object, Object> reply = await _channel.invokeMethod(
        'map#queryRenderedFeatures',
        <String, Object>{
          'x': point.x,
          'y': point.y,
          'layerIds': layerIds,
          'filter': filter,
        },
      );
      return reply['features'];
    } on PlatformException catch (e) {
      return new Future.error(e);
    }
  }

  @override
  Future<List> queryRenderedFeaturesInRect(
      Rect rect, List<String> layerIds, String filter) async {
    try {
      final Map<Object, Object> reply = await _channel.invokeMethod(
        'map#queryRenderedFeatures',
        <String, Object>{
          'left': rect.left,
          'top': rect.top,
          'right': rect.right,
          'bottom': rect.bottom,
          'layerIds': layerIds,
          'filter': filter,
        },
      );
      return reply['features'];
    } on PlatformException catch (e) {
      return new Future.error(e);
    }
  }

  @override
  Future invalidateAmbientCache() async {
    try {
      await _channel.invokeMethod('map#invalidateAmbientCache');
      return null;
    } on PlatformException catch (e) {
      return new Future.error(e);
    }
  }

  @override
  Future<LatLng> requestMyLocationLatLng() async {
    try {
      final Map<Object, Object> reply = await _channel.invokeMethod(
          'locationComponent#getLastLocation', null);
      double latitude = 0.0, longitude = 0.0;
      if (reply.containsKey("latitude") && reply["latitude"] != null) {
        latitude = double.parse(reply["latitude"].toString());
      }
      if (reply.containsKey("longitude") && reply["longitude"] != null) {
        longitude = double.parse(reply["longitude"].toString());
      }
      return LatLng(latitude, longitude);
    } on PlatformException catch (e) {
      return new Future.error(e);
    }
  }

  @override
  Future<LatLngBounds> getVisibleRegion() async {
    try {
      final Map<Object, Object> reply =
          await _channel.invokeMethod('map#getVisibleRegion', null);
      LatLng southwest, northeast;
      if (reply.containsKey("sw")) {
        List<dynamic> coordinates = reply["sw"];
        southwest = LatLng(coordinates[0], coordinates[1]);
      }
      if (reply.containsKey("ne")) {
        List<dynamic> coordinates = reply["ne"];
        northeast = LatLng(coordinates[0], coordinates[1]);
      }
      return LatLngBounds(southwest: southwest, northeast: northeast);
    } on PlatformException catch (e) {
      return new Future.error(e);
    }
  }

  @override
  Future<void> addImage(String name, Uint8List bytes,
      [bool sdf = false]) async {
    try {
      return await _channel.invokeMethod('style#addImage', <String, Object>{
        "name": name,
        "bytes": bytes,
        "length": bytes.length,
        "sdf": sdf
      });
    } on PlatformException catch (e) {
      return new Future.error(e);
    }
  }

  @override
  Future<void> setSymbolIconAllowOverlap(bool enable) async {
    try {
      await _channel
          .invokeMethod('symbolManager#iconAllowOverlap', <String, dynamic>{
        'iconAllowOverlap': enable,
      });
    } on PlatformException catch (e) {
      return new Future.error(e);
    }
  }

  @override
  Future<void> setSymbolIconIgnorePlacement(bool enable) async {
    try {
      await _channel
          .invokeMethod('symbolManager#iconIgnorePlacement', <String, dynamic>{
        'iconIgnorePlacement': enable,
      });
    } on PlatformException catch (e) {
      return new Future.error(e);
    }
  }

  @override
  Future<void> setSymbolTextAllowOverlap(bool enable) async {
    try {
      await _channel
          .invokeMethod('symbolManager#textAllowOverlap', <String, dynamic>{
        'textAllowOverlap': enable,
      });
    } on PlatformException catch (e) {
      return new Future.error(e);
    }
  }

  @override
  Future<void> setSymbolTextIgnorePlacement(bool enable) async {
    try {
      await _channel
          .invokeMethod('symbolManager#textIgnorePlacement', <String, dynamic>{
        'textIgnorePlacement': enable,
      });
    } on PlatformException catch (e) {
      return new Future.error(e);
    }
  }

  @override
  Future<void> addSource(String sourceId, String geojson) async {
    await _channel.invokeMethod('source#add', <String, dynamic>{
      'sourceId': sourceId,
      'geojson': geojson,
    });
  }

  @override
  Future<void> addSymbolLayer(String sourceId, String layerId, Map<String, String> properties) async {
    await _channel.invokeMethod('symbolLayer#add', <String, dynamic>{
      'sourceId': sourceId,
      'layerId': layerId,
      'properties': properties
    });
  }

  @override
  Future<void> addLineLayer(String sourceId, String layerId, Map<String, String> properties) async {
    await _channel.invokeMethod('lineLayer#add', <String, dynamic>{
      'sourceId': sourceId,
      'layerId': layerId,
      'properties': properties
    });
  }
}
