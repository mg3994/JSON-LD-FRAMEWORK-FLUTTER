import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:schema_org_flutter/src/ontology/schema_ld_validator.dart';
import 'package:schema_org_flutter/src/ontology/schema_ontology.dart';
import 'package:schema_org_flutter/src/ontology/schema_validator.dart';

void main() {
  group('SchemaOntology Tests', () {
    final ontology = SchemaOntology();

    setUpAll(() {
      final file = File('assets/schemaorg-current-https.jsonld');
      final jsonString = file.readAsStringSync();
      ontology.parseJsonLdOntology(jsonString);
    });

    test('Ontology correctly loads classes and inheritance hierarchy', () {
      expect(ontology.isLoaded, isTrue);
      expect(ontology.isSubclassOf('TechArticle', 'Article'), isTrue);
      expect(ontology.isSubclassOf('TechArticle', 'CreativeWork'), isTrue);
      expect(ontology.isSubclassOf('TechArticle', 'Thing'), isTrue);
      expect(ontology.isSubclassOf('Restaurant', 'FoodEstablishment'), isTrue);
      expect(ontology.isSubclassOf('Restaurant', 'LocalBusiness'), isTrue);
    });

    test('Ontology retrieves properties for a given type', () {
      final props = ontology.getPropertiesForType('TechArticle');
      final propNames = props.map((p) => p.id).toSet();

      expect(propNames.contains('headline'), isTrue);
      expect(propNames.contains('author'), isTrue);
      expect(propNames.contains('dependencies'), isTrue);
    });
  });

  group('SchemaLdValidator Tests', () {
    final ontology = SchemaOntology();

    setUpAll(() {
      final file = File('assets/schemaorg-current-https.jsonld');
      final jsonString = file.readAsStringSync();
      ontology.parseJsonLdOntology(jsonString);
    });

    test('Validator checks valid ISO 8601 dates and ISO 4217 currency', () {
      final validator = SchemaLdValidator(ontology: ontology, mode: ValidationMode.strict);
      final report = validator.validate({
        '@context': 'https://schema.org',
        '@type': 'Product',
        'name': 'Pixel 8',
        'offers': {
          '@type': 'Offer',
          'price': '699.99',
          'priceCurrency': 'USD',
          'validFrom': '2023-10-04T10:00:00Z',
        }
      });

      expect(report.isValid, isTrue);
      expect(report.criticalErrors, isEmpty);
    });

    test('Validator catches invalid dates and currency codes', () {
      final validator = SchemaLdValidator(ontology: ontology, mode: ValidationMode.strict);
      final report = validator.validate({
        '@context': 'https://schema.org',
        '@type': 'Product',
        'offers': {
          '@type': 'Offer',
          'priceCurrency': 'INVALID_CURRENCY',
          'validFrom': 'NOT_A_DATE',
        }
      });

      expect(report.isValid, isFalse);
      expect(report.criticalErrors.length, greaterThanOrEqualTo(2));
    });
  });
}
