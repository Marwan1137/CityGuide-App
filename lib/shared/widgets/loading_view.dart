import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({this.message = 'Getting things ready…', super.key});

  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Semantics(
      label: message,
      liveRegion: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}
