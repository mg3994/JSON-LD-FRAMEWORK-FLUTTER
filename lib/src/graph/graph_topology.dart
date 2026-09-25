import '../ontology/json_ld_context.dart';
import 'localized_string.dart';

/// Represents a resolved Schema.org Entity in the graph.
class SchemaEntity {
  final String? id;
  final List<String> types;
  final Map<String, dynamic> properties;
  final Map<String, dynamic> reverseProperties; // Stores @reverse inverse links

  SchemaEntity({
    this.id,
    required this.types,
    required this.properties,
    Map<String, dynamic>? reverseProperties,
  }) : reverseProperties = reverseProperties ?? {};

  String get primaryType => types.isNotEmpty ? types.first : 'Thing';

  bool isType(String typeName) => types.contains(typeName);

  dynamic getProperty(String name) => properties[name];

  String getStringProperty(String name, {dynamic locale, String? defaultValue = ''}) {
    final val = properties[name];
    if (val == null) return defaultValue ?? '';
    final locStr = LocalizedString.from(val);
    return locStr.resolve(locale, count: null);
  }

  List<dynamic> getListProperty(String name) {
    final val = properties[name];
    if (val == null) return [];
    if (val is List) return val;
    return [val];
  }
}

/// Dynamic JSON-LD Graph Topology Engine resolving keywords, @reverse, @nest, @list, and @included nodes.
class GraphTopology {
  final Map<String, SchemaEntity> _entityMap = {};
  final List<SchemaEntity> rootEntities = [];
  late JsonLdContext context;

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

    // Parse context
    context = JsonLdContext.parse(jsonLd['@context']);

    // Process top-level @included
    if (jsonLd.containsKey('@included')) {
      _parseIncludedNodes(jsonLd['@included']);
    }

    // Process top-level @graph array
    if (jsonLd.containsKey('@graph')) {
      final graphArray = jsonLd['@graph'];
      if (graphArray is List) {
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

  void _parseIncludedNodes(dynamic included) {
    if (included is List) {
      for (final item in included) {
        if (item is Map<String, dynamic>) {
          final entity = _rawToEntity(item);
          if (entity.id != null) {
            _entityMap[entity.id!] = entity;
          }
        }
      }
    } else if (included is Map<String, dynamic>) {
      final entity = _rawToEntity(included);
      if (entity.id != null) {
        _entityMap[entity.id!] = entity;
      }
    }
  }

  SchemaEntity _rawToEntity(Map<String, dynamic> raw) {
    final id = raw['@id']?.toString();
    final dynamic typeVal = raw['@type'];

    List<String> types = [];
    if (typeVal is List) {
      types = typeVal.map((e) => context.compactIri(e.toString())).toList();
    } else if (typeVal != null) {
      types = [context.compactIri(typeVal.toString())];
    }

    final Map<String, dynamic> props = {};
    final Map<String, dynamic> reverseProps = {};

    _extractPropertiesAndNest(raw, props, reverseProps);

    return SchemaEntity(id: id, types: types, properties: props, reverseProperties: reverseProps);
  }

  void _extractPropertiesAndNest(
    Map<String, dynamic> node,
    Map<String, dynamic> targetProps,
    Map<String, dynamic> targetReverse,
  ) {
    node.forEach((k, v) {
      if (k == '@context' || k == '@id' || k == '@type') return;

      if (k == '@nest') {
        if (v is Map<String, dynamic>) {
          _extractPropertiesAndNest(v, targetProps, targetReverse);
        } else if (v is List) {
          for (final nestItem in v) {
            if (nestItem is Map<String, dynamic>) {
              _extractPropertiesAndNest(nestItem, targetProps, targetReverse);
            }
          }
        }
        return;
      }

      if (k == '@reverse') {
        if (v is Map<String, dynamic>) {
          v.forEach((revKey, revVal) {
            targetReverse[context.compactIri(revKey)] = _resolveNodeValues(revVal);
          });
        }
        return;
      }

      final cleanKey = context.compactIri(k);
      targetProps[cleanKey] = _resolveNodeValues(v);
    });
  }

  dynamic _resolveNodeValues(dynamic val) {
    if (val is Map<String, dynamic>) {
      if (val.containsKey('@value')) {
        return val;
      }
      if (val.containsKey('@list')) {
        final listContent = val['@list'];
        if (listContent is List) {
          return listContent.map((item) => _resolveNodeValues(item)).toList();
        }
        return listContent;
      }
      if (val.containsKey('@set')) {
        return _resolveNodeValues(val['@set']);
      }
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
}
