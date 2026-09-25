# Schema.org JSON-LD Dynamic UI Framework (`schema_org_flutter`)

A flexible, powerful, and expressive Flutter UI SDK & Schema Engine that parses, validates, and dynamically renders **Schema.org JSON-LD** data into structured, customizable Flutter widgets.

Covers the complete official Schema.org ontology specification (`https://schema.org/version/latest/schemaorg-current-https.jsonld`).

---

## 🌟 Key Features

- **100% Schema.org Specification Coverage**: Dynamically parses classes, subclasses (`subClassOf`), properties, and ranges directly from the official Schema.org JSON-LD ontology.
- **Full JSON-LD Keyword Engine**: Native support for `@context`, `@id`, `@type`, `@graph`, `@value`, `@language`, `@direction`, `@reverse`, `@list`, `@set`, `@included`, `@nest`, `@index`, `@vocab`, and `@base`.
- **Universal Dynamic Renderer (`AutoSchemaWidget`)**: Renders clean, responsive, and accessible Flutter cards for **ANY** arbitrary Schema.org entity.
- **Strict Data Type Validation & Reporting**: Validates ISO 8601 dates/durations, ISO 4217 currency codes, and absolute URIs with customizable `ValidationMode` (`strict`, `warning`, `permissive`).
- **Graph Topology Engine**: Supports `@graph` array payloads, identity anchoring (`@id`), cross-entity linking, and multi-typed entities (`"@type": ["Restaurant", "TouristAttraction"]`).
- **Localization & Pluralization**: Automatically handles language-tagged string values (`{"@value": "Apple", "@language": "en"}`), text direction (`@direction` LTR/RTL), Flutter `Locale` matching, and pluralization templates (`{count}`).
- **Custom Widget Registry**: Override UI rendering for any Schema.org `@type` or property using `SchemaWidgetRegistry`.
- **Pre-packaged UI Templates**: Includes standard responsive UI widgets for common types (`Article`, `TechArticle`, `Product`, `Person`, `Organization`, `Event`, `Recipe`, `Place`, `PropertyValue`).
- **CI/CD Workflows**: Ready-to-use GitHub Actions for linting, static analysis, unit testing, dry-run package publishing, and web demo deployment.

---

## 📖 Complete JSON-LD Keyword Specification Guide

The framework implements comprehensive support for all core JSON-LD W3C specifications and Schema.org conventions:

| Keyword | Description | Usage Example in JSON-LD | Framework Processing Behavior |
| :--- | :--- | :--- | :--- |
| `@context` | Sets vocabulary context or prefixes | `"@context": "https://schema.org"` | Resolves custom term prefixes and default vocabularies. |
| `@id` | Anchor URI identifier | `"@id": "https://example.com/#author"` | Anchors entity nodes in `GraphTopology` graph map. |
| `@type` | Canonical entity class / multi-typing | `"@type": ["Restaurant", "Place"]` | Dynamic-casts types & matches `SchemaWidgetRegistry` builders. |
| `@graph` | Interconnected entity array | `"@graph": [{...}, {...}]` | Unpacks entity graph and builds cross-references. |
| `@value` | Value object wrapper | `{"@value": "Apple", "@language": "en"}` | Extracted by `LocalizedString` engine. |
| `@language` | BCP 47 language tag | `{"@value": "Pomme", "@language": "fr"}` | Matches against active Flutter `Locale`. |
| `@direction` | Text reading order | `{"@value": "مرحبا", "@direction": "rtl"}` | Applies `TextDirection.rtl` or `TextDirection.ltr`. |
| `@reverse` | Inverse relation linking | `"@reverse": {"author": {...}}` | Renders inverse relation chips ("Referenced by"). |
| `@nest` | Groups properties under nested map | `"@nest": {"price": "99"}` | Flattens nested fields onto parent entity properties. |
| `@list` | Preserves ordered sequences | `"itemListElement": {"@list": [...]}` | Preserves strict element ordering in UI lists. |
| `@set` | Unordered set collection | `"keywords": {"@set": ["AI", "Dart"]}` | Normalizes array items cleanly. |
| `@included` | Detached graph nodes | `"@included": [{...}]` | Registers unlinked entities into `GraphTopology`. |
| `@vocab` | Default vocabulary IRI | `"@vocab": "https://schema.org/"` | Expands non-prefixed property names to absolute URIs. |

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
