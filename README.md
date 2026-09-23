# Schema.org JSON-LD Dynamic UI Framework (`schema_org_flutter`)

A flexible, powerful, and expressive Flutter UI SDK & Schema Engine that parses, validates, and dynamically renders **Schema.org JSON-LD** data into structured, customizable Flutter widgets.

Covers the complete official Schema.org ontology specification (`https://schema.org/version/latest/schemaorg-current-https.jsonld`).

---

## 🌟 Key Features

- **100% Schema.org Specification Coverage**: Dynamically parses classes, subclasses (`subClassOf`), properties, and ranges directly from the official Schema.org JSON-LD ontology.
- **Universal Dynamic Renderer (`AutoSchemaWidget`)**: Renders clean, responsive, and accessible Flutter cards for **ANY** arbitrary Schema.org entity.
- **Strict Data Type Validation & Reporting**: Validates ISO 8601 dates/durations, ISO 4217 currency codes, and absolute URIs with customizable `ValidationMode` (`strict`, `warning`, `permissive`).
- **Graph Topology Engine**: Supports `@graph` array payloads, identity anchoring (`@id`), cross-entity linking, and multi-typed entities (`"@type": ["Restaurant", "TouristAttraction"]`).
- **Localization & Pluralization**: Automatically handles language-tagged string values (`{"@value": "Apple", "@language": "en"}`), Flutter `Locale` matching, and pluralization templates (`{count}`).
- **Custom Widget Registry**: Override UI rendering for any Schema.org `@type` or property using `SchemaWidgetRegistry`.
- **Pre-packaged UI Templates**: Includes standard responsive UI widgets for common types (`Article`, `TechArticle`, `Product`, `Person`, `Organization`, `Event`, `Recipe`, `Place`, `PropertyValue`).
- **CI/CD Workflows**: Ready-to-use GitHub Actions for linting, static analysis, unit testing, dry-run package publishing, and web demo deployment.

---

## 🚀 Getting Started

Add `schema_org_flutter` to your `pubspec.yaml`:

```yaml
dependencies:
  schema_org_flutter: ^0.1.0
```

Initialize standard templates in `main.dart` (optional):

```dart
import 'package:flutter/material.dart';
import 'package:schema_org_flutter/schema_org_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Register default templates for Article, Product, Person, etc.
  SchemaTemplates.registerDefaultTemplates();
  runApp(const MyApp());
}
```

---

## 💻 Usage Example

Pass raw JSON-LD (as a `String` or `Map`/`List`) directly into `SchemaLdWidget`:

```dart
import 'package:flutter/material.dart';
import 'package:schema_org_flutter/schema_org_flutter.dart';

class SchemaViewerScreen extends StatelessWidget {
  const SchemaViewerScreen({super.key});

  final String jsonLdData = '''
  {
    "@context": "https://schema.org",
    "@graph": [
      {
        "@type": "Person",
        "@id": "https://example.com/authors/johndoe#person",
        "name": "John Doe",
        "jobTitle": {"@value": "Lead Architect", "@language": "en"}
      },
      {
        "@type": "TechArticle",
        "headline": [
          {"@value": "Building JSON-LD Frameworks", "@language": "en"},
          {"@value": "Construire des Frameworks JSON-LD", "@language": "fr"}
        ],
        "description": "A comprehensive guide to dynamic Schema.org UI generation in Flutter.",
        "datePublished": "2026-03-23T10:00:00Z",
        "author": {"@id": "https://example.com/authors/johndoe#person"}
      }
    ]
  }
  ''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('JSON-LD Dynamic UI')),
      body: SchemaLdWidget(
        jsonLd: jsonLdData,
        locale: const Locale('en'),
        validationMode: ValidationMode.warning,
        onValidationReport: (report) {
          debugPrint('Validation Valid: ${report.isValid}');
        },
        onEntityTap: (entityId) {
          debugPrint('User tapped entity: $entityId');
        },
      ),
    );
  }
}
```

---

## 🎨 Customizing UI with `SchemaWidgetRegistry`

Register your own custom Flutter widgets for any custom or standard Schema.org type:

```dart
SchemaWidgetRegistry.instance.registerType('MedicalWebPage', (context, entity, {locale, theme, onEntityTap}) {
  final name = entity.getStringProperty('name', locale: locale);
  final lastReviewed = entity.getStringProperty('lastReviewed', locale: locale);

  return Container(
    padding: const EdgeInsets.all(16),
    color: Colors.teal.shade50,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.verified, color: Colors.teal),
            const SizedBox(width: 8),
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        if (lastReviewed.isNotEmpty)
          Text('Last Reviewed: $lastReviewed', style: TextStyle(color: Colors.teal.shade900)),
      ],
    ),
  );
});
```

---

## 🧪 Running Tests

Run unit and widget test suite:

```bash
flutter test
```

Run static analysis:

```bash
flutter analyze
```

---

## 📄 License

MIT License.
