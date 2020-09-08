import Mapbox
import MapboxAnnotationExtension

class Convert {
    class func interpretMapboxMapOptions(options: Any?, delegate: MapboxMapOptionsSink) {
        guard let options = options as? [String: Any] else { return }
        if let cameraTargetBounds = options["cameraTargetBounds"] as? [[[Double]]] {
            delegate.setCameraTargetBounds(bounds: MGLCoordinateBounds.fromArray(cameraTargetBounds[0]))
        }
        if let compassEnabled = options["compassEnabled"] as? Bool {
            delegate.setCompassEnabled(compassEnabled: compassEnabled)
        }
        if let minMaxZoomPreference = options["minMaxZoomPreference"] as? [Double] {
            delegate.setMinMaxZoomPreference(min: minMaxZoomPreference[0], max: minMaxZoomPreference[1])
        }
        if let styleString = options["styleString"] as? String {
            delegate.setStyleString(styleString: styleString)
        }
        if let rotateGesturesEnabled = options["rotateGesturesEnabled"] as? Bool {
            delegate.setRotateGesturesEnabled(rotateGesturesEnabled: rotateGesturesEnabled)
        }
        if let scrollGesturesEnabled = options["scrollGesturesEnabled"] as? Bool {
            delegate.setScrollGesturesEnabled(scrollGesturesEnabled: scrollGesturesEnabled)
        }
        if let tiltGesturesEnabled = options["tiltGesturesEnabled"] as? Bool {
            delegate.setTiltGesturesEnabled(tiltGesturesEnabled: tiltGesturesEnabled)
        }
        if let trackCameraPosition = options["trackCameraPosition"] as? Bool {
            delegate.setTrackCameraPosition(trackCameraPosition: trackCameraPosition)
        }
        if let zoomGesturesEnabled = options["zoomGesturesEnabled"] as? Bool {
            delegate.setZoomGesturesEnabled(zoomGesturesEnabled: zoomGesturesEnabled)
        }
        if let myLocationEnabled = options["myLocationEnabled"] as? Bool {
            delegate.setMyLocationEnabled(myLocationEnabled: myLocationEnabled)
        }
        if let myLocationTrackingMode = options["myLocationTrackingMode"] as? UInt, let trackingMode = MGLUserTrackingMode(rawValue: myLocationTrackingMode) {
            delegate.setMyLocationTrackingMode(myLocationTrackingMode: trackingMode)
        }
        if let myLocationRenderMode = options["myLocationRenderMode"] as? Int, let renderMode = MyLocationRenderMode(rawValue: myLocationRenderMode) {
            delegate.setMyLocationRenderMode(myLocationRenderMode: renderMode)
        }
        if let logoViewMargins = options["logoViewMargins"] as? [Double] {
            delegate.setLogoViewMargins(x: logoViewMargins[0], y: logoViewMargins[1])
        }
        if let compassViewPosition = options["compassViewPosition"] as? UInt, let position = MGLOrnamentPosition(rawValue: compassViewPosition) {
            delegate.setCompassViewPosition(position: position)
        }
        if let compassViewMargins = options["compassViewMargins"] as? [Double] {
            delegate.setCompassViewMargins(x: compassViewMargins[0], y: compassViewMargins[1])
        }
        if let attributionButtonMargins = options["attributionButtonMargins"] as? [Double] {
            delegate.setAttributionButtonMargins(x: attributionButtonMargins[0], y: attributionButtonMargins[1])
        }
    }
    
    class func parseCameraUpdate(cameraUpdate: [Any], mapView: MGLMapView) -> MGLMapCamera? {
        guard let type = cameraUpdate[0] as? String else { return nil }
        switch (type) {
        case "newCameraPosition":
            guard let cameraPosition = cameraUpdate[1] as? [String: Any] else { return nil }
            return MGLMapCamera.fromDict(cameraPosition, mapView: mapView)
        case "newLatLng":
            guard let coordinate = cameraUpdate[1] as? [Double] else { return nil }
            let camera = mapView.camera
            camera.centerCoordinate = CLLocationCoordinate2D.fromArray(coordinate)
            return camera
        case "newLatLngBounds":
            guard let bounds = cameraUpdate[1] as? [[Double]] else { return nil }
            guard let padding = cameraUpdate[2] as? CGFloat else { return nil }
            return mapView.cameraThatFitsCoordinateBounds(MGLCoordinateBounds.fromArray(bounds), edgePadding: UIEdgeInsets.init(top: padding, left: padding, bottom: padding, right: padding))
        case "newLatLngZoom":
            guard let coordinate = cameraUpdate[1] as? [Double] else { return nil }
            guard let zoom = cameraUpdate[2] as? Double else { return nil }
            let camera = mapView.camera
            camera.centerCoordinate = CLLocationCoordinate2D.fromArray(coordinate)
            let altitude = getAltitude(zoom: zoom, mapView: mapView)
            return MGLMapCamera(lookingAtCenter: camera.centerCoordinate, altitude: altitude, pitch: camera.pitch, heading: camera.heading)
        case "scrollBy":
            guard let x = cameraUpdate[1] as? CGFloat else { return nil }
            guard let y = cameraUpdate[2] as? CGFloat else { return nil }
            let camera = mapView.camera
            let mapPoint = mapView.convert(camera.centerCoordinate, toPointTo: mapView)
            let movedPoint = CGPoint(x: mapPoint.x + x, y: mapPoint.y + y)
            camera.centerCoordinate = mapView.convert(movedPoint, toCoordinateFrom: mapView)
            return camera
        case "zoomBy":
            guard let zoomBy = cameraUpdate[1] as? Double else { return nil }
            let camera = mapView.camera
            let zoom = getZoom(mapView: mapView)
            let altitude = getAltitude(zoom: zoom+zoomBy, mapView: mapView)
            camera.altitude = altitude
            if (cameraUpdate.count == 2) {
                return camera
            } else {
                guard let point = cameraUpdate[2] as? [CGFloat], point.count == 2 else { return nil }
                let movedPoint = CGPoint(x: point[0], y: point[1])
                camera.centerCoordinate = mapView.convert(movedPoint, toCoordinateFrom: mapView)
                return camera
            }
        case "zoomIn":
            let camera = mapView.camera
            let zoom = getZoom(mapView: mapView)
            let altitude = getAltitude(zoom: zoom + 1, mapView: mapView)
            camera.altitude = altitude
            return camera
        case "zoomOut":
            let camera = mapView.camera
            let zoom = getZoom(mapView: mapView)
            let altitude = getAltitude(zoom: zoom - 1, mapView: mapView)
            camera.altitude = altitude
            return camera
        case "zoomTo":
            guard let zoom = cameraUpdate[1] as? Double else { return nil }
            let camera = mapView.camera
            let altitude = getAltitude(zoom: zoom, mapView: mapView)
            camera.altitude = altitude
            return camera
        case "bearingTo":
            guard let bearing = cameraUpdate[1] as? Double else { return nil }
            let camera = mapView.camera
            camera.heading = bearing
            return camera
        case "tiltTo":
            guard let tilt = cameraUpdate[1] as? CGFloat else { return nil }
            let camera = mapView.camera
            camera.pitch = tilt
            return camera
        default:
            print("\(type) not implemented!")
        }
        return nil
    }
    
    class func getZoom(mapView: MGLMapView) -> Double {
        return MGLZoomLevelForAltitude(mapView.camera.altitude, mapView.camera.pitch, mapView.camera.centerCoordinate.latitude, mapView.frame.size)
    }
    
    class func getAltitude(zoom: Double, mapView: MGLMapView) -> Double {
        return MGLAltitudeForZoomLevel(zoom, mapView.camera.pitch, mapView.camera.centerCoordinate.latitude, mapView.frame.size)
    }

    class func interpretSymbolOptions(options: Any?, delegate: MGLSymbolStyleAnnotation) {
        guard let options = options as? [String: Any] else { return }
        if let iconSize = options["iconSize"] as? CGFloat {
            delegate.iconScale = iconSize
        }
        if let iconImage = options["iconImage"] as? String {
            delegate.iconImageName = iconImage
        }
        if let iconRotate = options["iconRotate"] as? CGFloat {
            delegate.iconRotation = iconRotate
        }
        if let iconOffset = options["iconOffset"] as? [Double] {
            delegate.iconOffset = CGVector(dx: iconOffset[0], dy: iconOffset[1])
        }
        if let iconAnchorStr = options["iconAnchor"] as? String {
            if let iconAnchor = Constants.symbolIconAnchorMapping[iconAnchorStr] {
                delegate.iconAnchor = iconAnchor
            } else {
                delegate.iconAnchor = MGLIconAnchor.center
            }
        }
        if let iconOpacity = options["iconOpacity"] as? CGFloat {
            delegate.iconOpacity = iconOpacity
        }
        if let iconColor = options["iconColor"] as? String {
            delegate.iconColor = UIColor(hexString: iconColor) ?? UIColor.black
        }
        if let iconHaloColor = options["iconHaloColor"] as? String {
            delegate.iconHaloColor = UIColor(hexString: iconHaloColor) ?? UIColor.white
        }
        if let iconHaloWidth = options["iconHaloWidth"] as? CGFloat {
            delegate.iconHaloWidth = iconHaloWidth
        }
        if let iconHaloBlur = options["iconHaloBlur"] as? CGFloat {
            delegate.iconHaloBlur = iconHaloBlur
        }
        if let textField = options["textField"] as? String {
            delegate.text = textField
        }
        if let textSize = options["textSize"] as? CGFloat {
            delegate.textFontSize = textSize
        }
        if let textMaxWidth = options["textMaxWidth"] as? CGFloat {
            delegate.maximumTextWidth = textMaxWidth
        }
        if let textLetterSpacing = options["textLetterSpacing"] as? CGFloat {
            delegate.textLetterSpacing = textLetterSpacing
        }
        if let textJustify = options["textJustify"] as? String {
            if let textJustifaction = Constants.symbolTextJustificationMapping[textJustify] {
                delegate.textJustification = textJustifaction
            } else {
                delegate.textJustification = MGLTextJustification.center
            }
        }
        if let textRadialOffset = options["textRadialOffset"] as? CGFloat {
            delegate.textRadialOffset = textRadialOffset
        }
        if let textAnchorStr = options["textAnchor"] as? String {
            if let textAnchor = Constants.symbolTextAnchorMapping[textAnchorStr] {
                delegate.textAnchor = textAnchor
            } else {
                delegate.textAnchor = MGLTextAnchor.center
            }
        }
        if let textRotate = options["textRotate"] as? CGFloat {
            delegate.textRotation = textRotate
        }
        if let textTransform = options["textTransform"] as? String {
            if let textTransformation = Constants.symbolTextTransformationMapping[textTransform] {
                delegate.textTransform = textTransformation
            } else {
                delegate.textTransform = MGLTextTransform.none
            }
        }
        if let textTranslate = options["textTranslate"] as? [Double] {
            delegate.textTranslation = CGVector(dx: textTranslate[0], dy: textTranslate[1])
        }
        if let textOffset = options["textOffset"] as? [Double] {
            delegate.textOffset = CGVector(dx: textOffset[0], dy: textOffset[1])
        }
        if let textOpacity = options["textOpacity"] as? CGFloat {
            delegate.textOpacity = textOpacity
        }
        if let textColor = options["textColor"] as? String {
            delegate.textColor = UIColor(hexString: textColor) ?? UIColor.black
        }
        if let textHaloColor = options["textHaloColor"] as? String {
            delegate.textHaloColor = UIColor(hexString: textHaloColor) ?? UIColor.white
        }
        if let textHaloWidth = options["textHaloWidth"] as? CGFloat {
            delegate.textHaloWidth = textHaloWidth
        }
        if let textHaloBlur = options["textHaloBlur"] as? CGFloat {
            delegate.textHaloBlur = textHaloBlur
        }
        if let geometry = options["geometry"] as? [Double] {
            // We cannot set the geometry directy on the annotation so calculate
            // the difference and update the coordinate using the delta.
            let currCoord = delegate.feature.coordinate
            let newCoord = CLLocationCoordinate2DMake(geometry[0], geometry[1])
            let delta = CGVector(dx: newCoord.longitude - currCoord.longitude, dy: newCoord.latitude - currCoord.latitude)
            delegate.updateGeometryCoordinates(withDelta: delta)
        }
        if let zIndex = options["zIndex"] as? Int {
            delegate.symbolSortKey = zIndex
        }
        if let draggable = options["draggable"] as? Bool {
            delegate.isDraggable = draggable
        }
    }
    
    class func interpretCircleOptions(options: Any?, delegate: MGLCircleStyleAnnotation) {
        guard let options = options as? [String: Any] else { return }
        if let circleRadius = options["circleRadius"] as? CGFloat {
            delegate.circleRadius = circleRadius
        }
        if let circleColor = options["circleColor"] as? String {
            delegate.circleColor = UIColor(hexString: circleColor) ?? UIColor.black
        }
        if let circleBlur = options["circleBlur"] as? CGFloat {
            delegate.circleBlur = circleBlur
        }
        if let circleOpacity = options["circleOpacity"] as? CGFloat {
            delegate.circleOpacity = circleOpacity
        }
        if let circleStrokeWidth = options["circleStrokeWidth"] as? CGFloat {
            delegate.circleStrokeWidth = circleStrokeWidth
        }
        if let circleStrokeColor = options["circleStrokeColor"] as? String {
            delegate.circleStrokeColor = UIColor(hexString: circleStrokeColor) ?? UIColor.black
        }
        if let circleStrokeOpacity = options["circleStrokeOpacity"] as? CGFloat {
            delegate.circleStrokeOpacity = circleStrokeOpacity
        }
        if let geometry = options["geometry"] as? [Double] {
            delegate.center = CLLocationCoordinate2DMake(geometry[0], geometry[1])
        }
        if let draggable = options["draggable"] as? Bool {
            delegate.isDraggable = draggable
        }
    }
    
    class func interpretLineOptions(options: Any?, delegate: MGLLineStyleAnnotation) {
        guard let options = options as? [String: Any] else { return }
        if let lineJoinStr = options["lineJoin"] as? String {
            if let lineJoin = Constants.lineJoinMapping[lineJoinStr] {
                delegate.lineJoin = lineJoin
            } else {
                delegate.lineJoin = MGLLineJoin.miter
            }
        }
        if let lineOpacity = options["lineOpacity"] as? CGFloat {
            delegate.lineOpacity = lineOpacity
        }
        if let lineColor = options["lineColor"] as? String {
            delegate.lineColor = UIColor(hexString: lineColor) ?? UIColor.black
        }
        if let lineWidth = options["lineWidth"] as? CGFloat {
            delegate.lineWidth = lineWidth
        }
        if let lineGapWidth = options["lineGapWidth"] as? CGFloat {
            delegate.lineGapWidth = lineGapWidth
        }
        if let lineOffset = options["lineOffset"] as? CGFloat {
            delegate.lineOffset = lineOffset
        }
        if let lineBlur = options["lineBlur"] as? CGFloat {
            delegate.lineBlur = lineBlur
        }
        if let linePattern = options["linePattern"] as? String {
            delegate.linePattern = linePattern
        }
        if let draggable = options["draggable"] as? Bool {
            delegate.isDraggable = draggable
        }
    }
    
    class func addSymbolProperties(symbolLayer: MGLSymbolStyleLayer, properties: [String: String]) {
        for (propertyName, propertyValue) in properties {
            let expression = interpretExpression(expression: propertyValue)
            switch propertyName {
                case "icon-allow-overlap":
                    symbolLayer.iconAllowsOverlap = expression
                case "icon-anchor":
                    symbolLayer.iconAnchor = expression
                case "icon-color":
                    symbolLayer.iconColor = expression
                case "icon-halo-blur":
                    symbolLayer.iconHaloBlur = expression
                case "icon-halo-color":
                    symbolLayer.iconHaloColor = expression
                case "icon-halo-width":
                    symbolLayer.iconHaloWidth = expression
                case "icon-ignore-placement":
                    symbolLayer.iconIgnoresPlacement = expression
                case "icon-image":
                    symbolLayer.iconImageName = expression
                case "icon-keep-upright":
                    symbolLayer.keepsIconUpright = expression
                case "icon-offset":
                    symbolLayer.iconOffset = expression
                case "icon-opacity":
                    symbolLayer.iconOpacity = expression
                case "icon-optional":
                    symbolLayer.iconOptional = expression
                case "icon-padding":
                    symbolLayer.iconPadding = expression
                case "icon-pitch-alignment":
                    symbolLayer.iconPitchAlignment = expression
                case "icon-rotate":
                    symbolLayer.iconRotation = expression
                case "icon-rotation-alignment":
                    symbolLayer.iconRotationAlignment = expression
                case "icon-size":
                    symbolLayer.iconScale = expression
                case "icon-text-fit":
                    symbolLayer.iconTextFit = expression
                case "icon-text-fit-padding":
                    symbolLayer.iconTextFitPadding = expression
                case "icon-translate":
                    symbolLayer.iconTranslation = expression
                case "icon-translate-anchor":
                    symbolLayer.iconTranslationAnchor = expression
                case "symbol-avoid-edges":
                    symbolLayer.symbolAvoidsEdges = expression
                case "symbol-placement":
                    symbolLayer.symbolPlacement = expression
                case "symbol-sort-key":
                    symbolLayer.symbolSortKey = expression
                case "symbol-spacing":
                    symbolLayer.symbolSpacing = expression
                case "symbol-z-order":
                    symbolLayer.symbolZOrder = expression
                case "text-allow-overlap":
                    symbolLayer.textAllowsOverlap = expression
                case "text-anchor":
                    symbolLayer.textAnchor = expression
                case "text-color":
                    symbolLayer.textColor = expression
                case "text-field":
                    symbolLayer.text = expression
                case "text-font":
                    symbolLayer.textFontNames = expression
                case "text-halo-blur":
                    symbolLayer.textHaloBlur = expression
                case "text-halo-color":
                    symbolLayer.textHaloColor = expression
                case "text-halo-width":
                    symbolLayer.textHaloWidth = expression
                case "text-ignore-placement":
                    symbolLayer.textIgnoresPlacement = expression
                case "text-justify":
                    symbolLayer.textJustification = expression
                case "text-keep-upright":
                    symbolLayer.keepsTextUpright = expression
                case "text-letter-spacing":
                    symbolLayer.textLetterSpacing = expression
                case "text-line-height":
                    symbolLayer.textLineHeight = expression
                case "text-max-angle":
                    symbolLayer.maximumTextAngle = expression
                case "text-max-width":
                    symbolLayer.maximumTextWidth = expression
                case "text-offset":
                    symbolLayer.textOffset = expression
                case "text-opacity":
                    symbolLayer.textOpacity = expression
                case "text-optional":
                    symbolLayer.textOptional = expression
                case "text-padding":
                    symbolLayer.textPadding = expression
                case "text-pitch-alignment":
                    symbolLayer.textPitchAlignment = expression
                case "text-radial-offset":
                    symbolLayer.textRadialOffset = expression
                case "text-rotate":
                    symbolLayer.textRotation = expression
                case "text-rotation-alignment":
                    symbolLayer.textRotationAlignment = expression
                case "text-size":
                    symbolLayer.textFontSize = expression
                case "text-transform":
                    symbolLayer.textTransform = expression
                case "text-translate":
                    symbolLayer.textTranslation = expression
                case "text-translate-anchor":
                    symbolLayer.textTranslationAnchor = expression
                case "text-variable-anchor":
                    symbolLayer.textVariableAnchor = expression
                case "text-writing-mode":
                    symbolLayer.textWritingModes = expression
                default:
                    break
            }
        }
    }
    
    class func addLineProperties(lineLayer: MGLLineStyleLayer, properties: [String: String]) {
        for (propertyName, propertyValue) in properties {
            let expression = interpretExpression(expression: propertyValue)
            switch propertyName {
                case "line-blur":
                    lineLayer.lineBlur = expression
                case "line-cap":
                    lineLayer.lineCap = expression
                case "line-color":
                    lineLayer.lineColor = expression
                case "line-dasharray":
                    lineLayer.lineDashPattern = expression
                case "line-gap-width":
                    lineLayer.lineGapWidth = expression
                case "line-gradient":
                    lineLayer.lineGradient = expression
                case "line-join":
                    lineLayer.lineJoin = expression
                case "line-miter-limit":
                    lineLayer.lineMiterLimit = expression
                case "line-offset":
                    lineLayer.lineOffset = expression
                case "line-pattern":
                    lineLayer.linePattern = expression
                case "line-round-limit":
                    lineLayer.lineRoundLimit = expression
                case "line-translate":
                    lineLayer.lineTranslation = expression
                case "line-translate-anchor":
                    lineLayer.lineTranslationAnchor = expression
                case "line-width":
                    lineLayer.lineWidth = expression
                default:
                    break
            }
        }
    }
    
    private class func interpretExpression(expression: String) -> NSExpression? {
        do {
            let json = try JSONSerialization.jsonObject(with: expression.data(using: .utf8)!, options: [])
            return NSExpression.init(mglJSONObject: json)
        } catch {
        }
        return nil
    }
}
