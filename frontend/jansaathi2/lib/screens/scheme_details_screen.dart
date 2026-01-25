import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SchemeDetailsScreen extends StatefulWidget {
  final String title;

  const SchemeDetailsScreen({super.key, required this.title});

  @override
  State<SchemeDetailsScreen> createState() => _SchemeDetailsScreenState();
}

class _SchemeDetailsScreenState extends State<SchemeDetailsScreen> {
  Map<String, dynamic>? schemeData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSchemeDetails();
  }

  Future<void> fetchSchemeDetails() async {
    try {
      final data = await ApiService.getSchemeDetails(widget.title);
      setState(() {
        schemeData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Scheme Details",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : schemeData == null
          ? const Center(child: Text("Failed to load scheme details"))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle(),
                  const SizedBox(height: 12),
                  _buildCategory(),

                  // 🔗 Scheme Website Link
                  const SizedBox(height: 10),
                  if (schemeData!["scheme_url"] != null)
                    InkWell(
                      onTap: () {},
                      child: Text(
                        schemeData!["scheme_url"],
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          fontSize: 14,
                        ),
                      ),
                    ),

                  const SizedBox(height: 12),

                  // ⚠ Closed Scheme Warning
                  if (schemeData!["is_closed"] == true)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "⚠ This scheme is closed",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  const SizedBox(height: 10),
                  _buildContentSections(),
                ],
              ),
            ),
    );
  }

  Widget _buildTitle() {
    return Text(
      schemeData!["title"],
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildCategory() {
    return Chip(
      label: Text(
        schemeData!["category"],
        style: const TextStyle(color: Colors.black),
      ),
      backgroundColor: Colors.orange.shade100,
    );
  }

  Widget _buildContentSections() {
    final content = schemeData!["content"] as Map<String, dynamic>;

    return Column(
      children: content.entries.map((entry) {
        return _buildSection(entry.key, entry.value);
      }).toList(),
    );
  }

  Widget _buildSection(String title, List<dynamic> items) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            ...items.map(
              (text) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  text.toString(),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
