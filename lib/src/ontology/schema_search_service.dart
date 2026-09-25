import 'schema_ontology.dart';

/// Provides instant search, filtering, and lookup across all 939+ classes, 1,538+ properties, and enumerations in Schema.org.
class SchemaSearchService {
  final SchemaOntology ontology;

  SchemaSearchService({SchemaOntology? ontology}) : ontology = ontology ?? SchemaOntology();

  /// Searches classes, properties, and enumerations matching [query].
  List<SearchResultItem> search(String query) {
    if (query.trim().isEmpty) return [];

    final q = query.toLowerCase().trim();
    final List<SearchResultItem> results = [];

    // Search Classes
    ontology.getPropertiesForType('Thing'); // Ensure loaded
    ontology.getAllClasses().forEach((cls) {
      if (cls.id.toLowerCase().contains(q) || cls.label.toLowerCase().contains(q) || cls.comment.toLowerCase().contains(q)) {
        results.add(SearchResultItem(
          id: cls.id,
          label: cls.label,
          comment: cls.comment,
          type: SearchResultType.schemaClass,
          superClasses: cls.superClasses,
        ));
      }
    });

    // Search Properties
    ontology.getAllProperties().forEach((prop) {
      if (prop.id.toLowerCase().contains(q) || prop.label.toLowerCase().contains(q) || prop.comment.toLowerCase().contains(q)) {
        results.add(SearchResultItem(
          id: prop.id,
          label: prop.label,
          comment: prop.comment,
          type: SearchResultType.schemaProperty,
          domainIncludes: prop.domainIncludes,
          rangeIncludes: prop.rangeIncludes,
        ));
      }
    });

    // Search Enumeration Members
    ontology.getAllEnumerations().forEach((enumMem) {
      if (enumMem.id.toLowerCase().contains(q) || enumMem.label.toLowerCase().contains(q) || enumMem.comment.toLowerCase().contains(q)) {
        results.add(SearchResultItem(
          id: enumMem.id,
          label: enumMem.label,
          comment: enumMem.comment,
          type: SearchResultType.schemaEnumeration,
          enumType: enumMem.enumType,
        ));
      }
    });

    return results;
  }
}

enum SearchResultType { schemaClass, schemaProperty, schemaEnumeration }

class SearchResultItem {
  final String id;
  final String label;
  final String comment;
  final SearchResultType type;
  final List<String>? superClasses;
  final List<String>? domainIncludes;
  final List<String>? rangeIncludes;
  final String? enumType;

  SearchResultItem({
    required this.id,
    required this.label,
    required this.comment,
    required this.type,
    this.superClasses,
    this.domainIncludes,
    this.rangeIncludes,
    this.enumType,
  });
}
