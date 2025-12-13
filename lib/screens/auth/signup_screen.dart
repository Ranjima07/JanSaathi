import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupScreen extends StatefulWidget {
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

  String? selectedOccupation;
  String? selectedQualification;
  String? selectedMaritalStatus;

  // Dropdown Lists
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
    return Scaffold(
      backgroundColor: Color(0xfff5f5f5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        title: Text(
          "Create Your Profile",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            SizedBox(height: 10),
            Text(
              "Personal Information",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.deepPurple,
              ),
            ),
            SizedBox(height: 15),

            _card(
              child: Column(
                children: [
                  _inputField("Full Name", nameController, Icons.person),

                  SizedBox(height: 15),
                  _datePickerField(),

                  SizedBox(height: 15),
                  _inputField("Location / Address", locationController, Icons.location_on),

                  SizedBox(height: 15),
                  _inputField("Nationality", nationalityController, Icons.flag),
                ],
              ),
            ),

            SizedBox(height: 25),
            Text(
              "Contact Information",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.deepPurple,
              ),
            ),
            SizedBox(height: 15),

            _card(
              child: Column(
                children: [
                  _inputField("Email", emailController, Icons.email,
                      keyboard: TextInputType.emailAddress),

                  SizedBox(height: 15),

                  _inputField("Phone Number", phoneController, Icons.phone,
                      keyboard: TextInputType.phone),
                ],
              ),
            ),

            SizedBox(height: 25),
            Text(
              "Profile Details",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.deepPurple,
              ),
            ),
            SizedBox(height: 15),

            _card(
              child: Column(
                children: [
                  // Occupation
                  _dropdownField(
                    label: "Occupation",
                    value: selectedOccupation,
                    items: occupations,
                    icon: Icons.work,
                    onChanged: (val) => setState(() => selectedOccupation = val),
                  ),

                  SizedBox(height: 15),

                  // Qualification Dropdown
                  _dropdownField(
                    label: "Qualification",
                    value: selectedQualification,
                    items: qualifications,
                    icon: Icons.school,
                    onChanged: (val) => setState(() => selectedQualification = val),
                  ),

                  SizedBox(height: 15),

                  // Marital Status
                  _dropdownField(
                    label: "Marital Status",
                    value: selectedMaritalStatus,
                    items: maritalStatuses,
                    icon: Icons.family_restroom,
                    onChanged: (val) => setState(() => selectedMaritalStatus = val),
                  ),
                ],
              ),
            ),

            SizedBox(height: 35),

            // Submit Button
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: EdgeInsets.symmetric(horizontal: 100, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: _submitForm,
                child: Text(
                  "Create Account",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Card container design
  Widget _card({required Widget child}) {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: child,
    );
  }

  // Generic input field
  Widget _inputField(String label, TextEditingController controller, IconData icon,
      {TextInputType keyboard = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      style: GoogleFonts.poppins(),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        labelText: label,
        labelStyle: GoogleFonts.poppins(),
        filled: true,
        fillColor: Color(0xfff7f7f7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // Dropdown field design
  Widget _dropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        labelText: label,
        labelStyle: GoogleFonts.poppins(),
        filled: true,
        fillColor: Color(0xfff7f7f7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      items: items.map((e) => DropdownMenuItem(child: Text(e), value: e)).toList(),
      onChanged: onChanged,
    );
  }

  // Date Picker Field
  Widget _datePickerField() {
    return TextField(
      controller: dobController,
      readOnly: true,
      style: GoogleFonts.poppins(),
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.calendar_month, color: Colors.deepPurple),
        labelText: "Date of Birth",
        filled: true,
        fillColor: Color(0xfff7f7f7),
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
          dobController.text = "${picked.day}-${picked.month}-${picked.year}";
        }
      },
    );
  }

  // Validate Inputs
  void _submitForm() {
    if (
      nameController.text.isEmpty ||
      dobController.text.isEmpty ||
      locationController.text.isEmpty ||
      nationalityController.text.isEmpty ||
      emailController.text.isEmpty ||
      phoneController.text.isEmpty ||
      selectedOccupation == null ||
      selectedQualification == null ||
      selectedMaritalStatus == null
    ) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields.")),
      );
      return;
    }

    print("Signup Success!");
  }
}
