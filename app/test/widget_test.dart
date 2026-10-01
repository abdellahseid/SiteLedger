import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siteledger/presentation/widgets/status_badge.dart';
import 'package:siteledger/presentation/widgets/metric_card.dart';

void main() {
  group('SiteLedger Core Widget Tests', () {
    testWidgets('StatusBadge renders correct labels and styling for statuses', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                StatusBadge(status: 'APPROVED'),
                StatusBadge(status: 'PENDING_APPROVAL'),
                StatusBadge(status: 'FLAGGED'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('APPROVED'), findsOneWidget);
      expect(find.text('PENDING APPROVAL'), findsOneWidget);
      expect(find.text('FLAGGED'), findsOneWidget);
    });

    testWidgets('MetricCard displays title, value, subtitle and fires onTap', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MetricCard(
              title: 'Total Deliveries',
              value: '142',
              subtitle: '94% on-spec',
              icon: Icons.local_shipping_outlined,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Total Deliveries'), findsOneWidget);
      expect(find.text('142'), findsOneWidget);
      expect(find.text('94% on-spec'), findsOneWidget);
      expect(find.byIcon(Icons.local_shipping_outlined), findsOneWidget);

      await tester.tap(find.byType(MetricCard));
      expect(tapped, isTrue);
    });
  });
}
