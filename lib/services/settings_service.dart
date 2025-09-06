import 'package:shared_preferences/shared_preferences.dart';

// Enums for user settings
enum UserProfession { acupuncture, generalPractice, nurse }
enum UserTier { free, pro, proPlus }

class SettingsService {
  static const String _professionKey = 'user_profession';
  static const String _tierKey = 'user_tier'; 
  static const String _loggedInKey = 'user_logged_in'; // Added

  // Default profession if none is set
  static const UserProfession defaultProfession = UserProfession.acupuncture;
  static const UserTier defaultTier = UserTier.free; 

  Future<void> saveUserProfession(UserProfession profession) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_professionKey, profession.toString());
  }

  Future<UserProfession> getUserProfession() async {
    final prefs = await SharedPreferences.getInstance();
    final professionString = prefs.getString(_professionKey);
    if (professionString != null) {
      try {
        return UserProfession.values.firstWhere((e) => e.toString() == professionString);
      } catch (e) {
        return defaultProfession;
      }
    }
    return defaultProfession;
  }

  Future<void> saveUserTier(UserTier tier) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tierKey, tier.toString());
  }

  Future<UserTier> getUserTier() async {
    final prefs = await SharedPreferences.getInstance();
    final tierString = prefs.getString(_tierKey);
    if (tierString != null) {
      try {
        return UserTier.values.firstWhere((e) => e.toString() == tierString);
      } catch (e) {
        return defaultTier;
      }
    }
    return defaultTier;
  }

  // Added methods for login state
  Future<void> saveLoginState(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, isLoggedIn);
  }

  Future<bool> getLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loggedInKey) ?? false; // Default to false if not set
  }
}

// Helper extension for user-friendly names
extension UserProfessionExtension on UserProfession {
  String get displayName {
    switch (this) {
      case UserProfession.acupuncture:
        return 'Acupuncture';
      case UserProfession.generalPractice:
        return 'General Practice';
      case UserProfession.nurse:
        return 'Nurse';
      default:
        return toString().split('.').last;
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
        return toString().split('.').last;
    }
  }
}
