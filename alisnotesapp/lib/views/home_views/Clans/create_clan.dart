import 'package:alisnotesapp/db/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../db/models/clan_model.dart';
import '../../../db/service_folder/clan_service.dart';
import '../../../db/service_folder/user_service.dart';

class CreateClan extends StatefulWidget {
  const CreateClan({super.key});

  @override
  State<CreateClan> createState() => _CreateClanState();
}

class _CreateClanState extends State<CreateClan> {

  final _formKey = GlobalKey<FormState>();
  String _clanName = '';
  String _sportType = '';
  String? _description;
  List<String> _membersIDs = []; // Start with the creator's ID, presumably
  bool isLoading = false;
  int numberOfClans = 0;
  
  UserProfile currentUserProfile = UserProfile(id: '',
   firstName: '',
   phoneNumber: '', 
   username: '', 
   dob: DateTime.parse('0001-01-01 01:01:04Z'), 
   gender: '', 
   favoriteSport: '', 
   clans: List.empty());

  void fetchProfileData() async{
    final User? firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser!= null && firebaseUser.phoneNumber != null){
      UserProfile? userProfile = await UserService().getUserByPhoneNumber(firebaseUser.phoneNumber!);
      if (userProfile != null){
        if (mounted){
          setState(() {
            currentUserProfile = userProfile;
            numberOfClans = userProfile.clans.length;
            isLoading = false;
          });
        }
      } else {
        if (mounted){
          setState(() {
            isLoading = false;
          });
        }
      }
    } else {
      if (mounted){
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Clan')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(labelText: 'Clan Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter clan name';
                  }
                  return null;
                },
                onSaved: (value) => _clanName = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Sport Type'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a sport type';
                  }
                  return null;
                },
                onSaved: (value) => _sportType = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description (optional)'),
                onSaved: (value) => _description = value,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Create Clan'),
              ),
              
            ],
          ),
        ),
      ),
    );
  }

    void _submitForm() async {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();

        final User? firebaseUser = FirebaseAuth.instance.currentUser;
        if (firebaseUser == null || firebaseUser.phoneNumber == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to retrieve user information'))
          );
          return;
        }

        String phoneNumber = firebaseUser.phoneNumber!;

        final newClan = Clan(
          clanName: _clanName,
          clanOwnerId: phoneNumber,  // Using Firebase Auth UID as owner ID
          dateCreated: DateTime.now(),
          membersIDs: [phoneNumber],  // Start with the creator's ID
          sportType: _sportType,
          description: _description,
          pendingMembersIDs: [],
          skillRating: 0
        );

        try {
          // Using the ClanService to create a new clan in Firestore
          await ClanService().createClan(newClan);
          await UserService().addUserClan(phoneNumber, _clanName);
          print('Clan successfully added.');
          Navigator.pop(context); // Optionally navigate back or to another relevant page
        } catch (e) {
          print('Failed to create clan or update user profile: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create clan or update user profile: $e'))
          );
        }
      }
    }




}
