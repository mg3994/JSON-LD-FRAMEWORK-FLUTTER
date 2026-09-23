import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:schema_org_flutter/src/graph/graph_topology.dart';
import 'package:schema_org_flutter/src/graph/localized_string.dart';

void main() {
  group('LocalizedString Tests', () {
    test('Parses language tagged values and matches Locale correctly', () {
      final loc = LocalizedString.from([
        {'@value': 'Apple', '@language': 'en'},
        {'@value': 'Pomme', '@language': 'fr'},
        {'@value': 'Manzana', '@language': 'es'},
      ]);

      expect(loc.resolve(const Locale('en')), equals('Apple'));
      expect(loc.resolve(const Locale('fr')), equals('Pomme'));
      expect(loc.resolve(const Locale('es')), equals('Manzana'));
      expect(loc.resolve(const Locale('de')), equals('Apple')); // fallback to default 'en'
    });

    test('Supports pluralization replacement', () {
      final loc = LocalizedString.from({
        'en': '{count} items found',
      });

      expect(loc.resolve(const Locale('en'), count: 5), equals('5 items found'));
    });
  });

  group('GraphTopology Tests', () {
    test('Parses @graph array with @id identity anchoring and references', () {
      final jsonLd = {
        '@context': 'https://schema.org',
        '@graph': [
          {
            '@type': 'Person',
            '@id': 'https://example.com/authors/johndoe#person',
            'name': 'John Doe',
            'jobTitle': 'Lead Architect'
          },
          {
            '@type': 'TechArticle',
            '@id': 'https://example.com/articles/schema-framework#article',
            'headline': 'Building JSON-LD Frameworks',
            'author': {'@id': 'https://example.com/authors/johndoe#person'}
          }
        ]
      };

      final topology = GraphTopology.parse(jsonLd);
      expect(topology.rootEntities.length, equals(2));

      final article = topology.getEntityById('https://example.com/articles/schema-framework#article');
      expect(article, isNotNull);
      expect(article!.primaryType, equals('TechArticle'));

      final authorRef = article.getProperty('author');
      expect(authorRef, isA<SchemaEntity>());
      final authorEntity = authorRef as SchemaEntity;
      expect(authorEntity.getStringProperty('name'), equals('John Doe'));
    });

    test('Supports multi-typed entities', () {
      final jsonLd = {
        '@type': ['Restaurant', 'TouristAttraction'],
        'name': 'Le Bistro',
      };

      final topology = GraphTopology.parse(jsonLd);
      expect(topology.rootEntities.length, equals(1));
      final entity = topology.rootEntities.first;
      expect(entity.types, contains('Restaurant'));
      expect(entity.types, contains('TouristAttraction'));
    });
  });
}
