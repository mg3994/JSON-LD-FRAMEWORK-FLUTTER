import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

/// Represents a Schema.org class definition.
class SchemaClass {
  final String id;
  final String label;
  final String comment;
  final List<String> superClasses;

  SchemaClass({
    required this.id,
    required this.label,
    required this.comment,
    required this.superClasses,
  });
}

/// Represents a Schema.org property definition.
class SchemaPropertyDef {
  final String id;
  final String label;
  final String comment;
  final List<String> domainIncludes;
  final List<String> rangeIncludes;

  SchemaPropertyDef({
    required this.id,
    required this.label,
    required this.comment,
    required this.domainIncludes,
    required this.rangeIncludes,
  });
}

/// Represents a Schema.org Enumeration member (e.g. InStock, EventScheduled).
class SchemaEnumerationMember {
  final String id;
  final String label;
  final String comment;
  final String enumType;

  SchemaEnumerationMember({
    required this.id,
    required this.label,
    required this.comment,
    required this.enumType,
  });
}

/// The runtime Schema.org Ontology graph storing classes, properties, enumerations, domains, and ranges.
class SchemaOntology {
  static final SchemaOntology _instance = SchemaOntology._internal();
  factory SchemaOntology() => _instance;
  SchemaOntology._internal();

  final Map<String, SchemaClass> _classes = {};
  final Map<String, SchemaPropertyDef> _properties = {};
  final Map<String, SchemaEnumerationMember> _enumerations = {};
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  List<SchemaClass> getAllClasses() => _classes.values.toList();
  List<SchemaPropertyDef> getAllProperties() => _properties.values.toList();
  List<SchemaEnumerationMember> getAllEnumerations() => _enumerations.values.toList();

  /// Loads ontology from local asset or optional JSON string.
  Future<void> loadFromAsset({String assetPath = 'assets/schemaorg-current-https.jsonld'}) async {
    if (_isLoaded) return;
    try {
      final jsonString = await rootBundle.loadString(assetPath);
      parseJsonLdOntology(jsonString);
    } catch (e) {
      // Fallback
    }
  }

  /// Loads ontology dynamically from Schema.org network endpoint.
  Future<void> loadFromNetwork({String url = 'https://schema.org/version/latest/schemaorg-current-https.jsonld'}) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      parseJsonLdOntology(response.body);
    } else {
      throw Exception('Failed to load Schema.org ontology from network: ${response.statusCode}');
    }
  }

  /// Parses raw JSON-LD graph into indexed classes, properties, and enumerations.
  void parseJsonLdOntology(String jsonString) {
    final Map<String, dynamic> data = jsonDecode(jsonString);
    final List<dynamic> graph = data['@graph'] ?? [];

    _classes.clear();
    _properties.clear();
    _enumerations.clear();

    for (final item in graph) {
      if (item is! Map<String, dynamic>) continue;

      final id = _cleanId(item['@id']);
      if (id.isEmpty) continue;

      final type = item['@type'];
      final label = _extractText(item['rdfs:label']) ?? id;
      final comment = _extractText(item['rdfs:comment']) ?? '';

      final isClass = type == 'rdfs:Class' || (type is List && type.contains('rdfs:Class'));
      final isProperty = type == 'rdf:Property' || (type is List && type.contains('rdf:Property'));

      if (isClass) {
        final superClasses = _extractListIds(item['rdfs:subClassOf']);
        _classes[id] = SchemaClass(
          id: id,
          label: label,
          comment: comment,
          superClasses: superClasses,
        );
      } else if (isProperty) {
        final domains = _extractListIds(item['schema:domainIncludes']);
        final ranges = _extractListIds(item['schema:rangeIncludes']);
        _properties[id] = SchemaPropertyDef(
          id: id,
          label: label,
          comment: comment,
          domainIncludes: domains,
          rangeIncludes: ranges,
        );
      } else {
        final enumType = type is List ? type.first.toString() : (type?.toString() ?? '');
        if (enumType.isNotEmpty && enumType.contains('schema:')) {
          _enumerations[id] = SchemaEnumerationMember(
            id: id,
            label: label,
            comment: comment,
            enumType: _cleanId(enumType),
          );
        }
      }
    }

    _isLoaded = true;
  }

  /// Checks if a type is a subclass of another type (recursively).
  bool isSubclassOf(String childType, String parentType) {
    final cleanChild = _cleanId(childType);
    final cleanParent = _cleanId(parentType);
    if (cleanChild == cleanParent) return true;

    final cls = _classes[cleanChild];
    if (cls == null) return false;

    for (final parent in cls.superClasses) {
      if (parent == cleanParent || isSubclassOf(parent, cleanParent)) {
        return true;
      }
    }
    return false;
  }

  /// Returns true if [enumValue] is a valid member of [enumType] (e.g. 'InStock' in 'ItemAvailability').
  bool isValidEnumerationMember(String enumValue, String enumType) {
    final cleanVal = _cleanId(enumValue);
    final cleanType = _cleanId(enumType);

    final member = _enumerations[cleanVal];
    if (member == null) return false;
    return member.enumType == cleanType || isSubclassOf(member.enumType, cleanType);
  }

  /// Returns all properties applicable to a specific type (including inherited properties).
  List<SchemaPropertyDef> getPropertiesForType(String typeName) {
    final cleanType = _cleanId(typeName);
    final List<SchemaPropertyDef> result = [];

    for (final prop in _properties.values) {
      for (final domain in prop.domainIncludes) {
        if (domain == cleanType || isSubclassOf(cleanType, domain)) {
          result.add(prop);
          break;
        }
      }
    }
    return result;
  }

  SchemaClass? getClass(String typeName) => _classes[_cleanId(typeName)];
  SchemaPropertyDef? getProperty(String propName) => _properties[_cleanId(propName)];
  SchemaEnumerationMember? getEnumerationMember(String memberName) => _enumerations[_cleanId(memberName)];

  String _cleanId(dynamic id) {
    if (id == null) return '';
    final str = id.toString();
    if (str.startsWith('schema:')) return str.substring(7);
    if (str.startsWith('https://schema.org/')) return str.substring(19);
    if (str.startsWith('http://schema.org/')) return str.substring(18);
    return str;
  }

  String? _extractText(dynamic val) {
    if (val == null) return null;
    if (val is String) return val;
    if (val is Map) return val['@value']?.toString() ?? val['@id']?.toString();
    return val.toString();
  }

  List<String> _extractListIds(dynamic val) {
    if (val == null) return [];
    if (val is List) {
      return val.map((e) => _cleanId(e is Map ? e['@id'] : e)).where((s) => s.isNotEmpty).toList();
    }
    if (val is Map) {
      final id = _cleanId(val['@id']);
      return id.isNotEmpty ? [id] : [];
    }
    final id = _cleanId(val);
    return id.isNotEmpty ? [id] : [];
  }
}
