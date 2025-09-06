import 'package:contact_chronicle/models/contact.dart';
import 'package:contact_chronicle/screens/contact_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class ContactListItem extends StatelessWidget {
  final Contact contact;
  final VoidCallback? onReturn; // Added callback

  const ContactListItem({super.key, required this.contact, this.onReturn}); // Updated constructor

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: theme.colorScheme.primaryContainer,
        backgroundImage: contact.avatarUrl != null && contact.avatarUrl!.isNotEmpty
            ? NetworkImage(contact.avatarUrl!)
            : null,
        child: contact.avatarUrl == null || contact.avatarUrl!.isEmpty
            ? Icon(
                LucideIcons.user,
                size: 28,
                color: theme.colorScheme.onPrimaryContainer,
              )
            : null,
      ),
      title: Text(
        contact.name,
        style: GoogleFonts.ptSans(
          fontWeight: FontWeight.w600,
          fontSize: 17,
          color: theme.textTheme.bodyLarge?.color,
        ),
      ),
      subtitle: Text(
        'ID: ${contact.id}',
        style: GoogleFonts.ptSans(
          fontSize: 14,
          color: theme.textTheme.bodyMedium?.color?.withAlpha((255 * 0.7).round()), // Using withAlpha for clarity
        ),
      ),
      trailing: Icon(LucideIcons.chevronRight, color: theme.colorScheme.outline),
      onTap: () async { // Made onTap async
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ContactDetailsScreen(contactId: contact.id),
          ),
        );
        // If result is true (contact was deleted or an action requires refresh)
        // and onReturn callback is provided, call it.
        if (result == true && onReturn != null) {
          onReturn!();
        }
      },
    );
  }
}
