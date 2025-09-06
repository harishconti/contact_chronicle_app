import 'package:contact_chronicle/models/contact.dart';
import 'package:contact_chronicle/models/note.dart';
import 'package:contact_chronicle/models/user_profile.dart'; // Added
import 'package:contact_chronicle/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

class NoteTimeline extends StatefulWidget {
  final List<Note> notes;
  final String contactId;
  final Contact contact;
  final Function(String, Note) onAddNote;
  final Future<void> Function(String noteId)? onDeleteNote;

  const NoteTimeline({
    super.key,
    required this.notes,
    required this.contactId,
    required this.contact,
    required this.onAddNote,
    this.onDeleteNote,
  });

  @override
  State<NoteTimeline> createState() => _NoteTimelineState();
}

class _NoteTimelineState extends State<NoteTimeline> {
  final _noteTextController = TextEditingController();
  final FocusNode _noteFocusNode = FocusNode();
  late SettingsService _settingsService;

  @override
  void initState() {
    super.initState();
    _settingsService = Provider.of<SettingsService>(context, listen: false);
  }

  void _submitNote() {
    if (_noteTextController.text.trim().isEmpty) {
      return;
    }
    final newNote = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      content: _noteTextController.text.trim(),
    );
    widget.onAddNote(widget.contactId, newNote);
    _noteTextController.clear();
    _noteFocusNode.unfocus();
  }

  Future<String> _getNoteTemplate() async {
    // Fetch the full UserProfile to get the profession
    final UserProfile userProfile = await _settingsService.getUserProfile();
    final UserProfession profession = userProfile.profession;
    final contact = widget.contact;
    final String currentDate = DateFormat.yMMMd().format(DateTime.now());

    switch (profession) {
      case UserProfession.acupuncture:
        return '''
**Acupuncture Session**
- Patient: ${contact.name}
- Age: ${contact.age ?? 'N/A'}
- Date: $currentDate
- Initial Complaints: ${contact.initialComplaints ?? 'N/A'}
- Session Focus: 
- Points Used: 
- Patient Feedback: 
- Plan for Next Session: ''';
      case UserProfession.generalPractice:
        return '''
**General Consultation**
- Patient: ${contact.name}
- Date: $currentDate
- Reason for Visit: 
- Vitals: 
- Assessment: 
- Plan: ''';
      case UserProfession.nurse:
        return '''
**Nursing Note**
- Patient: ${contact.name}
- Date: $currentDate
- Observation: 
- Intervention: 
- Evaluation: ''';
      case UserProfession.doctor:
        return '''
**Doctor's Note**
- Patient: ${contact.name}
- Date: $currentDate
- Chief Complaint: 
- History of Present Illness: 
- Examination: 
- Assessment & Plan: ''';
      case UserProfession.pharmacist:
        return '''
**Pharmacist Intervention Note**
- Patient: ${contact.name}
- Date: $currentDate
- Medication Related Problem: 
- Intervention/Recommendation: 
- Outcome: 
- Follow-up: ''';
      case UserProfession.ayurveda:
        return '''
**Ayurvedic Consultation**
- Patient: ${contact.name}
- Date: $currentDate
- Prakriti: 
- Vikriti: 
- Agni Status: 
- Dhatu Status: 
- Srotas Involved: 
- Diagnosis: 
- Treatment Plan (Ahara, Vihara, Aushadhi): ''';
      case UserProfession.veterinary:
        return '''
**Veterinary Visit Note**
- Patient Name: ${contact.name} (Species: )
- Owner: 
- Date: $currentDate
- Reason for Visit: 
- Examination Findings: 
- Diagnostics: 
- Treatment Administered: 
- Medications Dispensed: 
- Client Communication: 
- Follow-up Plan: ''';
      default:
        return '''
**New Note**
- Patient: ${contact.name}
- Date: $currentDate
- Details: ''';
    }
  }

  Future<void> _applyTemplate() async {
    final template = await _getNoteTemplate();
    _noteTextController.text = template;
    _noteTextController.selection = TextSelection.fromPosition(
      TextPosition(offset: _noteTextController.text.length),
    );
    _noteFocusNode.requestFocus();
  }

  Future<void> _confirmDeleteNote(BuildContext dialogContext, Note note) async {
    if (widget.onDeleteNote == null) return;

    final bool? confirmed = await showDialog<bool>(
      context: dialogContext,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text('Delete Note?', style: GoogleFonts.ptSans()),
          content: Text('Are you sure you want to delete this note?', style: GoogleFonts.ptSans()),
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
        await widget.onDeleteNote!(note.id);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(dialogContext).showSnackBar(
            SnackBar(content: Text('Failed to delete note: $e', style: GoogleFonts.ptSans())),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
          child: Text(
            'Clinical Notes',
            style: GoogleFonts.ptSans(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        if (widget.notes.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Center(
              child: Column(
                children: [
                  Icon(LucideIcons.fileText, size: 40, color: theme.colorScheme.secondary.withAlpha((255 * 0.5).round())),
                  const SizedBox(height: 8),
                  Text(
                    'No notes yet for ${widget.contact.name}.',
                    style: GoogleFonts.ptSans(fontSize: 16, color: theme.textTheme.bodyMedium?.color?.withAlpha((255 * 0.7).round())),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.notes.length,
            itemBuilder: (context, index) {
              final note = widget.notes[index];
              return Card(
                elevation: 1,
                margin: const EdgeInsets.symmetric(vertical: 6.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                color: theme.colorScheme.surfaceContainerLowest,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat.yMMMd().add_jm().format(note.createdAt),
                            style: GoogleFonts.ptSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          if (widget.onDeleteNote != null)
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                iconSize: 18,
                                icon: Icon(LucideIcons.trash2, color: theme.colorScheme.error.withAlpha((255*0.7).round())),
                                tooltip: 'Delete Note',
                                onPressed: () => _confirmDeleteNote(context, note),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        note.content,
                        style: GoogleFonts.ptSans(fontSize: 15, height: 1.5, color: theme.textTheme.bodyMedium?.color),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        const SizedBox(height: 16),
        _buildAddNoteSection(context),
      ],
    );
  }

  Widget _buildAddNoteSection(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withAlpha(theme.brightness == Brightness.light ? 30 : 50),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: theme.colorScheme.outlineVariant.withAlpha(100))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add New Note',
            style: GoogleFonts.ptSans(fontSize: 16, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteTextController,
            focusNode: _noteFocusNode,
            decoration: InputDecoration(
              hintText: 'Enter note details...',
              hintStyle: GoogleFonts.ptSans(color: theme.hintColor.withAlpha(150)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            ),
            style: GoogleFonts.ptSans(fontSize: 15, color: theme.colorScheme.onSurface),
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                icon: Icon(LucideIcons.notebookPen, size: 18),
                label: Text('Use Template', style: GoogleFonts.ptSans(fontWeight: FontWeight.w600)),
                onPressed: _applyTemplate,
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.secondary,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                icon: const Icon(LucideIcons.send, size: 18),
                label: Text('Add Note', style: GoogleFonts.ptSans(fontWeight: FontWeight.w600)),
                onPressed: _submitNote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
