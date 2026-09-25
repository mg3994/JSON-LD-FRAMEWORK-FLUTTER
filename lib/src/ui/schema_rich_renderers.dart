import 'package:flutter/material.dart';
import '../graph/graph_topology.dart';
import '../theme/schema_ui_theme.dart';

/// Rich visual renderers for ImageObject, VideoObject, GeoCoordinates, and AggregateRating.
class SchemaRichRenderers {
  static Widget buildAggregateRating(SchemaEntity entity, SchemaUiTheme theme) {
    final ratingValue = entity.getStringProperty('ratingValue', defaultValue: '5.0');
    final reviewCount = entity.getStringProperty('reviewCount', defaultValue: '0');

    final double numericRating = double.tryParse(ratingValue) ?? 5.0;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < numericRating.round() ? Icons.star : Icons.star_border,
                color: Colors.amber.shade700,
                size: 18,
              );
            }),
          ),
          const SizedBox(width: 8),
          Text(
            '$ratingValue ($reviewCount reviews)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.amber.shade900),
          ),
        ],
      ),
    );
  }

  static Widget buildGeoLocation(SchemaEntity entity, SchemaUiTheme theme) {
    final lat = entity.getStringProperty('latitude');
    final lng = entity.getStringProperty('longitude');

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.map, color: Colors.blue.shade700, size: 18),
          const SizedBox(width: 6),
          Text(
            'Geo: $lat, $lng',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blue.shade900),
          ),
        ],
      ),
    );
  }
}
