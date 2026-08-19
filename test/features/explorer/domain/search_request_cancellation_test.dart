import 'package:city_guide_app/features/explorer/domain/entity/search_request_cancellation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('notifies listeners once and immediately notifies late listeners', () {
    final cancellation = SearchRequestCancellation();
    var notifications = 0;
    cancellation.onCancel(() => notifications++);

    cancellation.cancel();
    cancellation.cancel();
    cancellation.onCancel(() => notifications++);

    expect(cancellation.isCancelled, isTrue);
    expect(notifications, 2);
  });
}
