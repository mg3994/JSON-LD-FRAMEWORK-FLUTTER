import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:schema_org_flutter/src/graph/graph_topology.dart';
import 'package:schema_org_flutter/src/theme/schema_ui_theme.dart';
import 'package:schema_org_flutter/src/ui/auto_schema_widget.dart';
import 'package:schema_org_flutter/src/ui/schema_ld_widget.dart';
import 'package:schema_org_flutter/src/ui/schema_widget_registry.dart';

void main() {
  testWidgets('AutoSchemaWidget renders basic schema entity correctly', (WidgetTester tester) async {
    final entity = SchemaEntity(
      types: ['TechArticle'],
      properties: {
        'headline': 'Building Dynamic UI in Flutter',
        'description': 'A guide to dynamic schema rendering.',
        'author': 'John Architect',
      },
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AutoSchemaWidget(entity: entity),
      ),
    ));

    expect(find.text('Building Dynamic UI in Flutter'), findsOneWidget);
    expect(find.text('A guide to dynamic schema rendering.'), findsOneWidget);
    expect(find.text('TechArticle'), findsOneWidget);
    expect(find.text('John Architect'), findsOneWidget);
  });

  testWidgets('SchemaWidgetRegistry overrides type widget', (WidgetTester tester) async {
    SchemaWidgetRegistry.instance.registerType('CustomProduct', (context, entity, {locale, onEntityTap, theme}) {
      return const Text('CUSTOM_PRODUCT_WIDGET');
    });

    final entity = SchemaEntity(
      types: ['CustomProduct'],
      properties: {'name': 'Custom Laptop'},
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AutoSchemaWidget(entity: entity),
      ),
    ));

    expect(find.text('CUSTOM_PRODUCT_WIDGET'), findsOneWidget);
  });

  testWidgets('SchemaLdWidget parses and renders JSON-LD payload', (WidgetTester tester) async {
    final jsonLd = {
      '@context': 'https://schema.org',
      '@type': 'Event',
      'name': 'Flutter World Summit',
      'startDate': '2026-05-20T09:00:00Z',
    };

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SchemaLdWidget(jsonLd: jsonLd),
      ),
    ));

    expect(find.text('Flutter World Summit'), findsOneWidget);
    expect(find.text('Event'), findsOneWidget);
  });
}
