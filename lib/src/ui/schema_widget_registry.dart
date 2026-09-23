import 'package:flutter/material.dart';
import '../graph/graph_topology.dart';
import '../theme/schema_ui_theme.dart';

typedef SchemaWidgetBuilder = Widget Function(
  BuildContext context,
  SchemaEntity entity, {
  Locale? locale,
  SchemaUiTheme? theme,
  void Function(String id)? onEntityTap,
});

/// Registry allowing custom Flutter widget definitions for ANY Schema.org type or property.
class SchemaWidgetRegistry {
  static final SchemaWidgetRegistry instance = SchemaWidgetRegistry._internal();
  factory SchemaWidgetRegistry() => instance;
  SchemaWidgetRegistry._internal();

  final Map<String, SchemaWidgetBuilder> _typeBuilders = {};

  /// Registers a custom builder function for a specific Schema.org @type (e.g., 'Product', 'MedicalWebPage').
  void registerType(String typeName, SchemaWidgetBuilder builder) {
    _typeBuilders[_cleanType(typeName)] = builder;
  }

  /// Removes custom builder registration.
  void unregisterType(String typeName) {
    _typeBuilders.remove(_cleanType(typeName));
  }

  /// Gets builder for type if registered.
  SchemaWidgetBuilder? getBuilderForTypes(List<String> types) {
    for (final t in types) {
      final clean = _cleanType(t);
      if (_typeBuilders.containsKey(clean)) {
        return _typeBuilders[clean];
      }
    }
    return null;
  }

  String _cleanType(String t) {
    if (t.startsWith('schema:')) return t.substring(7);
    if (t.startsWith('https://schema.org/')) return t.substring(19);
    return t;
  }
}
