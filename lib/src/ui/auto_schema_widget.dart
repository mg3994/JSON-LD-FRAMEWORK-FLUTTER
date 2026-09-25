import 'package:flutter/material.dart';

import '../graph/graph_topology.dart';
import '../graph/localized_string.dart';
import '../ontology/schema_ontology.dart';
import '../theme/schema_ui_theme.dart';
import 'schema_widget_registry.dart';

/// Universal dynamic UI widget that reflects ANY Schema.org entity dynamically.
class AutoSchemaWidget extends StatelessWidget {
  final SchemaEntity entity;
  final Locale? locale;
  final SchemaUiTheme theme;
  final void Function(String id)? onEntityTap;

  const AutoSchemaWidget({
    super.key,
    required this.entity,
    this.locale,
    this.theme = const SchemaUiTheme(),
    this.onEntityTap,
  });

  @override
  Widget build(BuildContext context) {
    final customBuilder = SchemaWidgetRegistry.instance.getBuilderForTypes(entity.types);
    if (customBuilder != null) {
      return customBuilder(context, entity, locale: locale, theme: theme, onEntityTap: onEntityTap);
    }

    return Card(
      elevation: theme.cardElevation,
      color: theme.cardBackgroundColor,
      margin: theme.cardMargin,
      shape: RoundedRectangleBorder(borderRadius: theme.borderRadius),
      child: Padding(
        padding: theme.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            const Divider(height: 24),
            _buildPropertiesList(context),
            if (entity.reverseProperties.isNotEmpty) ...[
              const Divider(height: 24),
              _buildReversePropertiesList(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final title = entity.getStringProperty('name', locale: locale, defaultValue: '').isNotEmpty
        ? entity.getStringProperty('name', locale: locale)
        : entity.getStringProperty('headline', locale: locale, defaultValue: entity.primaryType);

    final descLocStr = LocalizedString.from(entity.getProperty('description'));
    final descText = descLocStr.resolve(locale);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: entity.types.map((t) => _buildTypeBadge(t)).toList(),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: theme.headerTextStyle,
          textDirection: descLocStr.textDirection,
        ),
        if (descText.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            descText,
            style: theme.bodyTextStyle,
            textDirection: descLocStr.textDirection,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildTypeBadge(String typeName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: theme.accentBadgeColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        typeName,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: theme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildPropertiesList(BuildContext context) {
    final List<Widget> propWidgets = [];

    entity.properties.forEach((key, value) {
      if (key == 'name' || key == 'headline' || key == 'description') return;

      final propWidget = _renderPropertyValue(context, key, value);
      if (propWidget != null) {
        propWidgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: propWidget,
        ));
      }
    });

    if (propWidgets.isEmpty) {
      return Text('No additional attributes.', style: theme.captionTextStyle);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: propWidgets,
    );
  }

  Widget _buildReversePropertiesList(BuildContext context) {
    final List<Widget> reverseWidgets = [];

    entity.reverseProperties.forEach((key, value) {
      final formattedKey = _formatPropertyName(key);
      reverseWidgets.add(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.swap_horizontal_circle_outlined, size: 14, color: theme.secondaryColor),
              const SizedBox(width: 4),
              Text('Referenced by $formattedKey:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: theme.secondaryColor)),
            ],
          ),
          const SizedBox(height: 4),
          _renderSingleValue(context, key, value),
        ],
      ));
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: reverseWidgets,
    );
  }

  Widget? _renderPropertyValue(BuildContext context, String key, dynamic value) {
    if (value == null) return null;

    final formattedKey = _formatPropertyName(key);

    if (value is SchemaEntity) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$formattedKey:', style: TextStyle(fontWeight: FontWeight.w600, color: theme.subtitleColor)),
          const SizedBox(height: 4),
          InkWell(
            onTap: value.id != null && onEntityTap != null ? () => onEntityTap!(value.id!) : null,
            child: AutoSchemaWidget(entity: value, locale: locale, theme: theme, onEntityTap: onEntityTap),
          ),
        ],
      );
    }

    if (value is List) {
      if (value.isEmpty) return null;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$formattedKey (${value.length}):', style: TextStyle(fontWeight: FontWeight.w600, color: theme.subtitleColor)),
          const SizedBox(height: 4),
          ...value.map((item) => Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 2.0),
            child: _renderSingleValue(context, key, item),
          )),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$formattedKey:',
            style: TextStyle(fontWeight: FontWeight.w600, color: theme.subtitleColor, fontSize: 13),
          ),
        ),
        Expanded(
          child: _renderSingleValue(context, key, value),
        ),
      ],
    );
  }

  Widget _renderSingleValue(BuildContext context, String key, dynamic item) {
    if (item is SchemaEntity) {
      return InkWell(
        onTap: item.id != null && onEntityTap != null ? () => onEntityTap!(item.id!) : null,
        child: AutoSchemaWidget(entity: item, locale: locale, theme: theme, onEntityTap: onEntityTap),
      );
    }

    final locStr = LocalizedString.from(item);
    final strVal = locStr.resolve(locale);

    // Check if value is a Schema.org Enumeration member
    final ontology = SchemaOntology();
    if (ontology.isLoaded) {
      final enumMember = ontology.getEnumerationMember(strVal);
      if (enumMember != null) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            border: Border.all(color: Colors.blue.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            enumMember.label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
          ),
        );
      }
    }

    if (key == 'url' || key == 'sameAs' || key == 'image') {
      return Text(
        strVal,
        style: TextStyle(color: theme.primaryColor, decoration: TextDecoration.underline, fontSize: 13),
      );
    }

    return Text(
      strVal,
      style: theme.bodyTextStyle,
      textDirection: locStr.textDirection,
    );
  }

  String _formatPropertyName(String key) {
    if (key.isEmpty) return '';
    final result = key.replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}');
    return result[0].toUpperCase() + result.substring(1);
  }
}
