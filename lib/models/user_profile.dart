import 'package:contact_chronicle/services/settings_service.dart'; // For UserProfession and UserTier enums

class UserProfile {
  final String name;
  final String email;
  final UserProfession profession;
  final UserTier tier;
  final DateTime? lastBackup; // Made nullable as initial backup might not exist

  UserProfile({
    required this.name,
    required this.email,
    required this.profession,
    required this.tier,
    this.lastBackup,
  });

  // Method to create a UserProfile with default mock values
  factory UserProfile.defaultProfile() {
    return UserProfile(
      name: 'Dr. Mock User', // Default mock name
      email: 'mock.user@example.com', // Default mock email
      profession: SettingsService.defaultProfession,
      tier: SettingsService.defaultTier,
      lastBackup: null, // No backup initially
    );
  }

  // copyWith method to easily update parts of the profile
  UserProfile copyWith({
    String? name,
    String? email,
    UserProfession? profession,
    UserTier? tier,
    DateTime? lastBackup,
    bool setToNullLastBackup = false, // To explicitly set lastBackup to null
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      profession: profession ?? this.profession,
      tier: tier ?? this.tier,
      lastBackup: setToNullLastBackup ? null : (lastBackup ?? this.lastBackup),
    );
  }

  // Methods for JSON serialization/deserialization (for storage in SharedPreferences)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'profession': profession.toString(), // Store enum as string
      'tier': tier.toString(), // Store enum as string
      'lastBackup': lastBackup?.toIso8601String(), // Store DateTime as ISO8601 string
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String,
      email: json['email'] as String,
      profession: UserProfession.values.firstWhere(
        (e) => e.toString() == json['profession'],
        orElse: () => SettingsService.defaultProfession, // Fallback to default
      ),
      tier: UserTier.values.firstWhere(
        (e) => e.toString() == json['tier'],
        orElse: () => SettingsService.defaultTier, // Fallback to default
      ),
      lastBackup: json['lastBackup'] != null
          ? DateTime.parse(json['lastBackup'] as String)
          : null,
    );
  }
}
