import 'package:contact_chronicle/models/contact.dart';
import 'package:contact_chronicle/models/note.dart';
import 'package:contact_chronicle/services/data_service.dart';
import 'package:contact_chronicle/services/settings_service.dart'; // Added
import 'package:contact_chronicle/screens/contact_details_screen.dart';
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
  UserProfession _selectedProfession = SettingsService.defaultProfession;
  UserTier _selectedTier = SettingsService.defaultTier;
  bool _settingsLoaded = false;

  @override
  void initState() {
    super.initState();
    _settingsService = Provider.of<SettingsService>(context, listen: false);
    _loadContacts();
    _loadSettings();
  }

  Future<void> _loadContacts() async {
    final dataService = Provider.of<DataService>(context, listen: false);
    // Ensure widget is still mounted before calling setState
    if (mounted) {
       setState(() {
        _contactsFuture = dataService.getContacts();
      });
    }
  }

  Future<void> _loadSettings() async {
    _selectedProfession = await _settingsService.getUserProfession();
    _selectedTier = await _settingsService.getUserTier();
    if (mounted) {
        setState(() {
            _settingsLoaded = true;
        });
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
    final theme = Theme.of(context);
    if (!_settingsLoaded) {
        return Scaffold(
            appBar: AppBar(title: const Text('Dashboard')),
            body: const Center(child: CircularProgressIndicator())
        );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          _buildSettingsMenu(context),
        ],
      ),
      body: FutureBuilder<List<Contact>>(
        future: _contactsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading data: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No contact data available.', style: GoogleFonts.ptSans()));
          }

          final contacts = snapshot.data!;
          final totalContacts = contacts.length;
          final totalNotes = _getTotalNotes(contacts);

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Row(
                children: [
                  Expanded(child: _buildSummaryCard(context, LucideIcons.users, 'Total Contacts', totalContacts.toString())),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSummaryCard(context, LucideIcons.notebookText, 'Total Notes', totalNotes.toString())),
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
                  prefixIcon: Icon(LucideIcons.search, color: theme.colorScheme.primary.withOpacity(0.7)),
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
                }).toList(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, IconData icon, String title, String value) {
    final theme = Theme.of(context);
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

  Widget _buildSettingsMenu(BuildContext context) {
    final theme = Theme.of(context);
    return PopupMenuButton<String>(
      icon: Icon(LucideIcons.settings, color: theme.appBarTheme.iconTheme?.color ?? Colors.white),
      tooltip: 'Settings',
      onSelected: (String result) async {
        if (result.startsWith('profession_')) {
          UserProfession selected = UserProfession.values.firstWhere((e) => e.toString() == 'UserProfession.${result.substring('profession_'.length)}');
          await _settingsService.saveUserProfession(selected);
          if(mounted) setState(() => _selectedProfession = selected);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profession set to: ${_selectedProfession.displayName}', style: GoogleFonts.ptSans())));
        } else if (result.startsWith('tier_')) {
          UserTier selected = UserTier.values.firstWhere((e) => e.toString() == 'UserTier.${result.substring('tier_'.length)}');
          await _settingsService.saveUserTier(selected);
          if(mounted) setState(() => _selectedTier = selected);
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User tier set to: ${_selectedTier.displayName}', style: GoogleFonts.ptSans())));
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'header_profession',
          enabled: false,
          child: Text('Select Profession', style: GoogleFonts.ptSans(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
        ),
        ...UserProfession.values.map((profession) => PopupMenuItem<String>(
          value: 'profession_${profession.toString().split('.').last}',
          child: Text(profession.displayName, style: GoogleFonts.ptSans()),
          textStyle: _selectedProfession == profession ? TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary) : GoogleFonts.ptSans(color: theme.textTheme.bodyLarge?.color),
        )),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'header_tier',
          enabled: false,
          child: Text('Select User Tier', style: GoogleFonts.ptSans(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
        ),
        ...UserTier.values.map((tier) => PopupMenuItem<String>(
          value: 'tier_${tier.toString().split('.').last}',
          child: Text(tier.displayName, style: GoogleFonts.ptSans()),
          textStyle: _selectedTier == tier ? TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary) : GoogleFonts.ptSans(color: theme.textTheme.bodyLarge?.color),
        )),
      ],
    );
  }
}
