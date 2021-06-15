// This file is generated.

package com.mapbox.mapboxgl;

import com.mapbox.mapboxsdk.style.expressions.Expression;
import com.mapbox.mapboxsdk.style.layers.PropertyFactory;
import com.mapbox.mapboxsdk.style.layers.PropertyValue;

import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import static com.mapbox.mapboxgl.Convert.toMap;

class LayerPropertyConverter {

  static PropertyValue[] interpretLineLayerProperties(Object o) {
    final Map<String, String> data = (Map<String, String>) toMap(o);
    final List<PropertyValue> properties = new LinkedList();

    for (Map.Entry<String, String> entry : data.entrySet()) {
      Expression expression = Expression.Converter.convert(entry.getValue());
      switch (entry.getKey()) {
        case "line-cap":
          properties.add(PropertyFactory.lineCap(expression));
          break;
        case "line-join":
          properties.add(PropertyFactory.lineJoin(expression));
          break;
        case "line-miter-limit":
          properties.add(PropertyFactory.lineMiterLimit(expression));
          break;
        case "line-round-limit":
          properties.add(PropertyFactory.lineRoundLimit(expression));
          break;
        case "line-sort-key":
          properties.add(PropertyFactory.lineSortKey(expression));
          break;
        case "visibility":
          properties.add(PropertyFactory.visibility(expression));
          break;
        case "line-opacity":
          properties.add(PropertyFactory.lineOpacity(expression));
          break;
        case "line-color":
          properties.add(PropertyFactory.lineColor(expression));
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
        case "line-gap-width":
          properties.add(PropertyFactory.lineGapWidth(expression));
          break;
        case "line-offset":
          properties.add(PropertyFactory.lineOffset(expression));
          break;
        case "line-blur":
          properties.add(PropertyFactory.lineBlur(expression));
          break;
        case "line-dasharray":
          properties.add(PropertyFactory.lineDasharray(expression));
          break;
        case "line-pattern":
          properties.add(PropertyFactory.linePattern(expression));
          break;
        case "line-gradient":
          properties.add(PropertyFactory.lineGradient(expression));
          break;
        default:
          break;
      }
    }

    return properties.toArray(new PropertyValue[properties.size()]);
  }

}