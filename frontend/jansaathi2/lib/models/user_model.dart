class UserModel {
  final String fullName;
  final String email;
  final String dob;
  final String location;
  final String occupation;
  final String qualification;
  final String nationality;
  final String phone;
  final String maritalStatus;
  final String? profileImage; // 👈 Profile photo path / URL

  UserModel({
    required this.fullName,
    required this.email,
    required this.dob,
    required this.location,
    required this.occupation,
    required this.qualification,
    required this.nationality,
    required this.phone,
    required this.maritalStatus,
    this.profileImage,
  });

  // ================= FROM JSON =================
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      fullName: json['full_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      dob: json['dob']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      occupation: json['occupation']?.toString() ?? '',
      qualification: json['qualification']?.toString() ?? '',
      nationality: json['nationality']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      maritalStatus:
          json['marital_status']?.toString() ??
          json['maritalStatus']?.toString() ??
          '',
      profileImage: json['profile_image']?.toString(),
    );
  }

  // ================= TO JSON =================
  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'email': email,
      'dob': dob,
      'location': location,
      'occupation': occupation,
      'qualification': qualification,
      'nationality': nationality,
      'phone': phone,
      'marital_status': maritalStatus,
      'profile_image': profileImage,
    };
  }

  // ================= COPY WITH =================
  UserModel copyWith({
    String? fullName,
    String? dob,
    String? location,
    String? occupation,
    String? qualification,
    String? nationality,
    String? phone,
    String? maritalStatus,
    String? profileImage,
  }) {
    return UserModel(
      fullName: fullName ?? this.fullName,
      email: email, // email remains immutable
      dob: dob ?? this.dob,
      location: location ?? this.location,
      occupation: occupation ?? this.occupation,
      qualification: qualification ?? this.qualification,
      nationality: nationality ?? this.nationality,
      phone: phone ?? this.phone,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      profileImage: profileImage ?? this.profileImage,
    );
  }
}
