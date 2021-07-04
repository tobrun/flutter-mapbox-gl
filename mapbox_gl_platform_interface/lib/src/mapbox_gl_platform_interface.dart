// ignore_for_file: unnecessary_getters_setters

part of mapbox_gl_platform_interface;

typedef OnPlatformViewCreatedCallback = void Function(int);

abstract class MapboxGlPlatform {
  /// The default instance of [MapboxGlPlatform] to use.
  ///
  /// Defaults to [MethodChannelMapboxGl].
  ///
  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [MapboxGlPlatform] when they register themselves.
  static MapboxGlPlatform Function() createInstance =
      () => MethodChannelMapboxGl();

  static Map<int, MapboxGlPlatform> _instances = {};

  static void addInstance(int id, MapboxGlPlatform platform) {
    _instances[id] = platform;
  }

  static MapboxGlPlatform getInstance(int id) {
    return _instances[id]!;
  }

  final onInfoWindowTappedPlatform = ArgumentCallbacks<String>();

  final onSymbolTappedPlatform = ArgumentCallbacks<String>();

  final onLineTappedPlatform = ArgumentCallbacks<String>();

  final onCircleTappedPlatform = ArgumentCallbacks<String>();

  final onFillTappedPlatform = ArgumentCallbacks<String>();

  final onCameraMoveStartedPlatform = ArgumentCallbacks<void>();

  final onCameraMovePlatform = ArgumentCallbacks<CameraPosition>();

  final onCameraIdlePlatform = ArgumentCallbacks<CameraPosition?>();

  final onMapStyleLoadedPlatform = ArgumentCallbacks<void>();

  final onMapClickPlatform = ArgumentCallbacks<Map<String, dynamic>>();

  final onMapLongClickPlatform = ArgumentCallbacks<Map<String, dynamic>>();

  final ArgumentCallbacks<void> onAttributionClickPlatform =
      ArgumentCallbacks<void>();

  final ArgumentCallbacks<MyLocationTrackingMode>
      onCameraTrackingChangedPlatform =
      ArgumentCallbacks<MyLocationTrackingMode>();

  final onCameraTrackingDismissedPlatform = ArgumentCallbacks<void>();

  final onMapIdlePlatform = ArgumentCallbacks<void>();

  final onStyleImageMissing = ArgumentCallbacks<String>();

  final onUserLocationUpdatedPlatform = ArgumentCallbacks<UserLocation>();

  Future<void> initPlatform(int id) async {
    throw UnimplementedError('initPlatform() has not been implemented.');
  }

  Widget buildView(
      Map<String, dynamic> creationParams,
      OnPlatformViewCreatedCallback onPlatformViewCreated,
      Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers) {
    throw UnimplementedError('buildView() has not been implemented.');
  }

  Future<CameraPosition?> updateMapOptions(
      Map<String, dynamic> optionsUpdate) async {
    throw UnimplementedError('updateMapOptions() has not been implemented.');
  }

  Future<bool?> animateCamera(CameraUpdate cameraUpdate) async {
    throw UnimplementedError('animateCamera() has not been implemented.');
  }

  Future<bool?> moveCamera(CameraUpdate cameraUpdate) async {
    throw UnimplementedError('moveCamera() has not been implemented.');
  }

  Future<void> updateMyLocationTrackingMode(
      MyLocationTrackingMode myLocationTrackingMode) async {
    throw UnimplementedError(
        'updateMyLocationTrackingMode() has not been implemented.');
  }

  Future<void> matchMapLanguageWithDeviceDefault() async {
    throw UnimplementedError(
        'matchMapLanguageWithDeviceDefault() has not been implemented.');
  }

  Future<void> updateContentInsets(EdgeInsets insets, bool animated) async {
    throw UnimplementedError('updateContentInsets() has not been implemented.');
  }

  Future<void> setMapLanguage(String language) async {
    throw UnimplementedError('setMapLanguage() has not been implemented.');
  }

  Future<void> setTelemetryEnabled(bool enabled) async {
    throw UnimplementedError('setTelemetryEnabled() has not been implemented.');
  }

  Future<bool> getTelemetryEnabled() async {
    throw UnimplementedError('getTelemetryEnabled() has not been implemented.');
  }

  Future<List<Symbol>> addSymbols(List<SymbolOptions> options,
      [List<Map>? data]) async {
    throw UnimplementedError('addSymbols() has not been implemented.');
  }

  Future<void> updateSymbol(Symbol symbol, SymbolOptions changes) async {
    throw UnimplementedError('updateSymbol() has not been implemented.');
  }

  Future<void> removeSymbols(Iterable<String> symbolsIds) async {
    throw UnimplementedError('removeSymbol() has not been implemented.');
  }

  Future<Line> addLine(LineOptions options, [Map? data]) async {
    throw UnimplementedError('addLine() has not been implemented.');
  }

  Future<List<Line>> addLines(List<LineOptions> options,
      [List<Map>? data]) async {
    throw UnimplementedError('addLines() has not been implemented.');
  }

  Future<void> updateLine(Line line, LineOptions changes) async {
    throw UnimplementedError('updateLine() has not been implemented.');
  }

  Future<void> removeLine(String lineId) async {
    throw UnimplementedError('removeLine() has not been implemented.');
  }

  Future<void> removeLines(Iterable<String> ids) async {
    throw UnimplementedError('removeLines() has not been implemented.');
  }

  Future<Circle> addCircle(CircleOptions options, [Map? data]) async {
    throw UnimplementedError('addCircle() has not been implemented.');
  }

  Future<List<Circle>> addCircles(List<CircleOptions> options,
      [List<Map>? data]) async {
    throw UnimplementedError('addCircles() has not been implemented.');
  }

  Future<void> updateCircle(Circle circle, CircleOptions changes) async {
    throw UnimplementedError('updateCircle() has not been implemented.');
  }

  Future<LatLng> getCircleLatLng(Circle circle) async {
    throw UnimplementedError('getCircleLatLng() has not been implemented.');
  }

  Future<LatLng> getSymbolLatLng(Symbol symbol) async {
    throw UnimplementedError('getSymbolLatLng() has not been implemented.');
  }

  Future<List<LatLng>> getLineLatLngs(Line line) async {
    throw UnimplementedError('getLineLatLngs() has not been implemented.');
  }

  Future<void> removeCircle(String circleId) async {
    throw UnimplementedError('removeCircle() has not been implemented.');
  }

  Future<void> removeCircles(Iterable<String> ids) async {
    throw UnimplementedError('removeCircles() has not been implemented.');
  }

  Future<Fill> addFill(FillOptions options, [Map? data]) async {
    throw UnimplementedError('addFill() has not been implemented.');
  }

  Future<List<Fill>> addFills(List<FillOptions> options,
      [List<Map>? data]) async {
    throw UnimplementedError('addFills() has not been implemented.');
  }

  Future<void> updateFill(Fill fill, FillOptions changes) async {
    throw UnimplementedError('updateFill() has not been implemented.');
  }

  Future<void> removeFill(String fillId) async {
    throw UnimplementedError('removeFill() has not been implemented.');
  }

  Future<void> removeFills(Iterable<String> fillIds) async {
    throw UnimplementedError('removeFills() has not been implemented.');
  }

  Future<List> queryRenderedFeatures(
      Point<double> point, List<String> layerIds, List<Object>? filter) async {
    throw UnimplementedError(
        'queryRenderedFeatures() has not been implemented.');
  }

  Future<List> queryRenderedFeaturesInRect(
      Rect rect, List<String> layerIds, String? filter) async {
    throw UnimplementedError(
        'queryRenderedFeaturesInRect() has not been implemented.');
  }

  Future invalidateAmbientCache() async {
    throw UnimplementedError(
        'invalidateAmbientCache() has not been implemented.');
  }

  Future<LatLng?> requestMyLocationLatLng() async {
    throw UnimplementedError(
        'requestMyLocationLatLng() has not been implemented.');
  }

  Future<LatLngBounds> getVisibleRegion() async {
    throw UnimplementedError('getVisibleRegion() has not been implemented.');
  }

  Future<void> addImage(String name, Uint8List bytes,
      [bool sdf = false]) async {
    throw UnimplementedError('addImage() has not been implemented.');
  }

  Future<void> setSymbolIconAllowOverlap(bool enable) async {
    throw UnimplementedError(
        'setSymbolIconAllowOverlap() has not been implemented.');
  }

  Future<void> setSymbolIconIgnorePlacement(bool enable) async {
    throw UnimplementedError(
        'setSymbolIconIgnorePlacement() has not been implemented.');
  }

  Future<void> setSymbolTextAllowOverlap(bool enable) async {
    throw UnimplementedError(
        'setSymbolTextAllowOverlap() has not been implemented.');
  }

  Future<void> setSymbolTextIgnorePlacement(bool enable) async {
    throw UnimplementedError(
        'setSymbolTextIgnorePlacement() has not been implemented.');
  }

  Future<void> addImageSource(
      String imageSourceId, Uint8List bytes, LatLngQuad coordinates) async {
    throw UnimplementedError('addImageSource() has not been implemented.');
  }

  Future<void> removeImageSource(String imageSourceId) async {
    throw UnimplementedError('removeImageSource() has not been implemented.');
  }

  Future<void> addLayer(String imageLayerId, String imageSourceId) async {
    throw UnimplementedError('addLayer() has not been implemented.');
  }

  Future<void> addLayerBelow(
      String imageLayerId, String imageSourceId, String belowLayerId) async {
    throw UnimplementedError('addLayerBelow() has not been implemented.');
  }

  Future<void> removeLayer(String imageLayerId) async {
    throw UnimplementedError('removeLayer() has not been implemented.');
  }

  Future<Point> toScreenLocation(LatLng latLng) async {
    throw UnimplementedError('toScreenLocation() has not been implemented.');
  }

  Future<List<Point>> toScreenLocationBatch(Iterable<LatLng> latLngs) async {
    throw UnimplementedError(
        'toScreenLocationList() has not been implemented.');
  }

  Future<LatLng> toLatLng(Point screenLocation) async {
    throw UnimplementedError('toLatLng() has not been implemented.');
  }

  Future<double> getMetersPerPixelAtLatitude(double latitude) async {
    throw UnimplementedError(
        'getMetersPerPixelAtLatitude() has not been implemented.');
  }
}
