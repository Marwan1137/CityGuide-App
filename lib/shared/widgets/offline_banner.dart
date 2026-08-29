import 'package:flutter/material.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({this.visible = true, super.key});

  final bool visible;

  @override
  Widget build(BuildContext context) => AnimatedSize(
    duration: const Duration(milliseconds: 180),
    child: visible
        ? Material(
            color: Theme.of(context).colorScheme.errorContainer,
            child: const SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off, size: 18),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text('You are offline. Showing saved data.'),
                    ),
                  ],
                ),
              ),
            ),
          )
        : const SizedBox.shrink(),
  );
}
