import 'package:contact_chronicle/models/note.dart';

class Contact {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? avatarUrl; // Made nullable as per typical usage
  final int? age;
  final String? location;
  final DateTime startDate;
  final String? initialComplaints;
  final String? initialAnalysis;
  final List<Note> notes;

  Contact({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.avatarUrl,
    this.age,
    this.location,
    required this.startDate,
    this.initialComplaints,
    this.initialAnalysis,
    required this.notes,
  });

  Contact copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    int? age,
    String? location,
    DateTime? startDate,
    String? initialComplaints,
    String? initialAnalysis,
    List<Note>? notes,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      // For nullable fields, if you want to explicitly set them to null via copyWith,
      // this simple pattern (param ?? this.field) means if you pass `null` for avatarUrl,
      // it will retain `this.avatarUrl`. To truly set it to null, a more complex
      // copyWith or a different pattern (like using a special marker object or clear flags)
      // would be needed. However, for the current usage in DataService (updating notes),
      // this is sufficient.
      avatarUrl: avatarUrl ?? this.avatarUrl,
      age: age ?? this.age,
      location: location ?? this.location,
      startDate: startDate ?? this.startDate,
      initialComplaints: initialComplaints ?? this.initialComplaints,
      initialAnalysis: initialAnalysis ?? this.initialAnalysis,
      notes: notes ?? this.notes,
    );
  }
}
