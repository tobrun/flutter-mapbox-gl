import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:http/http.dart' as http;
import 'page.dart';

class IssTrackerPage extends Page {
  IssTrackerPage()
      : super(const Icon(Icons.settings_input_antenna), 'ISS Tracker');

  @override
  Widget build(BuildContext context) {
    return const IssTracker();
  }
}

class IssTracker extends StatefulWidget {
  const IssTracker();

  @override
  State createState() => IssTrackerState();
}

class IssTrackerState extends State<IssTracker> {
  Timer timer;
  LatLng issPosition;
  MapboxMapController mapController;
  bool setInitialPosition = false;
  Symbol _currentSymbol;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), _getData);
    _getData(null);
  }

  Future<void> _getData(Timer timer) async {
    final http.Response data = await http.Client().get('http://api.open-notify.org/iss-now');
    final Map<String, String> position = Map<String, String>.from(jsonDecode(data.body)['iss_position']);
    final LatLng _issPosition = LatLng(double.parse(position['latitude']), double.parse(position['longitude']));

    mapController.moveCamera(CameraUpdate.newLatLng(_issPosition));
    if (mounted) {
      setState(() => issPosition = _issPosition);
      if (!setInitialPosition) {
        setInitialPosition = true;
        mapController
          .addSymbol(SymbolOptions(
              geometry: _issPosition,
              iconImage: ("assets/symbols/satellite.png"),
              iconSize: 0.2
          ))
          .then((value) => setState(() => _currentSymbol = value));
      } else {
        mapController.updateSymbol(
          _currentSymbol,
          SymbolOptions(
            geometry: _issPosition,
          )
        );
      }
    }
  }

  @override
  void dispose() {
    if (timer != null) {
      timer.cancel();
      timer = null;
    }
    mapController.dispose();
    super.dispose();
  }

  void _onMapCreated(MapboxMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: MapboxMap(
        styleString: MapboxStyles.SATELLITE_STREETS,
        onMapCreated: _onMapCreated,
        rotateGesturesEnabled: false,
        initialCameraPosition:
            const CameraPosition(target: LatLng(0.0, 0.0), zoom: 2.2),
      )
    );
  }
}
