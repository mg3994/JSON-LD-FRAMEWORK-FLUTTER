import 'dart:convert';
import 'package:flutter/material.dart';
import '../ontology/schema_ontology.dart';
import 'schema_ld_widget.dart';

/// Form-based Visual Schema Builder Widget allowing users to pick any Schema.org type, fill dynamic property fields, validate, and preview JSON-LD.
class SchemaBuilderWidget extends StatefulWidget {
  final void Function(String jsonLd)? onJsonLdGenerated;

  const SchemaBuilderWidget({super.key, this.onJsonLdGenerated});

  @override
  State<SchemaBuilderWidget> createState() => _SchemaBuilderWidgetState();
}

class _SchemaBuilderWidgetState extends State<SchemaBuilderWidget> {
  final SchemaOntology _ontology = SchemaOntology();
  String _selectedClass = 'Product';
  final Map<String, TextEditingController> _controllers = {};
  List<SchemaPropertyDef> _availableProperties = [];
  String _generatedJsonLd = '';

  @override
  void initState() {
    super.initState();
    _loadTypeProperties(_selectedClass);
  }

  void _loadTypeProperties(String className) {
    _availableProperties = _ontology.getPropertiesForType(className);
    if (_availableProperties.isEmpty) {
      _availableProperties = [
        SchemaPropertyDef(id: 'name', label: 'Name', comment: 'Entity name', domainIncludes: [className], rangeIncludes: ['Text']),
        SchemaPropertyDef(id: 'description', label: 'Description', comment: 'Entity description', domainIncludes: [className], rangeIncludes: ['Text']),
        SchemaPropertyDef(id: 'url', label: 'URL', comment: 'Entity URL', domainIncludes: [className], rangeIncludes: ['URL']),
      ];
    }

    _controllers.clear();
    for (final prop in _availableProperties) {
      _controllers[prop.id] = TextEditingController();
    }
    _generateJsonLd();
  }

  void _generateJsonLd() {
    final Map<String, dynamic> data = {
      '@context': 'https://schema.org',
      '@type': _selectedClass,
    };

    _controllers.forEach((key, controller) {
      if (controller.text.trim().isNotEmpty) {
        data[key] = controller.text.trim();
      }
    });

    final formattedJson = const JsonEncoder.withIndent('  ').convert(data);
    setState(() {
      _generatedJsonLd = formattedJson;
    });

    if (widget.onJsonLdGenerated != null) {
      widget.onJsonLdGenerated!(_generatedJsonLd);
    }
  }

  @override
  Widget build(BuildContext context) {
    final commonClasses = ['Product', 'Article', 'TechArticle', 'Person', 'Organization', 'Event', 'Recipe', 'LocalBusiness'];

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Select Schema.org Type: ', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: commonClasses.contains(_selectedClass) ? _selectedClass : 'Product',
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedClass = val);
                    _loadTypeProperties(val);
                  }
                },
                items: commonClasses.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: ListView.builder(
                    itemCount: _availableProperties.take(10).length,
                    itemBuilder: (context, index) {
                      final prop = _availableProperties[index];
                      final controller = _controllers[prop.id];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: TextField(
                          controller: controller,
                          decoration: InputDecoration(
                            labelText: prop.label,
                            hintText: prop.comment,
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (_) => _generateJsonLd(),
                        ),
                      );
                    },
                  ),
                ),
                const VerticalDivider(),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Live Framework UI Preview:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SchemaLdWidget(jsonLd: _generatedJsonLd),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
