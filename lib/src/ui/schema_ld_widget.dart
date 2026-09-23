import 'dart:convert';
import 'package:flutter/material.dart';

import '../graph/graph_topology.dart';
import '../ontology/schema_ld_validator.dart';
import '../ontology/schema_ontology.dart';
import '../ontology/schema_validator.dart';
import '../theme/schema_ui_theme.dart';
import 'auto_schema_widget.dart';

/// Entry-point Widget for the Schema.org JSON-LD UI Framework.
class SchemaLdWidget extends StatefulWidget {
  final dynamic jsonLd; // String or Map/List
  final Locale? locale;
  final SchemaUiTheme? theme;
  final ValidationMode validationMode;
  final void Function(ValidationReport report)? onValidationReport;
  final void Function(String entityId)? onEntityTap;

  const SchemaLdWidget({
    super.key,
    required this.jsonLd,
    this.locale,
    this.theme,
    this.validationMode = ValidationMode.warning,
    this.onValidationReport,
    this.onEntityTap,
  });

  @override
  State<SchemaLdWidget> createState() => _SchemaLdWidgetState();
}

class _SchemaLdWidgetState extends State<SchemaLdWidget> {
  late GraphTopology _topology;
  ValidationReport? _report;

  @override
  void initState() {
    super.initState();
    _processJsonLd();
  }

  @override
  void didUpdateWidget(covariant SchemaLdWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.jsonLd != widget.jsonLd || oldWidget.validationMode != widget.validationMode) {
      _processJsonLd();
    }
  }

  void _processJsonLd() {
    dynamic parsed;
    if (widget.jsonLd is String) {
      try {
        parsed = jsonDecode(widget.jsonLd as String);
      } catch (e) {
        parsed = {};
      }
    } else {
      parsed = widget.jsonLd;
    }

    // Run validator
    final validator = SchemaLdValidator(
      ontology: SchemaOntology(),
      mode: widget.validationMode,
    );
    _report = validator.validate(parsed);

    if (widget.onValidationReport != null && _report != null) {
      widget.onValidationReport!(_report!);
    }

    // Parse topology
    _topology = GraphTopology.parse(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveTheme = widget.theme ?? const SchemaUiTheme();

    if (_topology.rootEntities.isEmpty) {
      return Center(
        child: Text('No valid Schema.org entities found.', style: effectiveTheme.captionTextStyle),
      );
    }

    return ListView.builder(
      itemCount: _topology.rootEntities.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final entity = _topology.rootEntities[index];
        return AutoSchemaWidget(
          entity: entity,
          locale: widget.locale,
          theme: effectiveTheme,
          onEntityTap: widget.onEntityTap,
        );
      },
    );
  }
}
