class UserProfile {
  final String id;
  final String email;
  final String fullName;
  final String role; // PROJECT_MANAGER, STOREKEEPER, PROCUREMENT_OFFICER, SUPPLIER, ADMIN
  final String? phone;
  final String? jobTitle;
  final String organizationId;
  final String organizationName;

  UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.phone,
    this.jobTitle,
    required this.organizationId,
    required this.organizationName,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json, Map<String, dynamic> org) {
    return UserProfile(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? json['full_name'] ?? '',
      role: json['role'] ?? 'STOREKEEPER',
      phone: json['phone'],
      jobTitle: json['jobTitle'] ?? json['job_title'],
      organizationId: org['id'] ?? '',
      organizationName: org['name'] ?? 'Abyssinia Infrastructures PLC',
    );
  }

  bool get isProjectManager => role == 'PROJECT_MANAGER' || role == 'ADMIN';
  bool get isStorekeeper => role == 'STOREKEEPER' || role == 'ADMIN';
  bool get isProcurement => role == 'PROCUREMENT_OFFICER' || role == 'ADMIN';
}
