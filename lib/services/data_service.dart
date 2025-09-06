import 'package:contact_chronicle/models/contact.dart';
import 'package:contact_chronicle/models/note.dart';
import 'dart:async'; // Required for Future.delayed

class DataService {
  final List<Contact> _contacts = [
    Contact(
      id: 'PN00001',
      name: 'Alice Johnson',
      email: 'alice.j@example.com',
      phone: '123-456-7890',
      avatarUrl: 'https://picsum.photos/id/237/100/100',
      age: 45,
      location: 'New York, NY',
      startDate: DateTime.parse('2023-10-26T10:00:00Z'),
      initialComplaints: 'Chronic back pain and stiffness.',
      initialAnalysis:
      'Possible lumbar strain or herniated disc. Needs further evaluation.',
      notes: [
        Note(
            id: 'n1',
            createdAt: DateTime.parse('2023-10-26T10:00:00Z'),
            content:
            'Initial consultation. Discussed treatment plan for chronic back pain.'),
        Note(
            id: 'n2',
            createdAt: DateTime.parse('2023-11-02T10:30:00Z'),
            content:
            'Follow-up session. Patient reports improvement.\n- Applied acupuncture to points LI4 and ST36.\n- Advised on gentle stretching.'),
      ],
    ),
    Contact(
      id: 'PN00002',
      name: 'Bob Williams',
      email: 'bob.w@example.com',
      phone: '234-567-8901',
      avatarUrl: 'https://picsum.photos/id/238/100/100',
      age: 52,
      location: 'Chicago, IL',
      startDate: DateTime.parse('2023-11-01T14:00:00Z'),
      initialComplaints: 'High blood pressure and occasional headaches.',
      initialAnalysis:
      'Vitals are stable, but BP is on the higher side. Recommended lifestyle changes.',
      notes: [
        Note(
            id: 'n3',
            createdAt: DateTime.parse('2023-11-01T14:00:00Z'),
            content:
            'Annual check-up. All vitals are normal. Recommended increasing **Vitamin D** intake.'),
      ],
    ),
    Contact(
      id: 'PN00003',
      name: 'Charlie Brown',
      email: 'charlie.b@example.com',
      phone: '345-678-9012',
      avatarUrl: 'https://picsum.photos/id/239/100/100',
      age: 35,
      location: 'Los Angeles, CA',
      startDate: DateTime.parse('2023-11-05T09:00:00Z'),
      initialComplaints: 'Seasonal allergies.',
      initialAnalysis:
      'Prescribed antihistamines and suggested allergy testing.',
      notes: [
        Note(
            id: 'n4',
            createdAt: DateTime.parse('2023-11-05T09:00:00Z'),
            content: 'Patient called to reschedule appointment to next week.')
      ],
    ),
  ];

  Future<List<Contact>> getContacts() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _contacts;
  }

  Future<Contact> getContact(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _contacts.firstWhere((contact) => contact.id == id, orElse: () => throw Exception('Contact not found'));
  }

  Future<void> addContact(Contact contact) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _contacts.insert(0, contact);
  }

  Future<void> updateContact(Contact updatedContact) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index =
    _contacts.indexWhere((contact) => contact.id == updatedContact.id);
    if (index != -1) {
      _contacts[index] = updatedContact;
    }
  }

  Future<void> addNote(String contactId, Note note) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final contactIndex = _contacts.indexWhere((c) => c.id == contactId);
    if (contactIndex == -1) throw Exception('Contact not found to add note');
    
    final contact = _contacts[contactIndex];
    List<Note> mutableNotes = List.from(contact.notes);
    mutableNotes.insert(0, note);
    
    final updatedContact = contact.copyWith(notes: mutableNotes);
    _contacts[contactIndex] = updatedContact;
  }

  Future<void> deleteContact(String contactId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _contacts.removeWhere((contact) => contact.id == contactId);
  }

  Future<void> deleteNote(String contactId, String noteId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final contactIndex = _contacts.indexWhere((c) => c.id == contactId);
    if (contactIndex == -1) throw Exception('Contact not found to delete note from');

    final contact = _contacts[contactIndex];
    List<Note> updatedNotes = List.from(contact.notes);
    updatedNotes.removeWhere((note) => note.id == noteId);

    final updatedContact = contact.copyWith(notes: updatedNotes);
    _contacts[contactIndex] = updatedContact;
  }
  
  String getNextPatientId() {
    if (_contacts.isEmpty) {
      return 'PN00001';
    }
    _contacts.sort((a, b) => a.id.compareTo(b.id));
    final lastId = _contacts.last.id;
    final numericPart = int.tryParse(lastId.substring(2)); 
    if (numericPart != null) {
      return 'PN${(numericPart + 1).toString().padLeft(5, '0')}';
    }
    return 'PN${(_contacts.length + 1).toString().padLeft(5, '0')}';
  }
}
