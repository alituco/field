import 'dart:io';

import 'package:alisnotesapp/db/models/clan_model.dart';
import 'package:alisnotesapp/db/models/user_model.dart';
import 'package:alisnotesapp/db/service_folder/clan_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;


class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final firebase_storage.FirebaseStorage _storage = firebase_storage.FirebaseStorage.instance;
  final ClanService _clanService = ClanService();

  // Check if username is taken
  Future<bool> isUsernameTaken(String username) async {
    QuerySnapshot querySnapshot = await _db.collection('users')
                                          .where('username', isEqualTo: username)
                                          .limit(1)
                                          .get();
    return querySnapshot.docs.isNotEmpty;
  }

  Future<bool> isEmailTaken(String emailAddress) async{
    QuerySnapshot querySnapshot = await _db.collection('users')
                                          .where('emailAddress', isEqualTo: emailAddress)
                                          .limit(1)
                                          .get();
    return querySnapshot.docs.isNotEmpty;
  }

  

  // Add a new user to the Firestore database
  Future<String> addUser(UserProfile user) async {
    DocumentReference docRef = await _db.collection('users').add(user.toMap());
    return docRef.id;  // Returns the Firestore document ID of the newly created user
  }

  // Retrieve all users from Firestore as a list of User objects
  Future<List<UserProfile>> getAllUsers() async {
    try {
      QuerySnapshot querySnapshot = await _db.collection('users').get();
      return querySnapshot.docs.map((doc) => UserProfile.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  // Get a single user by Phone Number
  Future<UserProfile?> getUserByPhoneNumber(String phoneNumber) async {
    try {
      print('Fetching user by phone number: $phoneNumber');
      QuerySnapshot querySnapshot = await _db.collection('users')
                                              .where('phoneNumber', isEqualTo: phoneNumber)
                                              .limit(1)
                                              .get();
      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
        var data = documentSnapshot.data();
        if (data != null) {
          return UserProfile.fromMap(data as Map<String, dynamic>, documentSnapshot.id);
        } else {
          print('No data found for user with phone number $phoneNumber');
          return null;
        }
      } else {
        print('No user found with phone number $phoneNumber');
        return null;
      }
    } catch (e, stackTrace) { // Catch block with stack trace
      print('Error getting user by phone number: $phoneNumber');
      print('Error details: ${e.toString()}');
      print('Stack trace: $stackTrace'); // Provides a traceback of the error
      return null;
    }
  }



  // Updating a field of certain user(find by phone number)
  Future<void> updateUser(String phoneNumber, Map<String, dynamic> newData) async {
    try {
      print('Starting update user with phone: $phoneNumber');
      QuerySnapshot querySnapshot = await _db.collection('users')
                                              .where('phoneNumber', isEqualTo: phoneNumber)
                                              .limit(1)
                                              .get();
      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot userDoc = querySnapshot.docs.first;
        await _db.collection('users').doc(userDoc.id).update(newData);
      } else {
        print('no user found with $phoneNumber');
      }
    } catch (err) {
      print('ERROR $err');
    }
  }

  // Delete a user from Firestore
  Future<void> deleteUser(String phoneNumber) async {

    Clan emptyClan;
    UserProfile? emptyUser;

    try {
      
      // fetch each clan in clans field
      DocumentSnapshot userDoc = await _db.collection('users').doc(phoneNumber).get();
      
      if (userDoc.exists){

        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        List<String> userClans = List<String>.from(userData["clans"] ?? []);
        print(" fetched User clans: $userClans");

        for (String clan in userClans){
          emptyClan = await _clanService.getClanByName(clan);
          emptyUser = await getUserByPhoneNumber(phoneNumber);

          if (emptyClan != null && emptyUser != null){
           _clanService.kickUser(emptyClan, emptyUser);
           print(" User with phone number: $phoneNumber deleted from clan $clan");
          }
        }

      }

      // delete user from users collection
      await _db.collection('users').doc(phoneNumber).delete();
      print("User Deleted from user collection");
    } catch (error) {
      print("Failed to delete user: $error");
    }
  }

  // Uploading profile picture by phone number
  Future<String?> uploadProfilePicture(String phoneNumber, File imageFile) async {
    try {
      String filePath = 'profile-pictures/$phoneNumber/${DateTime.now().millisecondsSinceEpoch.toString()}';
      firebase_storage.Reference ref = _storage.ref().child(filePath);

      // Upload the file
      firebase_storage.UploadTask uploadTask = ref.putFile(imageFile);
      await uploadTask.whenComplete(() => {});

      // Get the download URL
      String downloadUrl = await ref.getDownloadURL();

      // Find the user document by phone number
      QuerySnapshot querySnapshot = await _db.collection('users')
                                             .where('phoneNumber', isEqualTo: phoneNumber)
                                             .limit(1)
                                             .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot userDoc = querySnapshot.docs.first;
        await _db.collection('users').doc(userDoc.id).update({'profilePictureUrl': downloadUrl});
        return downloadUrl;
      } else {
        print("No user found with phone number: $phoneNumber");
        return null;  // Optionally handle creating the document or other logic here
      }
    } catch (e) {
      print('Error uploading profile picture: $e');
      return null;
    }
  }

  // Uploading banner picture
  Future<String?> uploadBannerPicture(String phoneNumber, File imageFile) async {
    try {
      String filePath = 'banner-pictures/$phoneNumber/${DateTime.now().millisecondsSinceEpoch.toString()}';
      firebase_storage.Reference ref = _storage.ref().child(filePath);

      // Upload the file
      firebase_storage.UploadTask uploadTask = ref.putFile(imageFile);
      await uploadTask.whenComplete(() => {});

      // Get the download URL
      String downloadUrl = await ref.getDownloadURL();

      // Find the user document by phone number
      QuerySnapshot querySnapshot = await _db.collection('users')
                                             .where('phoneNumber', isEqualTo: phoneNumber)
                                             .limit(1)
                                             .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot userDoc = querySnapshot.docs.first;
        await _db.collection('users').doc(userDoc.id).update({'profileBannerUrl': downloadUrl});
        return downloadUrl;
      } else {
        print("No user found with phone number: $phoneNumber");
        return null;  // Optionally handle creating the document or other logic here
      }
    } catch (e) {
      print('Error uploading profile banner: $e');
      return null;
    }
  }

  // Add user to clan
  Future<void> addUserClan(String phoneNumber, String clanName) async {
    try {
      var collection = _db.collection('users');
      var querySnapshot = await collection.where('phoneNumber', isEqualTo: phoneNumber).limit(1).get();
      if (querySnapshot.docs.isNotEmpty) {
        var userDoc = querySnapshot.docs.first;
        List<dynamic> clans = List.from(userDoc.data()['clans'] ?? []);
        clans.add(clanName);
        await collection.doc(userDoc.id).update({'clans': clans});
      } else {
        print("User not found");
      }
    } catch (e) {
      print("Error updating user's clans: $e");
      throw Exception("Failed to update user's clans.");
    }
  }
}
