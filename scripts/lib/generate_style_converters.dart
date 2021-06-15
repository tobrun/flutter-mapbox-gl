import 'dart:io';
import 'dart:convert';

import 'package:mustache/mustache.dart';
import 'package:recase/recase.dart';

main() async {
  var properties = [];

  var styleJson = jsonDecode(await new File('./scripts/input/style.json').readAsString());
  properties.addAll(styleJson["layout_line"].keys.followedBy(styleJson["paint_line"].keys)
      .map((f) => {
        'hyphen': f,
        'camel': new ReCase(f).camelCase
      }).toList());

  var javaTemplate = await new File('./scripts/templates/java_template.txt').readAsString();
  var template = new Template(javaTemplate);

  var outputFile = new File('./android/src/main/java/com/mapbox/mapboxgl/LayerPropertyConverter.java');
  outputFile.writeAsString(template.renderString({
    'lineStyles': properties
  }));
}