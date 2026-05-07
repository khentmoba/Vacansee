/// User role enum for role-based access control
enum UserRole { student, owner, admin }

/// User model representing both students and property owners
class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final UserRole? role;
  final String? phoneNumber;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isVerified;
  final String? gender;
  final String? firstName;
  final String? lastName;
  final String? address;
  final String? businessName;
  final String? businessPermitNo;
  final String? emergencyContactName;
  final String? emergencyContactPhone;

  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.role,
    this.phoneNumber,
    required this.createdAt,
    this.lastLoginAt,
    this.isVerified = false,
    this.gender,
    this.firstName,
    this.lastName,
    this.address,
    this.businessName,
    this.businessPermitNo,
    this.emergencyContactName,
    this.emergencyContactPhone,
  });

  /// Create UserModel from JSON (Supabase)
  factory UserModel.fromJson(Map<String, dynamic> data) {
    return UserModel(
      uid:
          data['id'] as String? ??
          data['uid'] as String? ??
          '', // fallback for legacy
      email: data['email'] as String? ?? '',
      displayName: data['display_name'] as String? ?? '',
      role: data['role'] == null
          ? null
          : UserRole.values.firstWhere(
              (r) => r.name == (data['role'] as String),
              orElse: () => UserRole.student,
            ),
      phoneNumber: data['phone_number'] as String?,
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'] as String)
          : DateTime.now(),
      lastLoginAt: data['last_login_at'] != null
          ? DateTime.parse(data['last_login_at'] as String)
          : null,
      isVerified: data['is_verified'] as bool? ?? false,
      gender: data['gender'] as String?,
      firstName: data['first_name'] as String?,
      lastName: data['last_name'] as String?,
      address: data['address'] as String?,
      businessName: data['business_name'] as String?,
      businessPermitNo: data['business_permit_no'] as String?,
      emergencyContactName: data['emergency_contact_name'] as String?,
      emergencyContactPhone: data['emergency_contact_phone'] as String?,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': uid,
      'email': email,
      'display_name': displayName,
      'role': role?.name,
      'phone_number': phoneNumber,
      'created_at': createdAt.toIso8601String(),
      'is_verified': isVerified,
      'gender': gender,
      'first_name': firstName,
      'last_name': lastName,
      'address': address,
      'business_name': businessName,
      'business_permit_no': businessPermitNo,
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_phone': emergencyContactPhone,
      if (lastLoginAt != null) 'last_login_at': lastLoginAt!.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    UserRole? role,
    bool clearRole = false,
    String? phoneNumber,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isVerified,
    String? gender,
    String? firstName,
    String? lastName,
    String? address,
    String? businessName,
    String? businessPermitNo,
    String? emergencyContactName,
    String? emergencyContactPhone,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: clearRole ? null : (role ?? this.role),
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isVerified: isVerified ?? this.isVerified,
      gender: gender ?? this.gender,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      address: address ?? this.address,
      businessName: businessName ?? this.businessName,
      businessPermitNo: businessPermitNo ?? this.businessPermitNo,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() => 'UserModel(uid: $uid, email: $email, role: $role)';
}
