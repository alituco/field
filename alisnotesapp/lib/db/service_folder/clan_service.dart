import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/clan_model.dart';
import '../models/user_model.dart';

class ClanService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final CollectionReference _clanCollection = FirebaseFirestore.instance.collection('clans');
  

  // Method to create a new clan
  Future<void> createClan(Clan clan) async {
    if (clan.clanName.isEmpty) {
      print('Clan name is empty.');
      return;
    }

    try {
      await _clanCollection.add(clan.toMap());
      print("Clan Added");
    } catch (error) {
      print("Failed to add clan: $error");
    }
  }


  // Method to fetch clan data by name
  Future<Clan?> getClanData(String clanName) async {
    try {
      QuerySnapshot querySnapshot = await _clanCollection
          .where('clanName', isEqualTo: clanName)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot doc = querySnapshot.docs.first;
        return Clan.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error fetching clan data: $e');
      return null;
    }
  }


  // Method to fetch all clans
  Future<List<Clan>> getClans() async {
    try {
      QuerySnapshot querySnapshot = await _clanCollection.get();
      return querySnapshot.docs.map((doc) {
        return Clan.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (err) {
      print('Error fetching clans: $err');
      return [];
    }
  }


  // Method for a user to join a clan
  Future<void> joinClan(Clan clan, UserProfile user) async {
    try {
      // Add user to clan's member list
      QuerySnapshot clanSnapshot = await _clanCollection
          .where('clanName', isEqualTo: clan.clanName)
          .limit(1)
          .get();

      if (clanSnapshot.docs.isNotEmpty) {
        DocumentSnapshot clanDocument = clanSnapshot.docs.first;
        await _clanCollection.doc(clanDocument.id).update({
          'membersIDs': FieldValue.arrayUnion([user.phoneNumber])
        });
      }

      // Add clan to user's clan list
      QuerySnapshot userSnapshot = await _db.collection('users')
          .where('phoneNumber', isEqualTo: user.phoneNumber)
          .limit(1)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        DocumentSnapshot userDocument = userSnapshot.docs.first;
        await _db.collection('users').doc(userDocument.id).update({
          'clans': FieldValue.arrayUnion([clan.clanName])
        });
      }
    } catch (err) {
      print('Error joining clan: $err');
    }
  }


  // Method to fetch clans by a list of names
  Future<List<Clan>> getClansByNames(List<String> clanNames) async {
    List<Clan> clans = [];
    for (String name in clanNames) {
      try {
        QuerySnapshot querySnapshot = await _clanCollection
            .where('clanName', isEqualTo: name)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          var doc = querySnapshot.docs.first;
          clans.add(Clan.fromMap(doc.data() as Map<String, dynamic>));
        }
      } catch (err) {
        print('Error fetching clan by name: $err');
      }
    }
    return clans;
  }


  Future<Clan> getClanByName(String clanName) async{

    try {
      QuerySnapshot querySnapshot = await _clanCollection
          .where('clanName', isEqualTo: clanName)
          .get();

      if (querySnapshot.docs.isNotEmpty){
        var doc = querySnapshot.docs.first;
        return Clan.fromMap(doc.data() as Map<String, dynamic>);
      }
      throw Exception('Error getting clan by name.');
    } catch (err){
      print('error fetching clan by clan name: $err');
      rethrow;
    }
  }

  Future<void> kickUser(Clan clan, UserProfile userProfile) async{
    List<String> updatedMembersIDs = List.from(clan.membersIDs)..remove(userProfile.phoneNumber);

    QuerySnapshot clanSnapshot = await _clanCollection
        .where('clanName', isEqualTo: clan.clanName)
        .get();

    if (clanSnapshot.docs.isNotEmpty){
      var doc = clanSnapshot.docs.first;
      await _clanCollection.doc(doc.id).update({
        'membersIDs': updatedMembersIDs
      });
      print('membersIDs updated');
    } 

    List<String> updatedClans = List.from(userProfile.clans)..remove(clan.clanName); 
    await FirebaseFirestore.instance.collection('users').doc(userProfile.id).update({
      'clans': updatedClans,
    });
    print('Updated users clans list');

  }

  // Method to delete a clan
  Future<void> deleteClan(String clanName) async {
    try {
      // Find the clan by name
      QuerySnapshot clanSnapshot = await _clanCollection
          .where('clanName', isEqualTo: clanName)
          .limit(1)
          .get();

      if (clanSnapshot.docs.isNotEmpty) {
        DocumentSnapshot clanDoc = clanSnapshot.docs.first;

        // Delete the clan document
        await _clanCollection.doc(clanDoc.id).delete();
        print("Clan deleted");

        // Update all users who are members of this clan
        QuerySnapshot userSnapshot = await _db.collection('users')
            .where('clans', arrayContains: clanName)
            .get();

        for (var doc in userSnapshot.docs) {
          await _db.collection('users').doc(doc.id).update({
            'clans': FieldValue.arrayRemove([clanName])
          });
        }
        print("Updated users' clan lists");
      } else {
        print("No clan found with the name $clanName");
      }
    } catch (error) {
      print("Failed to delete clan: $error");
    }
  }


  Future<List<Clan>> getTop10Clans() async {
    List<Clan> clans = [];
    try {
      QuerySnapshot querySnapshot = await _clanCollection
                        .orderBy('skillRating', descending: true)
                        .limit(10)
                        .get();


    clans = querySnapshot.docs.map((doc) {
      return Clan.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();

    return clans;

    } catch (err){
      print('ERROR: $err');
      return clans;
    }
  }


  // Function to get clan ID from clanName
  Future<String?> getClanIdByClanName(String clanName) async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('clans')
        .where('clanName', isEqualTo: clanName)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.id; // Return the document ID
    }
    return null;
  }

  // Function to send a message
  Future<void> sendMessage(String clanName, String senderId, String text) async {
    String? clanId = await getClanIdByClanName(clanName);
    if (clanId != null) {
      await FirebaseFirestore.instance.collection('clans').doc(clanId).collection('messages').add({
        'senderId': senderId,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      print("Clan not found.");
    }
  }


}
