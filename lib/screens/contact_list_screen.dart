import 'package:contact_chronicle/models/contact.dart';
import 'package:contact_chronicle/screens/contact_form_screen.dart';
import 'package:contact_chronicle/screens/dashboard_screen.dart';
import 'package:contact_chronicle/services/data_service.dart';
import 'package:contact_chronicle/widgets/contact_list_item.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class ContactListScreen extends StatefulWidget {
  const ContactListScreen({super.key});

  @override
  State<ContactListScreen> createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  String _searchQuery = '';
  late Future<List<Contact>> _contactsFuture;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  void _loadContacts() {
    if (mounted) { // Ensure widget is mounted before interacting with Provider or calling setState
      final dataService = Provider.of<DataService>(context, listen: false);
      setState(() {
        _contactsFuture = dataService.getContacts();
      });
    }
  }

  void _navigateToContactForm() async { // Made async to await result
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ContactFormScreen()),
    );
    // If ContactFormScreen pops with true (meaning a contact was saved)
    if (result == true) {
      _refreshContacts();
    }
  }

  void _refreshContacts() {
    _loadContacts(); // Re-fetch contacts. setState is called within _loadContacts if mounted.
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.layoutDashboard),
            tooltip: 'Dashboard',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const DashboardScreen()),
              ).then((_) {
                // Potentially refresh if settings that affect contact list display were changed
                // For now, only explicit actions (add/edit/delete) refresh.
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search by name, phone, or ID...',
                prefixIcon: Icon(LucideIcons.search, color: theme.colorScheme.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: theme.colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: theme.colorScheme.primary, width: 2.0),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              ),
              style: GoogleFonts.ptSans(),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Contact>>(
              future: _contactsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: GoogleFonts.ptSans()));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      _searchQuery.isEmpty ? 'No contacts yet. Tap + to add.' : 'No contacts match your search.',
                      style: GoogleFonts.ptSans(fontSize: 16, color: theme.textTheme.bodyMedium?.color?.withAlpha((255*0.7).round())),
                      textAlign: TextAlign.center,
                    )
                  );
                }

                final allContacts = snapshot.data!;
                final filteredContacts = allContacts.where((contact) {
                  final nameMatch = contact.name.toLowerCase().contains(_searchQuery);
                  final phoneMatch = contact.phone.toLowerCase().contains(_searchQuery);
                  final idMatch = contact.id.toLowerCase().contains(_searchQuery);
                  return nameMatch || phoneMatch || idMatch;
                }).toList();

                if (filteredContacts.isEmpty) {
                   return Center(
                     child: Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         Icon(LucideIcons.users, size: 60, color: theme.colorScheme.secondary.withAlpha((255 * 0.5).round())),
                         const SizedBox(height: 16),
                         Text(
                           _searchQuery.isEmpty ? 'No contacts yet.' : 'No contacts match "$_searchQuery".',
                           style: GoogleFonts.ptSans(fontSize: 18, color: theme.textTheme.bodyMedium?.color?.withAlpha((255 * 0.8).round())),
                         ),
                         if (_searchQuery.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                             'Tap the + button to add your first contact.',
                             textAlign: TextAlign.center,
                             style: GoogleFonts.ptSans(fontSize: 15, color: theme.textTheme.bodyMedium?.color?.withAlpha((255 * 0.6).round())),
                            ),
                          ),
                       ],
                     ),
                   );
                }

                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: 80.0),
                  itemCount: filteredContacts.length,
                  itemBuilder: (context, index) {
                    final contact = filteredContacts[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      // Pass the _refreshContacts method to onReturn
                      child: ContactListItem(contact: contact, onReturn: _refreshContacts),
                    );
                  },
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: theme.dividerColor.withAlpha((255 * 0.5).round()),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToContactForm,
        tooltip: 'Add Contact',
        child: const Icon(LucideIcons.plus),
      ),
    );
  }
}
