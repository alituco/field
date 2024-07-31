import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  String id;
  String clan1Id;
  String? clan2Id;
  DateTime time;
  String location;
  bool isFilled;
  String? winner;

  Event({
    required this.id,
    required this.clan1Id,
    this.clan2Id,
    required this.time,
    required this.location,
    required this.isFilled,
    this.winner,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'clan1Id': clan1Id,
      'clan2Id': clan2Id,
      'time': time,
      'location': location,
      'isFilled': isFilled,
      'winner': winner,
    };
  }

  factory Event.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id,
      clan1Id: data['clan1Id'],
      clan2Id: data['clan2Id'],
      time: data['time'] != null ? (data['time'] as Timestamp).toDate() : DateTime.now(), // Provide default value
      location: data['location'] ?? 'Unknown Location',
      isFilled: data['isFilled'] ?? false,
      winner: data['winner'],
    );
  }
}
