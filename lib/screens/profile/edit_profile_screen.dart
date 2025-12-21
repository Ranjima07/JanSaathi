import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_providers.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController dobController;
  late TextEditingController locationController;
  late TextEditingController nationalityController;
  late TextEditingController phoneController;

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
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user!;

    nameController = TextEditingController(text: user.fullName);
    dobController = TextEditingController(text: user.dob);
    locationController = TextEditingController(text: user.location);
    nationalityController = TextEditingController(text: user.nationality);
    phoneController = TextEditingController(text: user.phone);

    selectedOccupation = user.occupation;
    selectedQualification = user.qualification;
    selectedMaritalStatus = user.maritalStatus;
  }

  @override
  void dispose() {
    nameController.dispose();
    dobController.dispose();
    locationController.dispose();
    nationalityController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xfff4f5f7),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Edit Profile",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 24, 18, 40),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle("Personal Information"),
              _card(
                child: Column(
                  children: [
                    _inputField("Full Name", nameController, Icons.person),
                    _gap(),
                    _datePickerField(),
                    _gap(),
                    _inputField(
                        "Location / Address", locationController, Icons.location_on),
                    _gap(),
                    _inputField(
                        "Nationality", nationalityController, Icons.flag),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              _sectionTitle("Contact Information"),
              _card(
                child: _inputField(
                  "Phone Number",
                  phoneController,
                  Icons.phone,
                  keyboard: TextInputType.phone,
                ),
              ),

              const SizedBox(height: 28),

              _sectionTitle("Profile Details"),
              _card(
                child: Column(
                  children: [
                    _dropdownField(
                      label: "Occupation",
                      value: selectedOccupation,
                      items: occupations,
                      icon: Icons.work_outline,
                      onChanged: (v) =>
                          setState(() => selectedOccupation = v),
                    ),
                    _gap(),
                    _dropdownField(
                      label: "Qualification",
                      value: selectedQualification,
                      items: qualifications,
                      icon: Icons.school_outlined,
                      onChanged: (v) =>
                          setState(() => selectedQualification = v),
                    ),
                    _gap(),
                    _dropdownField(
                      label: "Marital Status",
                      value: selectedMaritalStatus,
                      items: maritalStatuses,
                      icon: Icons.family_restroom_outlined,
                      onChanged: (v) =>
                          setState(() => selectedMaritalStatus = v),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 3,
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      authProvider.updateUser(
                        fullName: nameController.text.trim(),
                        dob: dobController.text.trim(),
                        location: locationController.text.trim(),
                        occupation: selectedOccupation!,
                        qualification: selectedQualification!,
                        nationality: nationalityController.text.trim(),
                        phone: phoneController.text.trim(),
                        maritalStatus: selectedMaritalStatus!,
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    "Save Changes",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- UI HELPERS ----------------

  Widget _gap() => const SizedBox(height: 16);

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
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
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
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
      TextFormField(
        controller: controller,
        keyboardType: keyboard,
        validator: (v) => v == null || v.isEmpty ? "Required" : null,
        decoration: _inputDecoration(label, icon),
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
        validator: (v) => v == null ? "Required" : null,
        decoration: _inputDecoration(label, icon),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      );

  Widget _datePickerField() => TextFormField(
        controller: dobController,
        readOnly: true,
        validator: (v) => v == null || v.isEmpty ? "Required" : null,
        decoration:
            _inputDecoration("Date of Birth", Icons.calendar_month),
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

  InputDecoration _inputDecoration(String label, IconData icon) =>
      InputDecoration(
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        labelText: label,
        filled: true,
        fillColor: const Color(0xfff7f7f7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      );
}
