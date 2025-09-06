import 'package:contact_chronicle/models/user_profile.dart';
import 'package:contact_chronicle/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // Added for DateFormat
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

  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  UserProfession? _selectedProfession;

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
        _selectedProfession = profile.profession; // This will update the initialValue on rebuild
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_currentUserProfile == null || _selectedProfession == null) return;

      final updatedProfile = _currentUserProfile!.copyWith(
        name: _nameController.text,
        email: _emailController.text,
        profession: _selectedProfession,
      );

      await _settingsService.saveUserProfile(updatedProfile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile saved successfully!', style: GoogleFonts.ptSans())),
        );
        _loadUserProfile(); // Reload to ensure UI is consistent
      }
    } else {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please correct the errors in the form.', style: GoogleFonts.ptSans())),
        );
      }
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
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Name',
              hintText: 'Enter your name',
              prefixIcon: Icon(LucideIcons.user, color: theme.colorScheme.primary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
            ),
            style: GoogleFonts.ptSans(),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Name cannot be empty';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
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
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email cannot be empty';
              }
              // Basic email validation regex
              if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
                return 'Enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildProfessionDropdown(theme),
          const SizedBox(height: 20),
          _buildReadOnlyField(theme, LucideIcons.gem, 'Subscription Tier', _currentUserProfile!.tier.displayName),
          const SizedBox(height: 12),
          _buildReadOnlyField(
            theme,
            LucideIcons.history,
            'Last Backup',
            _currentUserProfile!.lastBackup == null
                ? 'Never'
                : DateFormat.yMMMd().add_jm().format(_currentUserProfile!.lastBackup!),
          ),
          const SizedBox(height: 32),
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
      ),
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
      // Use initialValue for FormField behavior, state updates will trigger rebuilds and refresh this.
      initialValue: _selectedProfession, 
      style: GoogleFonts.ptSans(color: theme.textTheme.bodyLarge?.color),
      dropdownColor: theme.colorScheme.surface,
      icon: Icon(LucideIcons.chevronDown, color: theme.colorScheme.onSurfaceVariant),
      items: UserProfession.values.map((UserProfession profession) {
        return DropdownMenuItem<UserProfession>(
          value: profession, // This `value` is for DropdownMenuItem, not the FormField
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
      validator: (value) => value == null ? 'Please select a profession' : null,
    );
  }

  Widget _buildReadOnlyField(ThemeData theme, IconData icon, String label, String value) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.ptSans(color: theme.colorScheme.onSurfaceVariant),
        prefixIcon: Icon(icon, color: theme.colorScheme.primary, size: 20),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
      ),
      child: Text(
        value,
        style: GoogleFonts.ptSans(fontSize: 16, color: theme.textTheme.bodyLarge?.color?.withAlpha((255 * 0.9).round())), 
      ),
    );
  }
}
