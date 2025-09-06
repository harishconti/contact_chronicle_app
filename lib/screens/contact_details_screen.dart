import 'package:contact_chronicle/models/contact.dart';
import 'package:contact_chronicle/models/note.dart';
import 'package:contact_chronicle/screens/contact_form_screen.dart';
import 'package:contact_chronicle/services/data_service.dart';
import 'package:contact_chronicle/widgets/note_timeline.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactDetailsScreen extends StatefulWidget {
  final String contactId;

  const ContactDetailsScreen({super.key, required this.contactId});

  @override
  State<ContactDetailsScreen> createState() => _ContactDetailsScreenState();
}

class _ContactDetailsScreenState extends State<ContactDetailsScreen> {
  late Future<Contact> _contactFuture;

  @override
  void initState() {
    super.initState();
    _loadContactDetails();
  }

  void _loadContactDetails() {
    final dataService = Provider.of<DataService>(context, listen: false);
    if (mounted) {
        _contactFuture = dataService.getContact(widget.contactId);
    }
  }

  void _refreshContactDetails() {
    if (mounted) {
        setState(() {
            _loadContactDetails();
        });
    }
  }

  void _addNoteToContact(String contactId, Note note) async {
    final dataService = Provider.of<DataService>(context, listen: false);
    await dataService.addNote(contactId, note);
    _refreshContactDetails();
  }

  // Added method to handle note deletion
  Future<void> _handleDeleteNote(String noteId) async {
    final dataService = Provider.of<DataService>(context, listen: false);
    try {
      await dataService.deleteNote(widget.contactId, noteId);
      _refreshContactDetails(); // Refresh the contact details to update the note list
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Note deleted successfully.', style: GoogleFonts.ptSans())),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete note: $e', style: GoogleFonts.ptSans())),
        );
      }
    }
  }

  Future<void> _launchURL(Uri url, BuildContext ctx) async {
    if (!await launchUrl(url)) {
      if (mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text('Could not launch $url', style: GoogleFonts.ptSans())),
        );
      }
    }
  }

  void _makePhoneCall(String phoneNumber, BuildContext ctx) {
    if (phoneNumber.trim().isEmpty) return;
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber.replaceAll(RegExp(r'\s+'), ''));
    _launchURL(phoneUri, ctx);
  }

  void _sendEmail(String email, BuildContext ctx) {
    if (email.trim().isEmpty) return;
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    _launchURL(emailUri, ctx);
  }

  Future<void> _confirmDeleteContact(BuildContext dialogContext, Contact contact) async {
    final dataService = Provider.of<DataService>(context, listen: false);

    final bool? confirmed = await showDialog<bool>(
      context: dialogContext,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text('Delete Contact?', style: GoogleFonts.ptSans()),
          content: Text('Are you sure you want to delete ${contact.name}?', style: GoogleFonts.ptSans()),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: GoogleFonts.ptSans()),
              onPressed: () => Navigator.of(ctx).pop(false),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Theme.of(ctx).colorScheme.error),
              child: Text('Delete', style: GoogleFonts.ptSans()),
              onPressed: () => Navigator.of(ctx).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await dataService.deleteContact(contact.id);
        if (!mounted) return;
        Navigator.of(context).pop(true); 
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete contact: $e', style: GoogleFonts.ptSans())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<Contact>(
      future: _contactFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Loading...')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(child: Text('Could not load contact. It might have been deleted.', style: GoogleFonts.ptSans())),
          );
        }
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('Not Found')),
            body: Center(child: Text('Contact not found.', style: GoogleFonts.ptSans())),
          );
        }

        final contact = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: Text(contact.name, style: GoogleFonts.ptSans(fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Edit Contact',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => ContactFormScreen(contactId: contact.id)),
                  ).then((result) {
                    if (result != true && mounted) { 
                       _refreshContactDetails();
                    }
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                tooltip: 'Delete Contact',
                onPressed: () => _confirmDeleteContact(context, contact),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    backgroundImage: contact.avatarUrl != null && contact.avatarUrl!.isNotEmpty
                        ? NetworkImage(contact.avatarUrl!)
                        : null,
                    child: contact.avatarUrl == null || contact.avatarUrl!.isEmpty
                        ? Icon(Icons.account_circle, size: 50, color: theme.colorScheme.onPrimaryContainer)
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    contact.name,
                    style: GoogleFonts.ptSans(fontSize: 26, fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color),
                  ),
                ),
                Center(
                  child: Text(
                    'Patient ID: ${contact.id}',
                    style: GoogleFonts.ptSans(fontSize: 16, color: theme.textTheme.bodyMedium?.color?.withAlpha((255 * 0.7).round())),
                  ),
                ),
                const SizedBox(height: 24),
                if (contact.email.isNotEmpty)
                  _buildDetailItem(context, LucideIcons.mail, 'Email', contact.email, 
                    onTap: () => _sendEmail(contact.email, context)),
                if (contact.phone.isNotEmpty)        
                  _buildDetailItem(context, LucideIcons.phone, 'Phone', contact.phone, 
                    onTap: () => _makePhoneCall(contact.phone, context)),
                
                if (contact.age != null)
                  _buildDetailItem(context, LucideIcons.cake, 'Age', contact.age.toString()),
                if (contact.location != null && contact.location!.isNotEmpty)
                  _buildDetailItem(context, LucideIcons.mapPin, 'Location', contact.location!),
                _buildDetailItem(context, LucideIcons.calendarDays, 'Start Date', DateFormat.yMMMd().format(contact.startDate)), 
                
                if (contact.initialComplaints != null && contact.initialComplaints!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildSectionTitle(context, 'Initial Complaints'),
                  Text(contact.initialComplaints!, style: GoogleFonts.ptSans(fontSize: 15, height: 1.5)),
                ],
                if (contact.initialAnalysis != null && contact.initialAnalysis!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildSectionTitle(context, 'Initial Analysis'),
                  Text(contact.initialAnalysis!, style: GoogleFonts.ptSans(fontSize: 15, height: 1.5)),
                ],
                const SizedBox(height: 24),
                Divider(color: theme.dividerColor.withAlpha((255 * 0.5).round())),
                const SizedBox(height: 16),
                NoteTimeline(
                  notes: contact.notes,
                  contactId: contact.id,
                  contact: contact, 
                  onAddNote: _addNoteToContact,
                  onDeleteNote: _handleDeleteNote, // Passed the callback here
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(BuildContext context, IconData icon, String label, String value, {VoidCallback? onTap}) {
    final theme = Theme.of(context);
    final bool isLink = onTap != null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.ptSans(fontSize: 12, color: theme.textTheme.bodySmall?.color?.withAlpha((255 * 0.7).round()))),
                const SizedBox(height: 2),
                InkWell(
                  onTap: onTap,
                  child: Padding( 
                    padding: EdgeInsets.symmetric(vertical: isLink ? 2.0 : 0.0),
                    child: Text(
                      value,
                      style: GoogleFonts.ptSans(
                        fontSize: 16,
                        color: isLink ? theme.colorScheme.secondary : theme.textTheme.bodyLarge?.color,
                        decoration: isLink ? TextDecoration.underline : null,
                        decorationColor: isLink ? theme.colorScheme.secondary : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

 Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: GoogleFonts.ptSans(
          fontSize: 18, 
          fontWeight: FontWeight.w600, 
          color: theme.colorScheme.primary
        ),
      ),
    );
  }
}
