import 'dart:convert'; // For jsonEncode and jsonDecode
import 'package:shared_preferences/shared_preferences.dart';
import 'package:contact_chronicle/models/user_profile.dart'; // Import UserProfile model

// Enums for user settings - these can remain here or be moved to user_profile.dart if preferred
// For now, keeping them here as they are also used by the extensions below.
enum UserProfession { 
  doctor, 
  nurse,
  pharmacist,
  acupuncture, 
  ayurveda,
  veterinary,
  generalPractice 
}
enum UserTier { free, pro, proPlus }

class SettingsService {
  static const String _userProfileKey = 'user_profile'; // New key for UserProfile
  static const String _loggedInKey = 'user_logged_in';

  // Default profession and tier constants are now primarily managed by UserProfile.defaultProfile()
  // and UserProfile.fromJson() fallbacks, but can be kept for reference or direct use if needed elsewhere.
  static const UserProfession defaultProfession = UserProfession.generalPractice;
  static const UserTier defaultTier = UserTier.free;

  Future<void> saveUserProfile(UserProfile userProfile) async {
    final prefs = await SharedPreferences.getInstance();
    final String userProfileJson = jsonEncode(userProfile.toJson());
    await prefs.setString(_userProfileKey, userProfileJson);
  }

  Future<UserProfile> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userProfileJson = prefs.getString(_userProfileKey);
    if (userProfileJson != null && userProfileJson.isNotEmpty) {
      try {
        final Map<String, dynamic> userProfileMap = jsonDecode(userProfileJson);
        return UserProfile.fromJson(userProfileMap);
      } catch (e) {
        // If parsing fails (e.g., corrupted data), return default profile
        // Optionally log the error: print("Error decoding UserProfile: $e");
        return UserProfile.defaultProfile();
      }
    }
    // If no profile is stored, return default profile
    return UserProfile.defaultProfile();
  }

  // Login state methods remain unchanged
  Future<void> saveLoginState(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, isLoggedIn);
  }

  Future<bool> getLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loggedInKey) ?? false;
  }
}

// Helper extensions remain for display purposes
extension UserProfessionExtension on UserProfession {
  String get displayName {
    switch (this) {
      case UserProfession.doctor:
        return 'Doctor';
      case UserProfession.nurse:
        return 'Nurse';
      case UserProfession.pharmacist:
        return 'Pharmacist';
      case UserProfession.acupuncture:
        return 'Acupuncture';
      case UserProfession.ayurveda:
        return 'Ayurveda';
      case UserProfession.veterinary:
        return 'Veterinary';
      case UserProfession.generalPractice:
        return 'General Practice';
      default:
        String name = toString().split('.').last;
        return name[0].toUpperCase() + name.substring(1);
    }
  }
}

extension UserTierExtension on UserTier {
  String get displayName {
    switch (this) {
      case UserTier.free:
        return 'Free';
      case UserTier.pro:
        return 'Pro';
      case UserTier.proPlus:
        return 'Pro+';
      default:
        String name = toString().split('.').last;
        return name[0].toUpperCase() + name.substring(1);
    }
  }
}
