import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';


Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  await runZonedGuarded(
        () async {
      WidgetsFlutterBinding.ensureInitialized();

     /* if (Platform.isAndroid) {
        final mapsImplementation = GoogleMapsFlutterPlatform.instance;
        if (mapsImplementation is GoogleMapsFlutterAndroid) {
          mapsImplementation.useAndroidViewSurface = true;
        }
      }*/

      FlutterError.onError = FlutterError.presentError;
      PlatformDispatcher.instance.onError = (error, stackTrace) {
        FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace),
        );
        return true;
      };

      runApp(await builder());
    },
        (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'bootstrap',
          context: ErrorDescription('during an asynchronous app operation'),
        ),
      );
    },
  );
}