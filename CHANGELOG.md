## 0.12.0, April 12, 2021
* Update to Mapbox-Android-SDK 9.6.0 [#489](https://github.com/tobrun/flutter-mapbox-gl/pull/489)
* Update to Mapbox-iOS-SDK 6.3.0 [#513](https://github.com/tobrun/flutter-mapbox-gl/pull/513)
* Batch creation/removal for circles, fills and lines [#576](https://github.com/tobrun/flutter-mapbox-gl/pull/576)
* Dependencies: updated image package [#598](https://github.com/tobrun/flutter-mapbox-gl/pull/598)
* Improve description to enable location features [#596](https://github.com/tobrun/flutter-mapbox-gl/pull/596)
* Fix feature manager on release build [#593](https://github.com/tobrun/flutter-mapbox-gl/pull/593)
* Emit onTap only for the feature above the others [#589](https://github.com/tobrun/flutter-mapbox-gl/pull/589)
* Add annotationOrder to web [#588](https://github.com/tobrun/flutter-mapbox-gl/pull/588)

## 0.11.0, March 30, 2021
* Fixed issues caused by new android API [#544](https://github.com/tobrun/flutter-mapbox-gl/pull/544)
* Add option to set maximum offline tile count [#549](https://github.com/tobrun/flutter-mapbox-gl/pull/549)
* Fixed web build failure due to http package upgrade [#550](https://github.com/tobrun/flutter-mapbox-gl/pull/550)
* Update OfflineRegion/OfflineRegionDefinition interfaces, synchronize with iOS and Android [#545](https://github.com/tobrun/flutter-mapbox-gl/pull/545)
* Fix Mapbox GL JS CSS embedding on web [#551](https://github.com/tobrun/flutter-mapbox-gl/pull/551)
* Update Podfile to fix iOS CI [#565](https://github.com/tobrun/flutter-mapbox-gl/pull/565)
* Update deprecated patterns to fix CI static analysis [#568](https://github.com/tobrun/flutter-mapbox-gl/pull/568)
* Add setOffline method on Android [#537](https://github.com/tobrun/flutter-mapbox-gl/pull/537)
* Add batch mode of screen locations [#554](https://github.com/tobrun/flutter-mapbox-gl/pull/554)
* Define which annotations consume the tap events [#575](https://github.com/tobrun/flutter-mapbox-gl/pull/575)
* Remove failed offline region downloads [#583](https://github.com/tobrun/flutter-mapbox-gl/pull/583)

## 0.10.0, February 12, 2021
* Merge offline regions [#532](https://github.com/tobrun/flutter-mapbox-gl/pull/532)
* Update offline region metadata [#530](https://github.com/tobrun/flutter-mapbox-gl/pull/530)
* Added web support for fills [#501](https://github.com/tobrun/flutter-mapbox-gl/pull/501)
* Support styleString as "Documents directory/Temporary directory" [#520](https://github.com/tobrun/flutter-mapbox-gl/pull/520)
* Use offline region ids [#491](https://github.com/tobrun/flutter-mapbox-gl/pull/491)
* Ability to define annotation layer order [#523](https://github.com/tobrun/flutter-mapbox-gl/pull/523)
* Clear fills API [#527](https://github.com/tobrun/flutter-mapbox-gl/pull/527)
* Add heading to UserLocation and expose UserLocation type [#522](https://github.com/tobrun/flutter-mapbox-gl/pull/522)
* Patch addFill with data parameter [#524](https://github.com/tobrun/flutter-mapbox-gl/pull/524)
* Fix style annotation is not deselected on iOS [#512](https://github.com/tobrun/flutter-mapbox-gl/pull/512)
* Update tracked camera position in camera#onIdle [#500](https://github.com/tobrun/flutter-mapbox-gl/pull/500)
* Fix iOS implementation of map#toLatLng on iOS [#495](https://github.com/tobrun/flutter-mapbox-gl/pull/495)
* Migrate to new Android flutter plugin architecture [#488](https://github.com/tobrun/flutter-mapbox-gl/pull/488)
* Update readme to fix UnsatisfiedLinkError [#422](https://github.com/tobrun/flutter-mapbox-gl/pull/442)
* Improved Image Source Support [#469](https://github.com/tobrun/flutter-mapbox-gl/pull/469)
* Avoid white space when resizing map on web [#474](https://github.com/tobrun/flutter-mapbox-gl/pull/474)
* Allow MapboxMap() to override Widget Key. [#475](https://github.com/tobrun/flutter-mapbox-gl/pull/475)
* Offline region feature [#336](https://github.com/tobrun/flutter-mapbox-gl/pull/336)
* Fix iOS symbol tapped interaction [#443](https://github.com/tobrun/flutter-mapbox-gl/pull/443)

## 0.9.0,  October 24. 2020
* Fix data parameter for addLine and addCircle [#388](https://github.com/tobrun/flutter-mapbox-gl/pull/388)
* Re-enable attribution on Android [#383](https://github.com/tobrun/flutter-mapbox-gl/pull/383)
* Upgrade annotation plugin to v0.9 [#381](https://github.com/tobrun/flutter-mapbox-gl/pull/381)
* Breaking change: CameraUpdate.newLatLngBounds() now supports setting different padding values for left, top, right, bottom with default of 0 for all. Implementations using the old approach with only one padding value for all edges have to be updated. [#382](https://github.com/tobrun/flutter-mapbox-gl/pull/382)
* web:ignore myLocationTrackingMode if myLocationEnabled is false [#363](https://github.com/tobrun/flutter-mapbox-gl/pull/363)
* Add methods to access projection [#380](https://github.com/tobrun/flutter-mapbox-gl/pull/380)
* Add fill API support for Android and iOS [#49](https://github.com/tobrun/flutter-mapbox-gl/pull/49)
* Listen to OnUserLocationUpdated to provide user location to app [#237](https://github.com/tobrun/flutter-mapbox-gl/pull/237)
* Correct integration in Activity lifecycle on Android [#266](https://github.com/tobrun/flutter-mapbox-gl/pull/266)
* Add support for custom font stackn in symbol options [#359](https://github.com/tobrun/flutter-mapbox-gl/pull/359)
* Fix memory leak on iOS caused by strong self reference [#370](https://github.com/tobrun/flutter-mapbox-gl/pull/370)
* Basic ImageSource Support [#409](https://github.com/tobrun/flutter-mapbox-gl/pull/409)
* Get meters per pixel at latitude [#416](https://github.com/tobrun/flutter-mapbox-gl/pull/416)
* Fix onStyleLoadedCallback [#418](https://github.com/tobrun/flutter-mapbox-gl/pull/418)

## 0.8.0, August 22, 2020
- implementation of feature querying [#177](https://github.com/tobrun/flutter-mapbox-gl/pull/177)
- Batch create/delete of symbols [#279](https://github.com/tobrun/flutter-mapbox-gl/pull/279)
- Add multi map support [#315](https://github.com/tobrun/flutter-mapbox-gl/pull/315)
- Fix OnCameraIdle not being invoked [#313](https://github.com/tobrun/flutter-mapbox-gl/pull/313)
- Fix android zIndex symbol option [#312](https://github.com/tobrun/flutter-mapbox-gl/pull/312)
- Set dependencies from git [#319](https://github.com/tobrun/flutter-mapbox-gl/pull/319)
- Add line#getGeometry and symbol#getGeometry [#281](https://github.com/tobrun/flutter-mapbox-gl/pull/281)

## 0.7.0, June 6, 2020
* Introduction of mapbox_gl_platform_interface library
* Introduction of mapbox_gl_web library
* Integrate web support through mapbox-gl-js
* Add icon-allow-overlap configurations

## 0.0.6, May 31, 2020
* Update mapbox depdendency to 9.2.0 (android) and 5.6.0 (iOS)
* Long press handlers for both iOS as Android
* Change default location tracking to none
* OnCameraIdle listener support
* Add image to style
* Add animation duration to animateCamera
* Content insets
* Visible region support on iOS
* Numerous bug fixes

## 0.0.5, December 21, 2019
* iOS support for annotation extensions (circle, symbol, line)
* Update SDK to 8.5.0 (Android) and 5.5.0 (iOS)
* Integrate style loaded callback api
* Add Map click event (iOS)
* Cache management API (Android/iOS)
* Various fixes to showing user location and configurations (Android/iOS)
* Last location API (Android)
* Throttle max FPS of user location component (Android)
* Fix for handling permission handling of the test application (Android)
* Support for loading symbol images from assets (iOS/Android)

## v0.0.4, Nov 2, 2019
* Update SDK to 8.4.0 (Android) and 5.4.0 (iOS)
* Add support for sideloading offline maps (Android/iOS)
* Add user tracking mode (iOS)
* Invert compassView.isHidden logic (iOS)
* Specific swift version (iOS)

## v0.0.3, Mar 30, 2019
* Camera API (iOS)
* Line API (Android)
* Update codebase to AndroidX
* Update Mapbox Maps SDK for Android to v7.3.0

## v0.0.2, Mar 23, 2019
* Support for iOS
* Migration to embedded Android and iOS SDK View system
* Style URL API
* Style JSON API (Android)
* Gesture support
* Gesture restrictions (Android)
* Symbol API (Android)
* Location component (Android)
* Camera API (Android)

## v0.0.1, May 7, 2018
* Initial Android surface rendering POC
