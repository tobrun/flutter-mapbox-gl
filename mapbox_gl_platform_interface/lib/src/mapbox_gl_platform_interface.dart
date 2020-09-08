// ignore_for_file: unnecessary_getters_setters

part of mapbox_gl_platform_interface;

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
    return _instances[id];
  }

  final ArgumentCallbacks<String> onInfoWindowTappedPlatform =
      ArgumentCallbacks<String>();

  final ArgumentCallbacks<String> onSymbolTappedPlatform =
      ArgumentCallbacks<String>();

  final ArgumentCallbacks<String> onLineTappedPlatform =
      ArgumentCallbacks<String>();

  final ArgumentCallbacks<String> onCircleTappedPlatform =
      ArgumentCallbacks<String>();

  final ArgumentCallbacks<void> onCameraMoveStartedPlatform =
      ArgumentCallbacks<void>();

  final ArgumentCallbacks<CameraPosition> onCameraMovePlatform =
      ArgumentCallbacks<CameraPosition>();

  final ArgumentCallbacks<void> onCameraIdlePlatform =
      ArgumentCallbacks<void>();

  final ArgumentCallbacks<void> onMapStyleLoadedPlatform =
      ArgumentCallbacks<void>();

  final ArgumentCallbacks<Map<String, dynamic>> onMapClickPlatform =
      ArgumentCallbacks<Map<String, dynamic>>();

  final ArgumentCallbacks<Map<String, dynamic>> onMapLongClickPlatform =
      ArgumentCallbacks<Map<String, dynamic>>();

  final ArgumentCallbacks<MyLocationTrackingMode>
      onCameraTrackingChangedPlatform =
      ArgumentCallbacks<MyLocationTrackingMode>();

  final ArgumentCallbacks<void> onCameraTrackingDismissedPlatform =
      ArgumentCallbacks<void>();

  final ArgumentCallbacks<void> onMapIdlePlatform = ArgumentCallbacks<void>();

  Future<void> initPlatform(int id) async {
    throw UnimplementedError('initPlatform() has not been implemented.');
  }

  Widget buildView(
      Map<String, dynamic> creationParams,
      Function onPlatformViewCreated,
      Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers) {
    throw UnimplementedError('buildView() has not been implemented.');
  }

  Future<CameraPosition> updateMapOptions(
      Map<String, dynamic> optionsUpdate) async {
    throw UnimplementedError('updateMapOptions() has not been implemented.');
  }

  Future<bool> animateCamera(CameraUpdate cameraUpdate) async {
    throw UnimplementedError('animateCamera() has not been implemented.');
  }

  Future<bool> moveCamera(CameraUpdate cameraUpdate) async {
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
  
  Future<List<Symbol>> addSymbols(List<SymbolOptions> options, [List<Map> data]) async {
    throw UnimplementedError('addSymbols() has not been implemented.');
  }

  Future<void> updateSymbol(Symbol symbol, SymbolOptions changes) async {
    throw UnimplementedError('updateSymbol() has not been implemented.');
  }

  Future<void> removeSymbols(Iterable<String> symbolsIds) async {
    throw UnimplementedError('removeSymbol() has not been implemented.');
  }

  Future<Line> addLine(LineOptions options, [Map data]) async {
    throw UnimplementedError('addLine() has not been implemented.');
  }

  Future<void> updateLine(Line line, LineOptions changes) async {
    throw UnimplementedError('updateLine() has not been implemented.');
  }

  Future<void> removeLine(String lineId) async {
    throw UnimplementedError('removeLine() has not been implemented.');
  }

  Future<Circle> addCircle(CircleOptions options, [Map data]) async {
    throw UnimplementedError('addCircle() has not been implemented.');
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

  Future<List> queryRenderedFeatures(
      Point<double> point, List<String> layerIds, List<Object> filter) async {
    throw UnimplementedError(
        'queryRenderedFeatures() has not been implemented.');
  }

  Future<List> queryRenderedFeaturesInRect(
      Rect rect, List<String> layerIds, String filter) async {
    throw UnimplementedError(
        'queryRenderedFeaturesInRect() has not been implemented.');
  }

  Future invalidateAmbientCache() async {
    throw UnimplementedError(
        'invalidateAmbientCache() has not been implemented.');
  }

  Future<LatLng> requestMyLocationLatLng() async {
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

  Future<void> addSource(String sourceId, String geojson) async {
    throw UnimplementedError(
        'setSymbolTextIgnorePlacement() has not been implemented.');
  }

  Future<void> addSymbolLayer(String sourceId, String layerId, Map<String, String> properties) async {
    throw UnimplementedError(
        'setSymbolTextIgnorePlacement() has not been implemented.');
  }

  Future<void> addLineLayer(String sourceId, String layerId, Map<String, String> properties) async {
    throw UnimplementedError(
        'setSymbolTextIgnorePlacement() has not been implemented.');
  }
}
