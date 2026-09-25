import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:schema_org_flutter/schema_org_flutter.dart';

void main() {
  group('JSON-LD Keyword Processing Tests', () {
    test('Parses @reverse inverse relationship links correctly', () {
      final jsonLd = {
        '@context': 'https://schema.org',
        '@type': 'Person',
        'name': 'Alice Architect',
        '@reverse': {
          'author': {
            '@type': 'TechArticle',
            'headline': 'Reverse Relations in JSON-LD Frameworks'
          }
        }
      };

      final topology = GraphTopology.parse(jsonLd);
      expect(topology.rootEntities.length, equals(1));
      final person = topology.rootEntities.first;
      expect(person.reverseProperties.containsKey('author'), isTrue);

      final reverseVal = person.reverseProperties['author'];
      expect(reverseVal, isA<SchemaEntity>());
      final article = reverseVal as SchemaEntity;
      expect(article.getStringProperty('headline'), equals('Reverse Relations in JSON-LD Frameworks'));
    });

    test('Parses @nest nested properties correctly', () {
      final jsonLd = {
        '@context': 'https://schema.org',
        '@type': 'Product',
        'name': 'Quantum Phone',
        '@nest': {
          'price': '999',
          'priceCurrency': 'USD'
        }
      };

      final topology = GraphTopology.parse(jsonLd);
      final entity = topology.rootEntities.first;
      expect(entity.getStringProperty('price'), equals('999'));
      expect(entity.getStringProperty('priceCurrency'), equals('USD'));
    });

    test('Parses @list ordered sequences and @set containers', () {
      final jsonLd = {
        '@context': 'https://schema.org',
        '@type': 'ItemList',
        'itemListElement': {
          '@list': ['Step 1', 'Step 2', 'Step 3']
        }
      };

      final topology = GraphTopology.parse(jsonLd);
      final entity = topology.rootEntities.first;
      final listVal = entity.getProperty('itemListElement');
      expect(listVal, isA<List>());
      expect(listVal, equals(['Step 1', 'Step 2', 'Step 3']));
    });

    test('Parses @included top-level detached entities', () {
      final jsonLd = {
        '@context': 'https://schema.org',
        '@type': 'Article',
        'headline': 'Main Article',
        '@included': [
          {
            '@type': 'Organization',
            '@id': 'https://example.com/org#publisher',
            'name': 'Tech Publishing House'
          }
        ]
      };

      final topology = GraphTopology.parse(jsonLd);
      final pubOrg = topology.getEntityById('https://example.com/org#publisher');
      expect(pubOrg, isNotNull);
      expect(pubOrg!.getStringProperty('name'), equals('Tech Publishing House'));
    });

    test('LocalizedString respects @direction (LTR / RTL)', () {
      final locLtr = LocalizedString.from({
        '@value': 'Hello World',
        '@language': 'en',
        '@direction': 'ltr'
      });

      final locRtl = LocalizedString.from({
        '@value': 'مرحبا بالعالم',
        '@language': 'ar',
        '@direction': 'rtl'
      });

      expect(locLtr.textDirection, equals(TextDirection.ltr));
      expect(locRtl.textDirection, equals(TextDirection.rtl));
    });
  });
}
