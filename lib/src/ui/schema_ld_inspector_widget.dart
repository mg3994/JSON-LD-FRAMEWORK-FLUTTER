import 'dart:convert';
import 'package:flutter/material.dart';
import '../graph/graph_topology.dart';
import '../ontology/schema_ld_validator.dart';
import '../ontology/schema_ontology.dart';
import '../ontology/schema_validator.dart';

/// Developer Inspection Sheet displaying JSON-LD Graph, Context Term mappings, and Ontology Report.
class SchemaLdInspectorWidget extends StatelessWidget {
  final dynamic jsonLd;
  final ValidationMode validationMode;

  const SchemaLdInspectorWidget({
    super.key,
    required this.jsonLd,
    this.validationMode = ValidationMode.warning,
  });

  @override
  Widget build(BuildContext context) {
    dynamic parsed;
    if (jsonLd is String) {
      try {
        parsed = jsonDecode(jsonLd);
      } catch (e) {
        parsed = {};
      }
    } else {
      parsed = jsonLd;
    }

    final validator = SchemaLdValidator(ontology: SchemaOntology(), mode: validationMode);
    final report = validator.validate(parsed);
    final topology = GraphTopology.parse(parsed);

    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.developer_mode, color: Colors.indigo),
                SizedBox(width: 8),
                Text('JSON-LD Framework Inspector', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const Divider(),
            Text('Entities Parsed: ${topology.rootEntities.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Vocab: ${topology.context.vocab ?? 'https://schema.org/'}'),
            Text('Prefixes Registered: ${topology.context.prefixes.keys.join(', ')}'),
            const SizedBox(height: 12),
            const Text('Validation Summary:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Status: ${report.isValid ? 'VALID' : 'INVALID'}', style: TextStyle(color: report.isValid ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
            Text('Issues Found: ${report.errors.length}'),
            ...report.errors.take(5).map((e) => Text('• ${e.toString()}', style: const TextStyle(fontSize: 12, color: Colors.orange))),
          ],
        ),
      ),
    );
  }
}
