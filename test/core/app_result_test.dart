import 'package:city_guide_app/core/error/failure.dart';
import 'package:city_guide_app/core/utils/app_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppResult', () {
    test('fold returns the success branch value', () {
      const result = Success<int>(42);

      final value = result.fold(
        onSuccess: (data) => 'value: $data',
        onFailure: (failure) => failure.message,
      );

      expect(value, 'value: 42');
    });

    test('fold returns the failure branch value', () {
      const result = Error<int>(NetworkFailure());

      final value = result.fold(
        onSuccess: (data) => 'value: $data',
        onFailure: (failure) => failure.message,
      );

      expect(value, 'Check your internet connection and try again.');
    });
  });
}
