import 'package:flutter/material.dart';
import '../ontology/schema_search_service.dart';

/// Flutter widget providing a search interface to explore all 939+ classes, 1,538+ properties, and enumerations.
class SchemaExplorerWidget extends StatefulWidget {
  const SchemaExplorerWidget({super.key});

  @override
  State<SchemaExplorerWidget> createState() => _SchemaExplorerWidgetState();
}

class _SchemaExplorerWidgetState extends State<SchemaExplorerWidget> {
  final TextEditingController _controller = TextEditingController();
  final SchemaSearchService _searchService = SchemaSearchService();
  List<SearchResultItem> _results = [];

  @override
  void initState() {
    super.initState();
    _performSearch('Article');
  }

  void _performSearch(String query) {
    setState(() {
      _results = _searchService.search(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Search Schema.org classes, properties, enumerations...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _controller.clear();
                  _performSearch('');
                },
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: _performSearch,
          ),
        ),
        Expanded(
          child: _results.isEmpty
              ? const Center(child: Text('No matching Schema.org elements found.'))
              : ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final item = _results[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: ListTile(
                        leading: _buildTypeAvatar(item.type),
                        title: Text(item.label, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (item.comment.isNotEmpty)
                              Text(item.comment, maxLines: 2, overflow: TextOverflow.ellipsis),
                            if (item.superClasses != null && item.superClasses!.isNotEmpty)
                              Text('Subclass of: ${item.superClasses!.join(', ')}', style: TextStyle(fontSize: 11, color: Colors.indigo.shade700)),
                            if (item.domainIncludes != null && item.domainIncludes!.isNotEmpty)
                              Text('Domains: ${item.domainIncludes!.take(4).join(', ')}', style: TextStyle(fontSize: 11, color: Colors.teal.shade700)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTypeAvatar(SearchResultType type) {
    switch (type) {
      case SearchResultType.schemaClass:
        return CircleAvatar(backgroundColor: Colors.indigo.shade100, child: const Icon(Icons.class_, color: Colors.indigo));
      case SearchResultType.schemaProperty:
        return CircleAvatar(backgroundColor: Colors.teal.shade100, child: const Icon(Icons.label, color: Colors.teal));
      case SearchResultType.schemaEnumeration:
        return CircleAvatar(backgroundColor: Colors.amber.shade100, child: const Icon(Icons.list, color: Colors.amber));
    }
  }
}
