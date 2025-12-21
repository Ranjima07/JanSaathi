import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_providers.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Controllers
  final nameController = TextEditingController();
  final dobController = TextEditingController();
  final locationController = TextEditingController();
  final nationalityController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String? selectedOccupation;
  String? selectedQualification;
  String? selectedMaritalStatus;

  final List<String> occupations = [
    "Student",
    "Farmer",
    "Self-employed",
    "Salaried",
    "Government Employee",
    "Unemployed",
    "Retired",
  ];

  final List<String> qualifications = [
    "Illiterate",
    "Primary School",
    "High School",
    "Higher Secondary",
    "Diploma / Vocational",
    "Graduate",
    "Post Graduate",
    "Doctorate (PhD)",
  ];

  final List<String> maritalStatuses = [
    "Single",
    "Married",
    "Divorced",
    "Widowed",
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(
          "Create Your Profile",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("Personal Information"),
            _card(
              child: Column(
                children: [
                  _inputField("Full Name", nameController, Icons.person),
                  const SizedBox(height: 15),
                  _datePickerField(),
                  const SizedBox(height: 15),
                  _inputField("Location / Address", locationController, Icons.location_on),
                  const SizedBox(height: 15),
                  _inputField("Nationality", nationalityController, Icons.flag),
                ],
              ),
            ),

            const SizedBox(height: 25),
            _sectionTitle("Contact Information"),
            _card(
              child: Column(
                children: [
                  _inputField("Email", emailController, Icons.email,
                      keyboard: TextInputType.emailAddress),
                  const SizedBox(height: 15),
                  _inputField("Phone Number", phoneController, Icons.phone,
                      keyboard: TextInputType.phone),
                ],
              ),
            ),

            const SizedBox(height: 25),
            _sectionTitle("Profile Details"),
            _card(
              child: Column(
                children: [
                  _dropdownField(
                    label: "Occupation",
                    value: selectedOccupation,
                    items: occupations,
                    icon: Icons.work,
                    onChanged: (v) => setState(() => selectedOccupation = v),
                  ),
                  const SizedBox(height: 15),
                  _dropdownField(
                    label: "Qualification",
                    value: selectedQualification,
                    items: qualifications,
                    icon: Icons.school,
                    onChanged: (v) => setState(() => selectedQualification = v),
                  ),
                  const SizedBox(height: 15),
                  _dropdownField(
                    label: "Marital Status",
                    value: selectedMaritalStatus,
                    items: maritalStatuses,
                    icon: Icons.family_restroom,
                    onChanged: (v) => setState(() => selectedMaritalStatus = v),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),
            _sectionTitle("Security"),
            _card(
              child: Column(
                children: [
                  _passwordField("Password", passwordController),
                  const SizedBox(height: 15),
                  _passwordField("Confirm Password", confirmPasswordController),
                ],
              ),
            ),

            const SizedBox(height: 35),

            Center(
              child: authProvider.isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 100, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: _submitForm,
                      child: Text(
                        "Create Account",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- SUBMIT ----------------

  Future<void> _submitForm() async {
    if ([
      nameController.text,
      dobController.text,
      locationController.text,
      nationalityController.text,
      emailController.text,
      phoneController.text,
      passwordController.text,
      confirmPasswordController.text,
    ].any((e) => e.isEmpty) ||
        selectedOccupation == null ||
        selectedQualification == null ||
        selectedMaritalStatus == null) {
      _showMessage("Please fill all fields.");
      return;
    }

    if (passwordController.text.length < 6) {
      _showMessage("Password must be at least 6 characters.");
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      _showMessage("Passwords do not match.");
      return;
    }

    final authProvider =
        Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.signup(
      fullName: nameController.text.trim(),
      dob: dobController.text.trim(),
      location: locationController.text.trim(),
      nationality: nationalityController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      occupation: selectedOccupation!,
      qualification: selectedQualification!,
      maritalStatus: selectedMaritalStatus!,
      password: passwordController.text.trim(),
      confirmPassword: confirmPasswordController.text.trim(),
    );

    if (success) {
      _showMessage("Signup successful! Please login.");
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      _showMessage("Signup failed. Try again.");
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // ---------------- UI HELPERS ----------------

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.deepPurple,
          ),
        ),
      );

  Widget _card({required Widget child}) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 12),
          ],
        ),
        child: child,
      );

  Widget _inputField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboard = TextInputType.text,
  }) =>
      TextField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.deepPurple),
          labelText: label,
          filled: true,
          fillColor: const Color(0xfff7f7f7),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      );

  Widget _passwordField(String label, TextEditingController controller) =>
      TextField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.lock, color: Colors.deepPurple),
          labelText: label,
          filled: true,
          fillColor: const Color(0xfff7f7f7),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      );

  Widget _dropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required IconData icon,
    required Function(String?) onChanged,
  }) =>
      DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.deepPurple),
          labelText: label,
          filled: true,
          fillColor: const Color(0xfff7f7f7),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
        items:
            items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
      );

  Widget _datePickerField() => TextField(
        controller: dobController,
        readOnly: true,
        decoration: InputDecoration(
          prefixIcon:
              const Icon(Icons.calendar_month, color: Colors.deepPurple),
          labelText: "Date of Birth",
          filled: true,
          fillColor: const Color(0xfff7f7f7),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
        onTap: () async {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime(2000),
            firstDate: DateTime(1950),
            lastDate: DateTime.now(),
          );
          if (picked != null) {
            dobController.text =
                "${picked.day}-${picked.month}-${picked.year}";
          }
        },
      );
}
