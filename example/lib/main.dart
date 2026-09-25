import 'package:flutter/material.dart';
import 'package:schema_org_flutter/schema_org_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Pre-load Schema.org ontology graph
  await SchemaOntology().loadFromAsset();
  // Register default templates for Article, Product, Person, etc.
  SchemaTemplates.registerDefaultTemplates();
  runApp(const SchemaOrgExampleApp());
}

class SchemaOrgExampleApp extends StatefulWidget {
  const SchemaOrgExampleApp({super.key});

  @override
  State<SchemaOrgExampleApp> createState() => _SchemaOrgExampleAppState();
}

class _SchemaOrgExampleAppState extends State<SchemaOrgExampleApp> {
  Locale _selectedLocale = const Locale('en');
  bool _isDarkMode = false;
  ValidationReport? _lastReport;

  final String _sampleJsonLd = '''
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
        "@id": "https://example.com/articles/schema-framework#article",
        "headline": [
          {"@value": "Building JSON-LD Dynamic UI Frameworks", "@language": "en"},
          {"@value": "Construire un framework UI JSON-LD dynamique", "@language": "fr"}
        ],
        "description": "An in-depth guide on building dynamic Flutter UI directly from Schema.org JSON-LD.",
        "datePublished": "2026-03-23T10:00:00Z",
        "author": {"@id": "https://example.com/authors/johndoe#person"}
      },
      {
        "@type": "Product",
        "@id": "https://example.com/products/flutter-book#product",
        "name": "Flutter Architecture Handbook",
        "description": "Complete guide for enterprise Flutter developers.",
        "offers": {
          "@type": "Offer",
          "price": "49.99",
          "priceCurrency": "USD",
          "availability": "InStock"
        }
      }
    ]
  }
  ''';

  @override
  Widget build(BuildContext context) {
    final theme = _isDarkMode ? SchemaUiTheme.dark() : const SchemaUiTheme();

    return MaterialApp(
      title: 'Schema.org JSON-LD UI Framework Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      ),
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          backgroundColor: theme.backgroundColor,
          appBar: AppBar(
            title: const Text('Schema.org JSON-LD Framework'),
            actions: [
              DropdownButton<Locale>(
                value: _selectedLocale,
                onChanged: (loc) {
                  if (loc != null) setState(() => _selectedLocale = loc);
                },
                items: const [
                  DropdownMenuItem(value: Locale('en'), child: Text('🇬🇧 English')),
                  DropdownMenuItem(value: Locale('fr'), child: Text('🇫🇷 Français')),
                ],
              ),
              IconButton(
                icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
                onPressed: () => setState(() => _isDarkMode = !_isDarkMode),
              ),
            ],
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.preview), text: 'Dynamic UI'),
                Tab(icon: Icon(Icons.build_circle_outlined), text: 'Schema Builder'),
                Tab(icon: Icon(Icons.search), text: 'Explorer'),
                Tab(icon: Icon(Icons.developer_mode), text: 'Inspector'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              Column(
                children: [
                  if (_lastReport != null) _buildValidationHeader(_lastReport!),
                  Expanded(
                    child: SchemaLdWidget(
                      jsonLd: _sampleJsonLd,
                      locale: _selectedLocale,
                      theme: theme,
                      validationMode: ValidationMode.warning,
                      onValidationReport: (report) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) setState(() => _lastReport = report);
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SchemaBuilderWidget(),
              const SchemaExplorerWidget(),
              SchemaLdInspectorWidget(jsonLd: _sampleJsonLd),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildValidationHeader(ValidationReport report) {
    final color = report.isValid ? Colors.green.shade800 : Colors.amber.shade900;
    final bg = report.isValid ? Colors.green.shade50 : Colors.amber.shade50;

    return Container(
      width: double.infinity,
      color: bg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(report.isValid ? Icons.check_circle_outline : Icons.warning_amber_rounded, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Ontology Validation: ${report.errors.length} notices/warnings (Status: ${report.isValid ? 'VALID' : 'INVALID'})',
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
