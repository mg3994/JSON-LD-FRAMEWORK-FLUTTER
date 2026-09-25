import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:schema_org_flutter/schema_org_flutter.dart';

void main() {
  group('Schema.org Enumerations & Extensions Tests', () {
    final ontology = SchemaOntology();

    setUpAll(() {
      final file = File('assets/schemaorg-current-https.jsonld');
      final jsonString = file.readAsStringSync();
      ontology.parseJsonLdOntology(jsonString);
    });

    test('Validates Schema.org Enumeration members correctly', () {
      expect(ontology.isValidEnumerationMember('InStock', 'ItemAvailability'), isTrue);
      expect(ontology.isValidEnumerationMember('https://schema.org/InStock', 'ItemAvailability'), isTrue);
      expect(ontology.isValidEnumerationMember('EventScheduled', 'EventStatusType'), isTrue);
      expect(ontology.isValidEnumerationMember('OrderDelivered', 'OrderStatus'), isTrue);
      expect(ontology.isValidEnumerationMember('NonExistentValue', 'ItemAvailability'), isFalse);
    });

    test('Indexes Enumeration labels and comments', () {
      final inStock = ontology.getEnumerationMember('InStock');
      expect(inStock, isNotNull);
      expect(inStock!.label, equals('InStock'));
      expect(inStock.enumType, equals('ItemAvailability'));
    });
  });
}
