import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Performs application-wide initialization before the widget tree is built.
Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

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
