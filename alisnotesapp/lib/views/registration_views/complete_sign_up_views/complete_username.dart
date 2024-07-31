import 'package:alisnotesapp/db/models/user_model.dart';
import 'package:alisnotesapp/db/service_folder/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CompleteUsername extends StatefulWidget {
  final String firstName;
  final String? lastName;
  final String? emailAddress;
  final DateTime dob;

  const CompleteUsername({super.key, required this.firstName, this.lastName, this.emailAddress, required this.dob});

  @override
  State<CompleteUsername> createState() => _CompleteUsernameState();
}

class _CompleteUsernameState extends State<CompleteUsername> {

  final TextEditingController _usernameController = TextEditingController();
  final UserService _userService = UserService();

  Future<bool> isNameTaken(String username) async{
    return _userService.isUsernameTaken(username);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      )
    );
  }

  void completeSignUp() async{
    bool isUsernameTaken = await isNameTaken(_usernameController.text);
    if (isUsernameTaken){
      _showError('Username is taken.');
    } else {
        UserProfile newUser = UserProfile(
          id: '', // This will be set after the document is created
          firstName: widget.firstName,
          lastName: widget.lastName,
          emailAddress: widget.emailAddress,
          phoneNumber: FirebaseAuth.instance.currentUser!.phoneNumber!,
          username: _usernameController.text,
          dob: widget.dob,
          gender: 'Unspecified',
          favoriteSport: '',
          biography: null, // Optionally add biography if your form includes it
          clans: [],
        );

        await _userService.addUser(newUser);
          }
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('lib/assets/images/logo/field-logo-white-backgroud.png', height: 50,),),
      body: Padding(
        padding: const EdgeInsets.only(top: 50.0, left: 32, right: 50, bottom: 3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          const Row(children: [
            CircleAvatar(radius: 3, backgroundColor: Color.fromARGB(255, 187, 186, 186),),
            SizedBox(width: 20,),
            CircleAvatar(radius: 3, backgroundColor: Color.fromARGB(255, 187, 186, 186),),
            SizedBox(width: 20,),
            CircleAvatar(radius: 3, backgroundColor: Color.fromARGB(255, 187, 186, 186),),
            SizedBox(width: 20,),
            CircleAvatar(radius: 3, backgroundColor: Color.fromARGB(255, 252, 0, 0),),
          ],),
          const SizedBox(height: 30,),
          const Text("Please enter a username", style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w600,
            letterSpacing: -1,
            height: 1.1
          ),),
          const SizedBox(height: 22,),
            const Text('Pick a cool username to represent you on our platform! Just a heads up, you won’t be able to change it later.', style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Color.fromRGBO(113, 112, 112, 1),
              letterSpacing: 0,
              height: 1.2,
              fontSize: 14.5
            )),
          const SizedBox(height: 10,),
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(
            hintStyle: TextStyle(
              color: Colors.grey,
              fontStyle: FontStyle.italic,
              fontSize: 17
            ),
            hintText: "Player123"),
            ),
          const SizedBox(height: 10,),
            const SizedBox(height: 50,),
            SizedBox(
                    width: 360,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                        shadowColor: Colors.transparent,
                        side: const BorderSide(
                          color: Color.fromRGBO(247, 50, 43, 1),
                        ),
                      ),
                      onPressed: () => completeSignUp(),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          color: Color.fromRGBO(247, 50, 43, 1),
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                        ),
                      ),
                    ),
        ],),
      ),
    );
  }
}