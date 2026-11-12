import 'package:flutter_test/flutter_test.dart';
import 'package:machine_maintenance/models/app_notification.dart';

void main() {
  test('AppNotification survives a toMap/fromMap round trip', () {
    final original = AppNotification(
      id: 1,
      title: 'Oil change',
      body: 'Due in 100 km',
      machineId: 7,
      createdAt: DateTime.utc(2026, 1, 2, 3, 4, 5),
      isRead: true,
    );

    final restored = AppNotification.fromMap(original.toMap());

    expect(restored.id, 1);
    expect(restored.title, 'Oil change');
    expect(restored.body, 'Due in 100 km');
    expect(restored.machineId, 7);
    expect(restored.createdAt, original.createdAt);
    expect(restored.isRead, isTrue);
  });
}
