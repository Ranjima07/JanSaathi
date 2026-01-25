import 'package:flutter/material.dart';
import '../screens/scheme_details_screen.dart';
import '../services/api_service.dart';

class SearchResultsScreen extends StatefulWidget {
  final String query;

  const SearchResultsScreen({super.key, required this.query});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  bool isLoading = true;
  List<dynamic> results = [];

  // 🎨 Same theme colors as HomeScreen
  final Color primaryPurple = const Color(0xFF6C4AB6);
  final Color backgroundColor = const Color(0xFFF5F7FA);

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    try {
      final data = await ApiService.searchSchemes(widget.query);
      setState(() {
        results = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Search results error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: isLoading
          ? Center(child: CircularProgressIndicator(color: primaryPurple))
          : results.isEmpty
          ? _emptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: results.length,
              itemBuilder: (context, index) {
                final scheme = results[index];
                final title = scheme['title'] ?? 'No Title';

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SchemeDetailsScreen(title: title),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          // Left accent dot
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: primaryPurple,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Title
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          // Arrow
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: primaryPurple,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 48, color: primaryPurple),
            const SizedBox(height: 12),
            const Text(
              "No schemes found",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            const Text(
              "Try a different keyword",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
