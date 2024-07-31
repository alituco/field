import 'package:alisnotesapp/views/home_views/signed_in_view_controller.dart';
import 'package:alisnotesapp/views/user_registration.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import '../../../db/service_folder/user_service.dart'; 
import '../../../db/models/user_model.dart';

class CompleteSignIn extends StatefulWidget {
  const CompleteSignIn({super.key});

  @override
  State<CompleteSignIn> createState() => _CompleteSignInState();
}

class _CompleteSignInState extends State<CompleteSignIn> {


  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _favoriteSportController = TextEditingController();
  DateTime? _selectedDate;

  

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Sign Up!'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _dobController,
                decoration: const InputDecoration(
                  labelText: 'Date of Birth',
                  border: OutlineInputBorder(),
                  hintText: 'YYYY-MM-DD',
                ),
                onTap: () {
                  _selectDate(context);
                },
                readOnly: true, // To prevent manual editing
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _genderController,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your gender';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _favoriteSportController,
                decoration: const InputDecoration(
                  labelText: 'Favorite Sport',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your favorite sport';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    print("submitting form");
                    _submitForm();
                  } else{
                    print("Invalid form");
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  String? getPhoneNumber() {
    final User? user = FirebaseAuth.instance.currentUser;
    return user?.phoneNumber;  // This returns the phone number if available
  }

void _submitForm() async {
  String? phoneNumber = getPhoneNumber();
  if (phoneNumber == null) {
    print('Phone number is null');
    Navigator.push(context, MaterialPageRoute(builder: (context) => const UserRegistration()));
    return;
  }

  if (_selectedDate == null) {
    print('Date of birth is not selected');
    // Optionally show an error message
    return;
  }

  // Prepare the new user data
  UserProfile newUser = UserProfile(
    id: '', // This will be set after the document is created
    firstName: 'firstname error',
    phoneNumber: phoneNumber,
    username: _usernameController.text,
    dob: _selectedDate!,
    gender: _genderController.text,
    favoriteSport: _favoriteSportController.text,
    biography: null, // Optionally add biography if your form includes it
    clans: [],
  );

  try {
    // Initialize UserService, add the user, and update the id
    final UserService userService = UserService();
    String newUserId = await userService.addUser(newUser);
    newUser = newUser.copyWith(id: newUserId); // Update the UserProfile with the new Firestore ID

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SignedInParent()));
  } catch (error) {
    print('Failed to add user: $error');
    // Optionally show an error message
  }
}


  @override
  void dispose() {
    _usernameController.dispose();
    _dobController.dispose();
    _genderController.dispose();
    _favoriteSportController.dispose();
    super.dispose();
  }
}
