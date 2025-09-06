import 'package:contact_chronicle/models/user_profile.dart';
import 'package:contact_chronicle/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late SettingsService _settingsService;
  UserProfile? _currentUserProfile;
  bool _isLoading = true;

  // Form key for potential validation
  final _formKey = GlobalKey<FormState>();

  // Local variables to hold editable profile data
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  UserProfession? _selectedProfession;
  // UserTier and lastBackup are read-only for now as per plan

  @override
  void initState() {
    super.initState();
    _settingsService = Provider.of<SettingsService>(context, listen: false);
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });
    final profile = await _settingsService.getUserProfile();
    if (mounted) {
      setState(() {
        _currentUserProfile = profile;
        _nameController.text = profile.name;
        _emailController.text = profile.email;
        _selectedProfession = profile.profession;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_currentUserProfile == null || _selectedProfession == null) return;

    // Create updated profile from local state
    final updatedProfile = _currentUserProfile!.copyWith(
      name: _nameController.text,
      email: _emailController.text,
      profession: _selectedProfession,
      // tier and lastBackup are not changed here as per current plan
    );

    await _settingsService.saveUserProfile(updatedProfile);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile saved successfully!', style: GoogleFonts.ptSans())),
      );
      // Reload profile to ensure UI reflects the saved state (e.g. if default values were used initially)
      _loadUserProfile(); 
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile', style: GoogleFonts.ptSans(fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentUserProfile == null 
              ? Center(child: Text('Could not load profile.', style: GoogleFonts.ptSans()))
              : _buildProfileForm(theme),
    );
  }

  Widget _buildProfileForm(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: <Widget>[
        // Name Field (Mocked/Editable)
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Name',
            hintText: 'Enter your name',
            prefixIcon: Icon(LucideIcons.user, color: theme.colorScheme.primary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          ),
          style: GoogleFonts.ptSans(),
        ),
        const SizedBox(height: 16),

        // Email Field (Mocked/Editable)
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'Enter your email',
            prefixIcon: Icon(LucideIcons.mail, color: theme.colorScheme.primary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          ),
          keyboardType: TextInputType.emailAddress,
          style: GoogleFonts.ptSans(),
        ),
        const SizedBox(height: 20),

        // Profession Dropdown
        _buildProfessionDropdown(theme),
        const SizedBox(height: 20),

        // Subscription Tier (Read-only)
        _buildReadOnlyField(theme, LucideIcons.gem, 'Subscription Tier', _currentUserProfile!.tier.displayName),
        const SizedBox(height: 12),

        // Last Backup (Read-only)
        _buildReadOnlyField(theme, LucideIcons.history, 'Last Backup', 
          _currentUserProfile!.lastBackup == null 
              ? 'Never' 
              : DateFormat.yMMMd().add_jm().format(_currentUserProfile!.lastBackup!)
        ),
        const SizedBox(height: 32),

        // Save Button
        ElevatedButton.icon(
          icon: const Icon(LucideIcons.save, size: 20),
          label: Text('Save Profile', style: GoogleFonts.ptSans(fontSize: 16, fontWeight: FontWeight.w600)),
          onPressed: _saveProfile,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          ),
        ),
      ],
    );
  }

  Widget _buildProfessionDropdown(ThemeData theme) {
    return DropdownButtonFormField<UserProfession>(
      decoration: InputDecoration(
        labelText: 'Profession',
        prefixIcon: Icon(LucideIcons.briefcase, color: theme.colorScheme.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      ),
      value: _selectedProfession,
      style: GoogleFonts.ptSans(color: theme.textTheme.bodyLarge?.color),
      dropdownColor: theme.colorScheme.surface,
      icon: Icon(LucideIcons.chevronDown, color: theme.colorScheme.onSurfaceVariant),
      items: UserProfession.values.map((UserProfession profession) {
        return DropdownMenuItem<UserProfession>(
          value: profession,
          child: Text(profession.displayName, style: GoogleFonts.ptSans()),
        );
      }).toList(),
      onChanged: (UserProfession? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedProfession = newValue;
          });
        }
      },
    );
  }

  Widget _buildReadOnlyField(ThemeData theme, IconData icon, String label, String value) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.ptSans(color: theme.colorScheme.onSurfaceVariant),
        prefixIcon: Icon(icon, color: theme.colorScheme.primary, size: 20),
        border: InputBorder.none, // Or a subtle underline if preferred
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0), 
      ),
      child: Text(
        value,
        style: GoogleFonts.ptSans(fontSize: 16, color: theme.textTheme.bodyLarge?.color?.withOpacity(0.9)),
      ),
    );
  }
}

// Required for DateFormat
// Make sure to have intl package in pubspec.yaml
// import 'package:intl/intl.dart'; // Already at the top by convention, if not, add it.
