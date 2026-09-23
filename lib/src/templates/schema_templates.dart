import 'package:flutter/material.dart';
import '../graph/graph_topology.dart';
import '../theme/schema_ui_theme.dart';
import '../ui/auto_schema_widget.dart';
import '../ui/schema_widget_registry.dart';

/// Pre-built template widgets for common Schema.org types while serving as examples.
class SchemaTemplates {
  /// Registers standard default templates into [SchemaWidgetRegistry].
  static void registerDefaultTemplates() {
    final registry = SchemaWidgetRegistry.instance;

    registry.registerType('Article', _buildArticleTemplate);
    registry.registerType('TechArticle', _buildArticleTemplate);
    registry.registerType('Product', _buildProductTemplate);
    registry.registerType('Person', _buildPersonTemplate);
    registry.registerType('Organization', _buildOrganizationTemplate);
    registry.registerType('Event', _buildEventTemplate);
    registry.registerType('Recipe', _buildRecipeTemplate);
    registry.registerType('Place', _buildPlaceTemplate);
    registry.registerType('LocalBusiness', _buildPlaceTemplate);
    registry.registerType('PropertyValue', _buildPropertyValueTemplate);
  }

  static Widget _buildArticleTemplate(
    BuildContext context,
    SchemaEntity entity, {
    Locale? locale,
    SchemaUiTheme? theme,
    void Function(String id)? onEntityTap,
  }) {
    final effTheme = theme ?? const SchemaUiTheme();
    final title = entity.getStringProperty('headline', locale: locale, defaultValue: entity.getStringProperty('name', locale: locale));
    final author = entity.getProperty('author');
    final publisher = entity.getProperty('publisher');
    final datePublished = entity.getStringProperty('datePublished', locale: locale);

    return Card(
      elevation: effTheme.cardElevation,
      color: effTheme.cardBackgroundColor,
      margin: effTheme.cardMargin,
      shape: RoundedRectangleBorder(borderRadius: effTheme.borderRadius),
      child: Padding(
        padding: effTheme.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.article_outlined, color: effTheme.primaryColor),
                const SizedBox(width: 8),
                Text('ARTICLE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: effTheme.primaryColor, letterSpacing: 1.1)),
                const Spacer(),
                if (datePublished.isNotEmpty)
                  Text(datePublished.split('T').first, style: effTheme.captionTextStyle),
              ],
            ),
            const SizedBox(height: 12),
            Text(title, style: effTheme.headerTextStyle),
            if (entity.getStringProperty('description', locale: locale).isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(entity.getStringProperty('description', locale: locale), style: effTheme.bodyTextStyle),
            ],
            const SizedBox(height: 12),
            if (author != null)
              _buildEntityChip('Author', author, locale, effTheme, onEntityTap),
            if (publisher != null)
              _buildEntityChip('Publisher', publisher, locale, effTheme, onEntityTap),
          ],
        ),
      ),
    );
  }

  static Widget _buildProductTemplate(
    BuildContext context,
    SchemaEntity entity, {
    Locale? locale,
    SchemaUiTheme? theme,
    void Function(String id)? onEntityTap,
  }) {
    final effTheme = theme ?? const SchemaUiTheme();
    final name = entity.getStringProperty('name', locale: locale);
    final offers = entity.getProperty('offers');

    String priceStr = '';
    if (offers is SchemaEntity) {
      final price = offers.getStringProperty('price', locale: locale);
      final currency = offers.getStringProperty('priceCurrency', locale: locale);
      if (price.isNotEmpty) priceStr = '$currency $price';
    } else if (offers is Map) {
      priceStr = '${offers['priceCurrency'] ?? ''} ${offers['price'] ?? ''}';
    }

    return Card(
      elevation: effTheme.cardElevation,
      color: effTheme.cardBackgroundColor,
      margin: effTheme.cardMargin,
      shape: RoundedRectangleBorder(borderRadius: effTheme.borderRadius),
      child: Padding(
        padding: effTheme.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shopping_bag_outlined, color: effTheme.secondaryColor),
                const SizedBox(width: 8),
                Text('PRODUCT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: effTheme.secondaryColor, letterSpacing: 1.1)),
                const Spacer(),
                if (priceStr.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(12)),
                    child: Text(priceStr, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade900)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(name, style: effTheme.headerTextStyle),
            if (entity.getStringProperty('description', locale: locale).isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(entity.getStringProperty('description', locale: locale), style: effTheme.bodyTextStyle),
            ],
          ],
        ),
      ),
    );
  }

  static Widget _buildPersonTemplate(
    BuildContext context,
    SchemaEntity entity, {
    Locale? locale,
    SchemaUiTheme? theme,
    void Function(String id)? onEntityTap,
  }) {
    final effTheme = theme ?? const SchemaUiTheme();
    final name = entity.getStringProperty('name', locale: locale);
    final jobTitle = entity.getStringProperty('jobTitle', locale: locale);

    return Card(
      elevation: effTheme.cardElevation,
      color: effTheme.cardBackgroundColor,
      margin: effTheme.cardMargin,
      shape: RoundedRectangleBorder(borderRadius: effTheme.borderRadius),
      child: Padding(
        padding: effTheme.cardPadding,
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: effTheme.accentBadgeColor,
              child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'P', style: TextStyle(color: effTheme.primaryColor, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: effTheme.headerTextStyle.copyWith(fontSize: 16)),
                  if (jobTitle.isNotEmpty)
                    Text(jobTitle, style: effTheme.captionTextStyle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildOrganizationTemplate(
    BuildContext context,
    SchemaEntity entity, {
    Locale? locale,
    SchemaUiTheme? theme,
    void Function(String id)? onEntityTap,
  }) {
    final effTheme = theme ?? const SchemaUiTheme();
    final name = entity.getStringProperty('name', locale: locale);
    final url = entity.getStringProperty('url', locale: locale);

    return Card(
      elevation: effTheme.cardElevation,
      color: effTheme.cardBackgroundColor,
      margin: effTheme.cardMargin,
      shape: RoundedRectangleBorder(borderRadius: effTheme.borderRadius),
      child: Padding(
        padding: effTheme.cardPadding,
        child: Row(
          children: [
            Icon(Icons.business_rounded, color: effTheme.primaryColor, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: effTheme.headerTextStyle.copyWith(fontSize: 16)),
                  if (url.isNotEmpty) Text(url, style: TextStyle(color: effTheme.primaryColor, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildEventTemplate(
    BuildContext context,
    SchemaEntity entity, {
    Locale? locale,
    SchemaUiTheme? theme,
    void Function(String id)? onEntityTap,
  }) {
    final effTheme = theme ?? const SchemaUiTheme();
    final name = entity.getStringProperty('name', locale: locale);
    final startDate = entity.getStringProperty('startDate', locale: locale);

    return Card(
      elevation: effTheme.cardElevation,
      color: effTheme.cardBackgroundColor,
      margin: effTheme.cardMargin,
      shape: RoundedRectangleBorder(borderRadius: effTheme.borderRadius),
      child: Padding(
        padding: effTheme.cardPadding,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: effTheme.accentBadgeColor, borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.event, color: effTheme.primaryColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: effTheme.headerTextStyle.copyWith(fontSize: 16)),
                  if (startDate.isNotEmpty) Text('Date: $startDate', style: effTheme.captionTextStyle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildRecipeTemplate(
    BuildContext context,
    SchemaEntity entity, {
    Locale? locale,
    SchemaUiTheme? theme,
    void Function(String id)? onEntityTap,
  }) {
    final effTheme = theme ?? const SchemaUiTheme();
    final name = entity.getStringProperty('name', locale: locale);
    final prepTime = entity.getStringProperty('prepTime', locale: locale);
    final cookTime = entity.getStringProperty('cookTime', locale: locale);

    return Card(
      elevation: effTheme.cardElevation,
      color: effTheme.cardBackgroundColor,
      margin: effTheme.cardMargin,
      shape: RoundedRectangleBorder(borderRadius: effTheme.borderRadius),
      child: Padding(
        padding: effTheme.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.restaurant_menu, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                Text('RECIPE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.orange.shade700, letterSpacing: 1.1)),
              ],
            ),
            const SizedBox(height: 8),
            Text(name, style: effTheme.headerTextStyle),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              children: [
                if (prepTime.isNotEmpty) Text('Prep: $prepTime', style: effTheme.captionTextStyle),
                if (cookTime.isNotEmpty) Text('Cook: $cookTime', style: effTheme.captionTextStyle),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildPlaceTemplate(
    BuildContext context,
    SchemaEntity entity, {
    Locale? locale,
    SchemaUiTheme? theme,
    void Function(String id)? onEntityTap,
  }) {
    final effTheme = theme ?? const SchemaUiTheme();
    final name = entity.getStringProperty('name', locale: locale);

    return Card(
      elevation: effTheme.cardElevation,
      color: effTheme.cardBackgroundColor,
      margin: effTheme.cardMargin,
      shape: RoundedRectangleBorder(borderRadius: effTheme.borderRadius),
      child: Padding(
        padding: effTheme.cardPadding,
        child: Row(
          children: [
            Icon(Icons.location_on_outlined, color: Colors.redAccent, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(name, style: effTheme.headerTextStyle.copyWith(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildPropertyValueTemplate(
    BuildContext context,
    SchemaEntity entity, {
    Locale? locale,
    SchemaUiTheme? theme,
    void Function(String id)? onEntityTap,
  }) {
    final effTheme = theme ?? const SchemaUiTheme();
    final name = entity.getStringProperty('name', locale: locale);
    final value = entity.getStringProperty('value', locale: locale);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      margin: const EdgeInsets.only(right: 6, bottom: 6),
      decoration: BoxDecoration(
        color: effTheme.accentBadgeColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text('$name: $value', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: effTheme.textColor)),
    );
  }

  static Widget _buildEntityChip(
    String label,
    dynamic entityVal,
    Locale? locale,
    SchemaUiTheme theme,
    void Function(String id)? onEntityTap,
  ) {
    if (entityVal is SchemaEntity) {
      final name = entityVal.getStringProperty('name', locale: locale, defaultValue: entityVal.primaryType);
      return Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Row(
          children: [
            Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: theme.subtitleColor)),
            ActionChip(
              label: Text(name, style: TextStyle(fontSize: 12, color: theme.primaryColor)),
              onPressed: entityVal.id != null && onEntityTap != null ? () => onEntityTap(entityVal.id!) : null,
            ),
          ],
        ),
      );
    }
    return Text('$label: ${entityVal.toString()}', style: theme.captionTextStyle);
  }
}
