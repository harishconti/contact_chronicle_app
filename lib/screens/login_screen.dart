import 'package:contact_chronicle/screens/contact_list_screen.dart';
import 'package:contact_chronicle/services/settings_service.dart'; // Added
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // Added

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  // Updated to be async and use SettingsService
  Future<void> _signInWithGoogle(BuildContext context) async {
    // In a real app, you would integrate Firebase Auth or similar here.
    
    // Save login state
    final settingsService = Provider.of<SettingsService>(context, listen: false);
    await settingsService.saveLoginState(true);

    // Ensure the widget is still mounted before navigating
    if (!context.mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const ContactListScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                LucideIcons.contact,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Contact Chronicle',
                style: GoogleFonts.ptSans(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.displayLarge?.color ?? theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your professional companion for managing patient contacts and clinical notes efficiently.',
                textAlign: TextAlign.center,
                style: GoogleFonts.ptSans(
                  fontSize: 16,
                  color: theme.textTheme.bodyMedium?.color?.withAlpha((255 * 0.7).round()) ?? theme.colorScheme.onSurface.withAlpha((255 * 0.7).round()),
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                icon: const Icon(LucideIcons.keyRound, size: 20),
                label: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                  child: Text(
                    'Sign in with Google',
                     style: GoogleFonts.ptSans(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  minimumSize: const Size(double.infinity, 50), 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () => _signInWithGoogle(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
