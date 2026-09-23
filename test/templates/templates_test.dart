import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:schema_org_flutter/src/templates/schema_templates.dart';
import 'package:schema_org_flutter/src/ui/schema_ld_widget.dart';

void main() {
  setUpAll(() {
    SchemaTemplates.registerDefaultTemplates();
  });

  testWidgets('Renders Article template correctly', (WidgetTester tester) async {
    final jsonLd = {
      '@context': 'https://schema.org',
      '@type': 'Article',
      'headline': 'Pre-built Templates in Action',
      'datePublished': '2026-03-15T12:00:00Z',
    };

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SchemaLdWidget(jsonLd: jsonLd),
      ),
    ));

    expect(find.text('ARTICLE'), findsOneWidget);
    expect(find.text('Pre-built Templates in Action'), findsOneWidget);
  });

  testWidgets('Renders Product template with price badge', (WidgetTester tester) async {
    final jsonLd = {
      '@context': 'https://schema.org',
      '@type': 'Product',
      'name': 'Dart Tablet Pro',
      'offers': {
        '@type': 'Offer',
        'price': '899',
        'priceCurrency': 'USD',
      }
    };

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SchemaLdWidget(jsonLd: jsonLd),
      ),
    ));

    expect(find.text('PRODUCT'), findsOneWidget);
    expect(find.text('Dart Tablet Pro'), findsOneWidget);
    expect(find.text('USD 899'), findsOneWidget);
  });
}
