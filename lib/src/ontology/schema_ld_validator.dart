import 'schema_ontology.dart';
import 'schema_validator.dart';

/// Validates raw JSON-LD map or list against Schema.org ontology rules.
class SchemaLdValidator {
  final SchemaOntology ontology;
  final ValidationMode mode;

  SchemaLdValidator({
    SchemaOntology? ontology,
    this.mode = ValidationMode.warning,
  }) : ontology = ontology ?? SchemaOntology();

  ValidationReport validate(dynamic jsonLd) {
    final errors = <ValidationError>[];
    _validateNode(jsonLd, path: '\$', errors: errors);
    return ValidationReport(mode: mode, errors: errors);
  }

  void _validateNode(dynamic node, {required String path, required List<ValidationError> errors}) {
    if (node is List) {
      for (int i = 0; i < node.length; i++) {
        _validateNode(node[i], path: '$path[$i]', errors: errors);
      }
      return;
    }

    if (node is! Map<String, dynamic>) {
      return;
    }

    // Check if it's a top-level @graph
    if (node.containsKey('@graph')) {
      _validateNode(node['@graph'], path: '$path.@graph', errors: errors);
      return;
    }

    // Validate @type
    final dynamic typeVal = node['@type'];
    if (typeVal == null) {
      if (node.containsKey('@id') && node.keys.length == 1) {
        // Pure reference node, valid
        return;
      }
      errors.add(ValidationError(
        path: path,
        message: 'Missing "@type" in entity payload.',
        severity: mode == ValidationMode.strict ? ValidationSeverity.error : ValidationSeverity.warning,
      ));
      return;
    }

    final List<String> types = typeVal is List
        ? typeVal.map((e) => e.toString()).toList()
        : [typeVal.toString()];

    // Validate each type against ontology if loaded
    if (ontology.isLoaded) {
      for (final type in types) {
        final cleanType = _cleanName(type);
        final cls = ontology.getClass(cleanType);
        if (cls == null && !_isKnownBuiltinType(cleanType)) {
          errors.add(ValidationError(
            path: path,
            message: 'Unknown Schema.org type "$type".',
            severity: ValidationSeverity.warning,
          ));
        }
      }
    }

    // Validate properties
    node.forEach((key, value) {
      if (key.startsWith('@')) return; // Skip keywords like @id, @context, @type

      final cleanProp = _cleanName(key);
      if (ontology.isLoaded) {
        final propDef = ontology.getProperty(cleanProp);
        if (propDef == null) {
          errors.add(ValidationError(
            path: '$path.$key',
            message: 'Unknown Schema.org property "$key".',
            severity: ValidationSeverity.info,
          ));
        } else {
          // Verify domainIncludes if defined
          if (propDef.domainIncludes.isNotEmpty) {
            bool domainMatch = false;
            for (final type in types) {
              final cleanType = _cleanName(type);
              for (final domain in propDef.domainIncludes) {
                if (domain == cleanType || ontology.isSubclassOf(cleanType, domain)) {
                  domainMatch = true;
                  break;
                }
              }
              if (domainMatch) break;
            }
            if (!domainMatch) {
              errors.add(ValidationError(
                path: '$path.$key',
                message: 'Property "$key" is not defined for type(s) ${types.join(", ")} in Schema.org ontology.',
                severity: ValidationSeverity.info,
              ));
            }
          }
        }
      }

      // Check specific data type rules for known properties
      _validatePropertyValues(cleanProp, value, path: '$path.$key', errors: errors);

      // Recurse into object/array values
      if (value is Map || value is List) {
        _validateNode(value, path: '$path.$key', errors: errors);
      }
    });
  }

  void _validatePropertyValues(String propName, dynamic value, {required String path, required List<ValidationError> errors}) {
    if (value is String) {
      final isDateProp = propName.endsWith('Date') ||
          propName.endsWith('Time') ||
          propName.startsWith('valid') ||
          propName.startsWith('date') ||
          propName == 'startDate' ||
          propName == 'endDate' ||
          propName == 'birthDate' ||
          propName == 'deathDate';

      if (isDateProp) {
        if (!DataTypeValidator.isValidIsoDate(value)) {
          errors.add(ValidationError(
            path: path,
            message: 'Value "$value" is not a valid ISO 8601 date/time.',
            severity: mode == ValidationMode.strict ? ValidationSeverity.error : ValidationSeverity.warning,
          ));
        }
      } else if (propName == 'duration' || propName == 'prepTime' || propName == 'cookTime' || propName == 'totalTime') {
        if (!DataTypeValidator.isValidIsoDuration(value)) {
          errors.add(ValidationError(
            path: path,
            message: 'Value "$value" is not a valid ISO 8601 duration format (e.g. PT1H30M).',
            severity: mode == ValidationMode.strict ? ValidationSeverity.error : ValidationSeverity.warning,
          ));
        }
      } else if (propName == 'priceCurrency' || propName == 'currency') {
        if (!DataTypeValidator.isValidCurrencyCode(value)) {
          errors.add(ValidationError(
            path: path,
            message: 'Value "$value" is not a valid 3-letter ISO 4217 currency code.',
            severity: mode == ValidationMode.strict ? ValidationSeverity.error : ValidationSeverity.warning,
          ));
        }
      } else if (propName == 'url' || propName == 'sameAs' || propName == 'image') {
        if (!value.startsWith('/') && !DataTypeValidator.isAbsoluteUri(value)) {
          errors.add(ValidationError(
            path: path,
            message: 'Value "$value" should be a valid absolute URI.',
            severity: ValidationSeverity.info,
          ));
        }
      }
    }
  }

  bool _isKnownBuiltinType(String type) {
    return [
      'Thing', 'DataType', 'Text', 'Number', 'Integer', 'Float', 'Boolean', 'Date', 'DateTime', 'Time', 'URL'
    ].contains(type);
  }

  String _cleanName(String name) {
    if (name.startsWith('schema:')) return name.substring(7);
    if (name.startsWith('https://schema.org/')) return name.substring(19);
    if (name.startsWith('http://schema.org/')) return name.substring(18);
    return name;
  }
}
