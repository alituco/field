import 'package:alisnotesapp/db/service_folder/clan_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../db/models/event_model.dart';
import '../models/clan_model.dart';

class EventService {
  final FirebaseFirestore _db;
  final CollectionReference _eventCollection;
  final CollectionReference _clanCollection;
  final ClanService _clanService = ClanService();

  EventService()
      : _db = FirebaseFirestore.instance,
        _eventCollection = FirebaseFirestore.instance.collection('events'),
        _clanCollection = FirebaseFirestore.instance.collection('clans')
        ;
      
  Future<void> createEvent(Event event) async {
    try {
      await _eventCollection.add(event.toFirestore());
      print("Event Added");
    } catch (error) {
      print("Failed to add event: $error");
    }
  }

  Future<void> joinEvent(String eventId, String clan2Id) async {
    try {
      await _eventCollection.doc(eventId).update({
        'clan2Id': clan2Id,
        'isFilled': true,
      });
      print("Event Joined");
    } catch (error) {
      print("Failed to join event: $error");
    }
  }

  Future<List<Event>> getAllEvents() async {
    List<Event> events = [];
    try {
      QuerySnapshot querySnapshot = await _eventCollection
          .get();

      for (var doc in querySnapshot.docs){
        events.add(Event.fromDocumentSnapshot(doc));
      }
      return events;
    } catch (err){
      print('Error gang. $err');
    }
    return events;
  }

  Future<List<Event>> getEvents(Clan clan) async {
    List<Event> events = [];
    try {
      QuerySnapshot querySnapshot = await _eventCollection
          .where('clan1Id', isEqualTo: clan.clanName)
          .get();

      for (var doc in querySnapshot.docs) {
        events.add(Event.fromDocumentSnapshot(doc));
      }

      querySnapshot = await _eventCollection
          .where('clan2Id', isEqualTo: clan.clanName)
          .get();

      for (var doc in querySnapshot.docs) {
        events.add(Event.fromDocumentSnapshot(doc));
      }

      print("Events fetched successfully");
    } catch (error) {
      print("Failed to fetch events: $error");
    }
    return events;
  }

    Future<void> updateWinner(Event event, String clanName) async {
      try {
        // Retrieve both clans involved in the event
        List<String> clanNames = [event.clan1Id, event.clan2Id ?? ''];
        List<Clan> clans = await _clanService.getClansByNames(clanNames);
        Map<String, Clan> clanMap = { for (var clan in clans) clan.clanName: clan };

        // Determine the winner and loser
        Clan? winner = clanMap[clanName];
        Clan? loser = clanMap[clanName == event.clan1Id ? event.clan2Id : event.clan1Id];

        if (winner == null || loser == null) {
          print('Server error: Invalid clan specified.');
          return;  // Exit if winner or loser is not found
        }

        // Fetch documents for winner and loser using clan names
        DocumentSnapshot winnerDoc = await _clanCollection
          .where('clanName', isEqualTo: winner.clanName)
          .limit(1)
          .get()
          .then((snapshot) => snapshot.docs.first);
        DocumentSnapshot loserDoc = await _clanCollection
          .where('clanName', isEqualTo: loser.clanName)
          .limit(1)
          .get()
          .then((snapshot) => snapshot.docs.first);

        // Ensure data is a Map before accessing it
        Map<String, dynamic> winnerData = winnerDoc.data() as Map<String, dynamic>? ?? {};
        Map<String, dynamic> loserData = loserDoc.data() as Map<String, dynamic>? ?? {};

        // Update skill ratings
        int winnerOldRating = winnerData['skillRating'] as int? ?? 0;
        int loserOldRating = loserData['skillRating'] as int? ?? 0;

        await _clanCollection.doc(winnerDoc.id).update({
          'skillRating': winnerOldRating + 10
        });
        await _clanCollection.doc(loserDoc.id).update({
          'skillRating': loserOldRating - 10
        });

        // Update the event record with the winner
        await _eventCollection.doc(event.id).update({
          'winnerClan': winner.clanName
        });
        print("Event record updated with new winner.");
      } catch (e) {
        print("Failed to update event winner: $e");
      }
    }


}

