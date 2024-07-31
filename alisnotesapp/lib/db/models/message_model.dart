import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderPhoneNumber;
  final String text;
  final DateTime timestamp;

  Message({
    required this.senderPhoneNumber,
    required this.text,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderPhoneNumber': senderPhoneNumber,
      'text': text,
      'timestamp': timestamp,
    };
  }

  static Message fromMap(Map<String, dynamic> map) {
    return Message(
      senderPhoneNumber: map['senderPhoneNumber'],
      text: map['text'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}
