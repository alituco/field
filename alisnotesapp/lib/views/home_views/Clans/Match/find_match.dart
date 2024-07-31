import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'create_match.dart';
import '../../../../db/models/event_model.dart';
import '../../../../db/service_folder/event_service.dart';

class FindMatch extends StatefulWidget {
  final String clanId;
  final String clanName;

  const FindMatch({Key? key, required this.clanId, required this.clanName}) : super(key: key);

  @override
  State<FindMatch> createState() => _FindMatchState();
}

class _FindMatchState extends State<FindMatch> {
  final EventService _eventService = EventService();

  void navigateToCreateMatch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateMatch(clanId: widget.clanId, clanName: widget.clanName),
      ),
    );
  }

  void joinMatch(BuildContext context, String eventId) {
    _eventService.joinEvent(eventId, widget.clanName).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully joined the match')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to join the match: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Match!'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: navigateToCreateMatch,
            child: const Text('Start a match'),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('events')
                  .where('isFilled', isEqualTo: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final events = snapshot.data!.docs.map((doc) => Event.fromDocumentSnapshot(doc)).toList();
                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return ListTile(
                      title: Text('Match at ${event.location} on ${event.time}'),
                      trailing: ElevatedButton(
                        onPressed: () => joinMatch(context, event.id),
                        child: const Text('Join Match'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
