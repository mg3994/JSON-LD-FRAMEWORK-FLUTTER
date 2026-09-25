/// Processes and manages JSON-LD `@context` definitions, term mappings, vocabularies, and IRI prefixes.
class JsonLdContext {
  String? vocab;
  String? base;
  final Map<String, String> prefixes = {};
  final Map<String, Map<String, dynamic>> termDefinitions = {};

  JsonLdContext();

  factory JsonLdContext.parse(dynamic rawContext) {
    final ctx = JsonLdContext();
    ctx._processContext(rawContext);
    return ctx;
  }

  void _processContext(dynamic rawContext) {
    if (rawContext == null) return;

    if (rawContext is String) {
      if (rawContext.contains('schema.org')) {
        vocab = 'https://schema.org/';
      }
      return;
    }

    if (rawContext is List) {
      for (final item in rawContext) {
        _processContext(item);
      }
      return;
    }

    if (rawContext is Map<String, dynamic>) {
      rawContext.forEach((key, value) {
        if (key == '@vocab') {
          vocab = value.toString();
        } else if (key == '@base') {
          base = value.toString();
        } else if (key.startsWith('@')) {
          // Other keywords in context
        } else if (value is String) {
          if (value.startsWith('http://') || value.startsWith('https://') || value.endsWith('/') || value.endsWith('#')) {
            prefixes[key] = value;
          } else {
            termDefinitions[key] = {'@id': value};
          }
        } else if (value is Map<String, dynamic>) {
          termDefinitions[key] = value;
        }
      });
    }
  }

  /// Expands compact IRI or term (e.g. "schema:headline" -> "https://schema.org/headline")
  String expandIri(String term) {
    if (term.startsWith('@')) return term;

    if (termDefinitions.containsKey(term)) {
      final def = termDefinitions[term]!;
      if (def.containsKey('@id')) {
        return expandIri(def['@id'].toString());
      }
    }

    if (term.contains(':')) {
      final parts = term.split(':');
      final prefix = parts[0];
      final suffix = parts.sublist(1).join(':');

      if (prefixes.containsKey(prefix)) {
        return '${prefixes[prefix]}$suffix';
      }
      if (prefix == 'schema') {
        return 'https://schema.org/$suffix';
      }
    }

    if (vocab != null && !term.startsWith('http://') && !term.startsWith('https://')) {
      return '$vocab$term';
    }

    return term;
  }

  /// Shortens standard IRI to clean property key name (e.g., "https://schema.org/name" -> "name")
  String compactIri(String iri) {
    if (iri.startsWith('@')) return iri;
    if (iri.startsWith('https://schema.org/')) return iri.substring(19);
    if (iri.startsWith('http://schema.org/')) return iri.substring(18);
    if (iri.startsWith('schema:')) return iri.substring(7);

    prefixes.forEach((prefix, uri) {
      if (iri.startsWith(uri)) {
        iri = iri.substring(uri.length);
      }
    });

    return iri;
  }
}

/// JSON-LD Keyword Constants & Utility Helpers.
class JsonLdKeywords {
  static const String context = '@context';
  static const String id = '@id';
  static const String type = '@type';
  static const String graph = '@graph';
  static const String value = '@value';
  static const String language = '@language';
  static const String direction = '@direction';
  static const String reverse = '@reverse';
  static const String list = '@list';
  static const String set = '@set';
  static const String included = '@included';
  static const String nest = '@nest';
  static const String index = '@index';
  static const String container = '@container';
  static const String vocab = '@vocab';
  static const String base = '@base';

  static bool isKeyword(String key) => key.startsWith('@');
}
