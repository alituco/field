import 'package:alisnotesapp/db/service_folder/user_service.dart';
import 'package:alisnotesapp/views/registration_views/complete_sign_up_views/complete_dob.dart';
import 'package:flutter/material.dart';

class CompleteEmail extends StatefulWidget {

  final String firstName;
  final String lastName;

  const CompleteEmail({super.key, required this.firstName, required this.lastName});



  @override
  State<CompleteEmail> createState() => _CompleteEmailState();
}

class _CompleteEmailState extends State<CompleteEmail> {

  final TextEditingController _emailController = TextEditingController();
  final UserService _userService = UserService();

  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._]+@[a-zA-Z0-9]+\.[a-zA-Z]+$', 
    );
    return emailRegex.hasMatch(email);
  }

  void goNext() async {
    if (!isValidEmail(_emailController.text.trim())) {
      // Show Snackbar if the email is invalid
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address.'),
          duration: Duration(seconds: 2),
        )
      );
    } else {
        bool isEmailTaken = await _userService.isEmailTaken(_emailController.text);
        if (isEmailTaken){
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This email has already been linked to another account'),
              duration: Duration(seconds: 2),
              )
          );
        } else {
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => CompleteDOB(firstName: widget.firstName, lastName: widget.lastName))
            );
        }


    }
  }


    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Image.asset('lib/assets/images/logo/field-logo-white-backgroud.png', height: 50,),
        ),
        body: 
      Padding(
        padding: EdgeInsets.only(top: 50.0, left: 32, right: 40, bottom: 3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          const Row(children: [
              CircleAvatar(radius: 3, backgroundColor: Color.fromARGB(255, 187, 186, 186),),
              SizedBox(width: 20,),
              CircleAvatar(radius: 3, backgroundColor: Color.fromARGB(255, 252, 0, 0),),
              SizedBox(width: 20,),
              CircleAvatar(radius: 3, backgroundColor: Color.fromARGB(255, 187, 186, 186),),
              SizedBox(width: 20,),
              CircleAvatar(radius: 3, backgroundColor: Color.fromARGB(255, 187, 186, 186),),
            ],),
          const SizedBox(height: 30,),
          const Text("Please provide a valid email.", style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w600,
            letterSpacing: -1,
            height: 1.2
          ),),
          const SizedBox(height: 13,),
          const Text('Email verification helps us keep your account secure. Learn more', style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Color.fromRGBO(113, 112, 112, 1),
            letterSpacing: -0.4,
            height: 1.2,
            fontSize: 14.5
          ),),
          const SizedBox(height: 15,),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
            hintStyle: TextStyle(
              color: Colors.grey,
              fontStyle: FontStyle.italic,
              fontSize: 17
            ),
            hintText: "Email address"),
            ),

          const SizedBox(height: 70,),
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
                        onPressed: () => goNext(),
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
        ]
        ),
        
      ),);
    }
  }