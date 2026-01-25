import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../screens/scheme_details_screen.dart';
import '../screens/search_results_screen.dart';

class SchemeSearchDelegate extends SearchDelegate {
  @override
  String get searchFieldLabel => 'Search schemes';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  // 🔹 Suggestions WHILE typing
  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.trim().isEmpty) {
      return const Center(child: Text("Start typing to search schemes"));
    }

    return FutureBuilder<List<dynamic>>(
      future: ApiService.searchSchemes(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No suggestions found"));
        }

        final results = snapshot.data!;

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final title = results[index]["title"];

            return ListTile(
              title: Text(title),
              onTap: () {
                close(context, null);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SchemeDetailsScreen(title: title),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // 🔹 Enter key pressed → full results page
  @override
  Widget buildResults(BuildContext context) {
    return SearchResultsScreen(query: query);
  }
}
