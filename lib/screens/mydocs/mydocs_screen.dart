import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ugssa_app/services/api_service.dart';

class MyDocsScreen extends StatefulWidget {
  const MyDocsScreen({super.key});

  @override
  State<MyDocsScreen> createState() => _MyDocsScreenState();
}

class _MyDocsScreenState extends State<MyDocsScreen> {
  File? selectedFile;
  String extractedText = "";
  bool isLoading = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> pickDocument() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        selectedFile = File(pickedFile.path);
        extractedText = "Selected: ${pickedFile.name}";
      });
    }
  }

  Future<void> uploadDocument() async {
    if (selectedFile == null) return;

    setState(() => isLoading = true);

    final response = await ApiService.uploadDocument(selectedFile!);

    setState(() {
      isLoading = false;
      extractedText =
          response["extracted_text"] ?? "No text found";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Documents")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: pickDocument,
              icon: const Icon(Icons.upload_file),
              label: const Text("Select Document"),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: uploadDocument,
              icon: const Icon(Icons.text_snippet),
              label: const Text("Upload & Extract Text"),
            ),
            const SizedBox(height: 20),
            if (isLoading) const CircularProgressIndicator(),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Text(extractedText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
