import 'dart:io';
import 'package:contact_chronicle/models/contact.dart';
import 'package:contact_chronicle/models/note.dart'; // Added this line
import 'package:contact_chronicle/services/data_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class ContactFormScreen extends StatefulWidget {
  final String? contactId; // Null for new contact, non-null for editing

  const ContactFormScreen({super.key, this.contactId});

  @override
  State<ContactFormScreen> createState() => _ContactFormScreenState();
}

class _ContactFormScreenState extends State<ContactFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isEditing = false;
  String _patientId = '';
  XFile? _avatarFile;
  String? _existingAvatarUrl;

  // Form field controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _locationController = TextEditingController();
  final _initialComplaintsController = TextEditingController();
  final _initialAnalysisController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isEditing = widget.contactId != null;
    // It's generally safer to get providers a bit later if context is needed immediately,
    // but for listen:false, it's often okay in initState.
    // However, to be absolutely safe with async operations that might follow immediately:
    WidgetsBinding.instance.addPostFrameCallback((_) {
        final dataService = Provider.of<DataService>(context, listen: false);
        if (_isEditing) {
          _loadExistingContact(dataService);
        } else {
          if (mounted) {
            setState(() {
              _patientId = dataService.getNextPatientId();
            });
          }
        }
    });
  }

  Future<void> _loadExistingContact(DataService dataService) async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final contact = await dataService.getContact(widget.contactId!);
      if (!mounted) return; // Check after await
      _patientId = contact.id;
      _nameController.text = contact.name;
      _emailController.text = contact.email;
      _phoneController.text = contact.phone;
      _ageController.text = contact.age?.toString() ?? '';
      _locationController.text = contact.location ?? '';
      _initialComplaintsController.text = contact.initialComplaints ?? '';
      _initialAnalysisController.text = contact.initialAnalysis ?? '';
      _existingAvatarUrl = contact.avatarUrl;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load contact: $e', style: GoogleFonts.ptSans())),
      );
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (!mounted) return; // Check after await
      if (image != null) {
        setState(() {
          _avatarFile = image;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e', style: GoogleFonts.ptSans())),
      );
    }
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (mounted) setState(() => _isLoading = true);

      final dataService = Provider.of<DataService>(context, listen: false);
      Contact contactData; // Define outside try block

      try {
        // Fetch existing data for startDate and notes if editing, BEFORE any other async operation that might touch context
        DateTime startDate = DateTime.now();
        List<Note> notes = [];
        if (_isEditing) {
          final existingContact = await dataService.getContact(widget.contactId!);
          // No context use here yet, so direct assignment is fine
          startDate = existingContact.startDate;
          notes = existingContact.notes;
        }

        contactData = Contact(
          id: _patientId,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          age: int.tryParse(_ageController.text.trim()),
          location: _locationController.text.trim(),
          initialComplaints: _initialComplaintsController.text.trim(),
          initialAnalysis: _initialAnalysisController.text.trim(),
          avatarUrl: _avatarFile?.path ?? _existingAvatarUrl,
          startDate: startDate,
          notes: notes,
        );

        if (_isEditing) {
          await dataService.updateContact(contactData);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Contact updated successfully!', style: GoogleFonts.ptSans())),
          );
        } else {
          await dataService.addContact(contactData);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Contact added successfully!', style: GoogleFonts.ptSans())),
          );
        }
        if (!mounted) return;
        Navigator.of(context).pop(true);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save contact: $e', style: GoogleFonts.ptSans())),
        );
      }
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _locationController.dispose();
    _initialComplaintsController.dispose();
    _initialAnalysisController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Contact' : 'Add New Contact'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.save),
            tooltip: 'Save Contact',
            onPressed: _isLoading ? null : _saveForm,
          )
        ],
      ),
      body: _isLoading && _patientId.isEmpty // Simplified loading condition
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: theme.colorScheme.surfaceContainerHighest, // Updated
                          backgroundImage: _avatarFile != null
                              ? FileImage(File(_avatarFile!.path))
                              : (_existingAvatarUrl != null && _existingAvatarUrl!.isNotEmpty
                                  ? NetworkImage(_existingAvatarUrl!)
                                  : null) as ImageProvider?,
                          child: (_avatarFile == null && (_existingAvatarUrl == null || _existingAvatarUrl!.isEmpty))
                              ? Icon(LucideIcons.userPlus, size: 50, color: theme.colorScheme.onSurfaceVariant)
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        _avatarFile == null && (_existingAvatarUrl == null || _existingAvatarUrl!.isEmpty) 
                        ? 'Tap to add photo' 
                        : 'Tap to change photo',
                        style: GoogleFonts.ptSans(color: theme.colorScheme.primary, fontSize: 14)
                      )
                    ),
                    const SizedBox(height: 24),
                    if (_patientId.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Patient ID',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                            filled: true,
                            fillColor: theme.colorScheme.surface.withAlpha(100),
                          ),
                          child: Text(_patientId, style: GoogleFonts.ptSans(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    _buildTextFormField(
                      controller: _nameController,
                      label: 'Full Name',
                      icon: LucideIcons.user,
                      validator: (value) => (value == null || value.isEmpty) ? 'Please enter a name' : null,
                    ),
                    _buildTextFormField(
                      controller: _emailController,
                      label: 'Email Address',
                      icon: LucideIcons.mail,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter an email';
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    _buildTextFormField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      icon: LucideIcons.phone,
                      keyboardType: TextInputType.phone,
                       validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter a phone number';
                        if (value.replaceAll(RegExp(r'[^0-9]'), '').length < 7) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                    _buildTextFormField(
                      controller: _ageController,
                      label: 'Age (Optional)',
                      icon: LucideIcons.cake,
                      keyboardType: TextInputType.number,
                    ),
                    _buildTextFormField(
                      controller: _locationController,
                      label: 'Location (Optional)',
                      icon: LucideIcons.mapPin,
                    ),
                    _buildTextFormField(
                      controller: _initialComplaintsController,
                      label: 'Initial Complaints (Optional)',
                      icon: LucideIcons.clipboardList,
                      maxLines: 3,
                    ),
                     _buildTextFormField(
                      controller: _initialAnalysisController,
                      label: 'Initial Analysis (Optional)',
                      icon: LucideIcons.microscope, 
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton.icon(
                        icon: _isLoading 
                            ? Container(width: 24, height: 24, padding: const EdgeInsets.all(2.0), child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 3,))
                            : Icon(_isEditing ? Icons.check_circle_outline : Icons.add_circle_outline, size: 20), // Updated icons
                        label: Text(_isEditing ? 'Update Contact' : 'Create Contact', style: GoogleFonts.ptSans(fontSize: 18, fontWeight: FontWeight.w600)),
                        onPressed: _isLoading ? null : _saveForm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int? maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Icon(icon, size: 20),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
        keyboardType: keyboardType,
        validator: validator,
        maxLines: maxLines,
        style: GoogleFonts.ptSans(),
        textCapitalization: label.toLowerCase().contains('name') || label.toLowerCase().contains('location') 
                           ? TextCapitalization.words 
                           : (maxLines != null && maxLines > 1 ? TextCapitalization.sentences : TextCapitalization.none),
      ),
    );
  }
}
