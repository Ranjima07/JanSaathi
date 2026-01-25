import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'scheme_details_screen.dart';

class CategorySchemesScreen extends StatefulWidget {
  final String title;
  final List<String> categories;

  const CategorySchemesScreen({
    super.key,
    required this.title,
    required this.categories,
  });

  @override
  State<CategorySchemesScreen> createState() => _CategorySchemesScreenState();
}

class _CategorySchemesScreenState extends State<CategorySchemesScreen> {
  bool isLoading = true;
  List<dynamic> schemes = [];

  @override
  void initState() {
    super.initState();
    fetchSchemes();
  }

  /// Fetch schemes for one or more categories and merge results
  Future<void> fetchSchemes() async {
    try {
      List<dynamic> allSchemes = [];

      for (final category in widget.categories) {
        final data = await ApiService.getSchemesByCategory(category);
        allSchemes.addAll(data);
      }

      setState(() {
        schemes = allSchemes;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Category fetch error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryPurple = Color(0xFF6A4BC3);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryPurple))
          : schemes.isEmpty
          ? const Center(
              child: Text(
                "No schemes found",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              itemCount: schemes.length,
              itemBuilder: (context, index) {
                final scheme = schemes[index];
                final title = scheme["title"];

                return Card(
                  elevation: 2,
                  shadowColor: Colors.black12,
                  color: const Color.fromARGB(
                    255,
                    108,
                    74,
                    176,
                  ), // home-style soft purple
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    splashColor: primaryPurple.withOpacity(0.15),
                    highlightColor: primaryPurple.withOpacity(0.05),
                    onTap: () {
                      if (title == null) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SchemeDetailsScreen(title: title),
                        ),
                      );
                    },
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      title: Text(
                        title ?? "No Title",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color.fromARGB(221, 248, 245, 245),
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Color.fromARGB(255, 79, 41, 182),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
