import 'package:contact_chronicle/models/contact.dart';
import 'package:contact_chronicle/models/note.dart';
import 'package:contact_chronicle/models/user_profile.dart';
import 'package:contact_chronicle/services/data_service.dart';
import 'package:contact_chronicle/services/settings_service.dart';
import 'package:contact_chronicle/screens/contact_details_screen.dart';
import 'package:contact_chronicle/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<Contact>> _contactsFuture;
  String _globalSearchQuery = '';
  List<Map<String, dynamic>> _searchResults = [];

  late SettingsService _settingsService;
  bool _initialDataLoaded = false;

  @override
  void initState() {
    super.initState();
    _settingsService = Provider.of<SettingsService>(context, listen: false);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final dataService = Provider.of<DataService>(context, listen: false);
    if (mounted) {
      _contactsFuture = dataService.getContacts();
      try {
        await _contactsFuture;
        if (mounted) setState(() => _initialDataLoaded = true);
      } catch (_) {
        if (mounted) setState(() => _initialDataLoaded = true);
      }
    }
  }

  void _performGlobalSearch(String query, List<Contact> contacts) {
    if (query.isEmpty) {
      if (mounted) setState(() => _searchResults = []);
      return;
    }
    final List<Map<String, dynamic>> results = [];
    for (var contact in contacts) {
      for (var note in contact.notes) {
        if (note.content.toLowerCase().contains(query.toLowerCase())) {
          results.add({'contact': contact, 'note': note});
        }
      }
    }
    if (mounted) setState(() => _searchResults = results);
  }

  int _getTotalNotes(List<Contact> contacts) {
    int total = 0;
    for (var contact in contacts) {
      total += contact.notes.length;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // This context is fine for the build method scope
    if (!_initialDataLoaded) {
      return Scaffold(
          appBar: AppBar(title: Text('Dashboard', style: GoogleFonts.ptSans())),
          body: const Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard', style: GoogleFonts.ptSans(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.user, color: theme.appBarTheme.iconTheme?.color),
            tooltip: 'User Profile',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          _buildOldSettingsMenu(), // context parameter removed
        ],
      ),
      body: FutureBuilder<List<Contact>>(
        future: _contactsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !_initialDataLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading data: ${snapshot.error}', style: GoogleFonts.ptSans()));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No contact data available.', style: GoogleFonts.ptSans(fontSize: 16)));
          }

          final contacts = snapshot.data!;
          final totalContacts = contacts.length;
          final totalNotes = _getTotalNotes(contacts);

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Row(
                children: [
                  Expanded(child: _buildSummaryCard(LucideIcons.users, 'Total Contacts', totalContacts.toString())),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSummaryCard(LucideIcons.notebookText, 'Total Notes', totalNotes.toString())),
                ],
              ),
              const SizedBox(height: 24),
              Text('Global Note Search', style: GoogleFonts.ptSans(fontSize: 18, fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
              const SizedBox(height: 8),
              TextField(
                onChanged: (value) {
                  _globalSearchQuery = value;
                  _performGlobalSearch(_globalSearchQuery, contacts);
                },
                decoration: InputDecoration(
                  hintText: 'Search across all notes...',
                  prefixIcon: Icon(LucideIcons.search, color: theme.colorScheme.primary.withAlpha((255 * 0.7).round())),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                ),
                style: GoogleFonts.ptSans(),
              ),
              const SizedBox(height: 16),
              if (_globalSearchQuery.isNotEmpty && _searchResults.isEmpty)
                Center(child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('No notes found matching "$_globalSearchQuery".', style: GoogleFonts.ptSans(fontSize: 16)),
                )),
              if (_searchResults.isNotEmpty)
                ..._searchResults.map((result) {
                  Contact contact = result['contact'];
                  Note note = result['note'];
                  return Card(
                    elevation: 1,
                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                    child: ListTile(
                      leading: Icon(LucideIcons.fileText, color: theme.colorScheme.secondary),
                      title: Text(note.content, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.ptSans(fontSize: 15)),
                      subtitle: Text('From: ${contact.name}', style: GoogleFonts.ptSans(fontSize: 13, color: theme.textTheme.bodySmall?.color)),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => ContactDetailsScreen(contactId: contact.id)),
                        );
                      },
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }

  // context parameter removed
  Widget _buildSummaryCard(IconData icon, String title, String value) {
    final theme = Theme.of(context); // Uses State's context
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 30, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text(title, style: GoogleFonts.ptSans(fontSize: 15, color: theme.textTheme.bodyMedium?.color?.withAlpha((255 * 0.8).round()))),
            const SizedBox(height: 4),
            Text(value, style: GoogleFonts.ptSans(fontSize: 28, fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color)),
          ],
        ),
      ),
    );
  }

  // context parameter removed
  Widget _buildOldSettingsMenu() {
    final theme = Theme.of(context); // Uses State's context for the icon and tooltip
    return PopupMenuButton<String>(
      icon: Icon(LucideIcons.settings, color: theme.appBarTheme.iconTheme?.color),
      tooltip: 'Old Settings (Dev)',
      onSelected: (String result) async {
        if (result.startsWith('profession_')) {
          UserProfession selectedProf = UserProfession.values.firstWhere((e) => e.toString() == 'UserProfession.${result.substring('profession_'.length)}');
          UserProfile currentProfile = await _settingsService.getUserProfile();
          await _settingsService.saveUserProfile(currentProfile.copyWith(profession: selectedProf));
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profession (old menu) set to: ${selectedProf.displayName}', style: GoogleFonts.ptSans())));
        } else if (result.startsWith('tier_')) {
          UserTier selectedTierEnum = UserTier.values.firstWhere((e) => e.toString() == 'UserTier.${result.substring('tier_'.length)}');
          UserProfile currentProfile = await _settingsService.getUserProfile();
          await _settingsService.saveUserProfile(currentProfile.copyWith(tier: selectedTierEnum));
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User tier (old menu) set to: ${selectedTierEnum.displayName}', style: GoogleFonts.ptSans())));
        }
      },
      // itemBuilder provides its own context (dialogContext) for menu items
      itemBuilder: (BuildContext dialogContext) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'header_info',
          enabled: false,
          child: Text('Quick Toggles (Dev Only)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'header_profession',
          enabled: false,
          child: Text('Select Profession', style: GoogleFonts.ptSans(fontWeight: FontWeight.bold, color: Theme.of(dialogContext).colorScheme.primary)),
        ),
        ...UserProfession.values.map((profession) => PopupMenuItem<String>(
          value: 'profession_${profession.toString().split('.').last}',
          child: Text(profession.displayName, style: GoogleFonts.ptSans()),
        )),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'header_tier',
          enabled: false,
          child: Text('Select User Tier', style: GoogleFonts.ptSans(fontWeight: FontWeight.bold, color: Theme.of(dialogContext).colorScheme.primary)),
        ),
        ...UserTier.values.map((tier) => PopupMenuItem<String>(
          value: 'tier_${tier.toString().split('.').last}',
          child: Text(tier.displayName, style: GoogleFonts.ptSans()),
        )),
      ],
    );
  }
}
