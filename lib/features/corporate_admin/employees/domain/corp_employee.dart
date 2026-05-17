class CorpEmployee {
  const CorpEmployee({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.department,
    this.designation,
    this.status,
    this.createdAt,
  });

  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String? department;
  final String? designation;
  final String? status;
  final String? createdAt;

  factory CorpEmployee.fromJson(Map<String, dynamic> json) {
    return CorpEmployee(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      department: json['department'] as String?,
      designation: json['designation'] as String?,
      status: json['status'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }
}
