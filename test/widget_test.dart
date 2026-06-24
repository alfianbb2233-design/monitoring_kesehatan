import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:monitoring_kesehatan/main.dart';

void main() {
  testWidgets('HealthTrack app smoke test', (WidgetTester tester) async {
    await initializeDateFormatting('id_ID');
    await tester.pumpWidget(const HealthTrackApp());

    expect(find.text('HealthTrack'), findsOneWidget);
    expect(find.text('Monitoring Kesehatan Harian'), findsOneWidget);
  });
}
