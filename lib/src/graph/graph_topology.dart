import 'localized_string.dart';

/// Represents a resolved Schema.org Entity in the graph.
class SchemaEntity {
  final String? id;
  final List<String> types;
  final Map<String, dynamic> properties;

  SchemaEntity({
    this.id,
    required this.types,
    required this.properties,
  });

  String get primaryType => types.isNotEmpty ? types.first : 'Thing';

  bool isType(String typeName) => types.contains(typeName);

  /// Helper to safely retrieve property value.
  dynamic getProperty(String name) => properties[name];

  /// Resolves localized string property value.
  String getStringProperty(String name, {dynamic locale, String? defaultValue = ''}) {
    final val = properties[name];
    if (val == null) return defaultValue ?? '';
    final locStr = LocalizedString.from(val);
    return locStr.resolve(locale, count: null);
  }

  /// Returns list of entity or primitive values for property.
  List<dynamic> getListProperty(String name) {
    final val = properties[name];
    if (val == null) return [];
    if (val is List) return val;
    return [val];
  }
}

/// Dynamic JSON-LD Graph Topology Engine resolving @id references and multi-typed entities.
class GraphTopology {
  final Map<String, SchemaEntity> _entityMap = {};
  final List<SchemaEntity> rootEntities = [];

  GraphTopology._();

  factory GraphTopology.parse(dynamic jsonLd) {
    final graph = GraphTopology._();
    graph._parseJsonLd(jsonLd);
    return graph;
  }

  void _parseJsonLd(dynamic jsonLd) {
    if (jsonLd == null) return;

    if (jsonLd is List) {
      for (final item in jsonLd) {
        _parseJsonLd(item);
      }
      return;
    }

    if (jsonLd is! Map<String, dynamic>) return;

    // Check @graph array
    if (jsonLd.containsKey('@graph')) {
      final graphArray = jsonLd['@graph'];
      if (graphArray is List) {
        // First pass: collect all entities into entityMap
        for (final item in graphArray) {
          if (item is Map<String, dynamic>) {
            final entity = _rawToEntity(item);
            if (entity.id != null) {
              _entityMap[entity.id!] = entity;
            }
            rootEntities.add(entity);
          }
        }
      }
      return;
    }

    // Single top-level entity
    final entity = _rawToEntity(jsonLd);
    if (entity.id != null) {
      _entityMap[entity.id!] = entity;
    }
    rootEntities.add(entity);
  }

  SchemaEntity _rawToEntity(Map<String, dynamic> raw) {
    final id = raw['@id']?.toString();
    final dynamic typeVal = raw['@type'];

    List<String> types = [];
    if (typeVal is List) {
      types = typeVal.map((e) => _cleanType(e.toString())).toList();
    } else if (typeVal != null) {
      types = [_cleanType(typeVal.toString())];
    }

    final Map<String, dynamic> props = {};
    raw.forEach((k, v) {
      if (k.startsWith('@')) return;
      props[_cleanPropKey(k)] = _resolveNodeValues(v);
    });

    return SchemaEntity(id: id, types: types, properties: props);
  }

  dynamic _resolveNodeValues(dynamic val) {
    if (val is Map<String, dynamic>) {
      if (val.containsKey('@id') && val.keys.length == 1) {
        final refId = val['@id'].toString();
        return _entityMap[refId] ?? val;
      }
      if (val.containsKey('@type') || val.containsKey('@id')) {
        final childEntity = _rawToEntity(val);
        if (childEntity.id != null) {
          _entityMap[childEntity.id!] = childEntity;
        }
        return childEntity;
      }
      return val;
    } else if (val is List) {
      return val.map((e) => _resolveNodeValues(e)).toList();
    }
    return val;
  }

  SchemaEntity? getEntityById(String id) => _entityMap[id];

  String _cleanType(String t) {
    if (t.startsWith('schema:')) return t.substring(7);
    if (t.startsWith('https://schema.org/')) return t.substring(19);
    return t;
  }

  String _cleanPropKey(String k) {
    if (k.startsWith('schema:')) return k.substring(7);
    if (k.startsWith('https://schema.org/')) return k.substring(19);
    return k;
  }
}
