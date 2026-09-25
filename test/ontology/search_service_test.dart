import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:schema_org_flutter/schema_org_flutter.dart';

void main() {
  group('SchemaSearchService Tests', () {
    final ontology = SchemaOntology();
    late SchemaSearchService searchService;

    setUpAll(() {
      final file = File('assets/schemaorg-current-https.jsonld');
      final jsonString = file.readAsStringSync();
      ontology.parseJsonLdOntology(jsonString);
      searchService = SchemaSearchService(ontology: ontology);
    });

    test('Searches Schema.org classes and properties correctly', () {
      final results = searchService.search('Article');
      expect(results.isNotEmpty, isTrue);

      final hasArticle = results.any((r) => r.id == 'Article' && r.type == SearchResultType.schemaClass);
      expect(hasArticle, isTrue);
    });

    test('Searches Schema.org enumerations correctly', () {
      final results = searchService.search('InStock');
      expect(results.isNotEmpty, isTrue);

      final hasInStock = results.any((r) => r.id == 'InStock' && r.type == SearchResultType.schemaEnumeration);
      expect(hasInStock, isTrue);
    });
  });
}
