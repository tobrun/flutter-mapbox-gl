part of mapbox_gl_web;

class SymbolManager extends FeatureManager<SymbolOptions> {
  ArgumentCallbacks<String>? onStyleImageMissing;
  SymbolManager(
      {required MapboxMap map,
      ArgumentCallbacks<String>? onTap,
      this.onStyleImageMissing})
      : super(
          sourceId: 'symbol_source',
          layerId: 'symbol_layer',
          map: map,
          onTap: onTap,
        );

  @override
  void initLayer() {
    map.addLayer({
      'id': layerId,
      'type': 'symbol',
      'source': sourceId,
      'layout': {
        'icon-image': '{iconImage}',
        'icon-size': ['get', 'iconSize'],
        'icon-rotate': ['get', 'iconRotate'],
        'icon-offset': ['get', 'iconOffset'],
        'icon-anchor': ['get', 'iconAnchor'],
        'text-field': ['get', 'textField'],
        'text-size': ['get', 'textSize'],
        'text-max-width': ['get', 'textMaxWidth'],
        'text-letter-spacing': ['get', 'textLetterSpacing'],
        'text-justify': ['get', 'textJustify'],
        'text-anchor': ['get', 'textAnchor'],
        'text-rotate': ['get', 'textRotate'],
        'text-transform': ['get', 'textTransform'],
        'text-offset': ['get', 'textOffset'],
        'symbol-sort-key': ['get', 'symbolSortKey'],
        'icon-allow-overlap': true,
        'icon-ignore-placement': true,
        'text-allow-overlap': true,
        'text-ignore-placement': true,
      },
      'paint': {
        'icon-opacity': ['get', 'iconOpacity'],
        'icon-color': ['get', 'iconColor'],
        'icon-halo-color': ['get', 'iconHaloColor'],
        'icon-halo-width': ['get', 'iconHaloWidth'],
        'icon-halo-blur': ['get', 'iconHaloBlur'],
        'text-opacity': ['get', 'textOpacity'],
        'text-color': ['get', 'textColor'],
        'text-halo-color': ['get', 'textHaloColor'],
        'text-halo-width': ['get', 'textHaloWidth'],
        'text-halo-blur': ['get', 'textHaloBlur'],
      }
    });
  }

  @override
  void update(String lineId, SymbolOptions changes) {
    updateAll({lineId: changes});
  }

  void updateAll(Map<String, SymbolOptions> changesById) {
    List<Feature> featuresWithUpdatedOptions = [];
    changesById.forEach(
      (id, options) => featuresWithUpdatedOptions.add(
        Convert.interpretSymbolOptions(
          options,
          getFeature(id)!,
        ),
      ),
    );
    updateFeatures(featuresWithUpdatedOptions);
  }

  @override
  void onDrag(String featureId, LatLng latLng) {
    update(featureId, SymbolOptions(geometry: latLng));
  }
}
