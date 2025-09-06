import 'package:contact_chronicle/screens/contact_list_screen.dart';
import 'package:contact_chronicle/screens/login_screen.dart';
import 'package:contact_chronicle/services/settings_service.dart';
import 'package:contact_chronicle/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:contact_chronicle/services/data_service.dart';

void main() {
  runApp(const MyApp());
}

// MyApp now only sets up Providers and MaterialApp
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DataService>(create: (_) => DataService()),
        Provider<SettingsService>(create: (_) => SettingsService()),
      ],
      child: MaterialApp(
        title: 'Contact Chronicle',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const AuthWrapper(), // Use AuthWrapper as home
      ),
    );
  }
}

// New StatefulWidget to handle auth logic below Providers
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // This context is now a descendant of MultiProvider, so it can find SettingsService
    final settingsService = Provider.of<SettingsService>(context, listen: false);
    bool loggedIn = await settingsService.getLoginState();
    
    if (mounted) {
      setState(() {
        _isLoggedIn = loggedIn;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return _isLoggedIn ? const ContactListScreen() : const LoginScreen();
  }
}
