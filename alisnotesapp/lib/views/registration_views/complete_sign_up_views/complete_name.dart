import 'package:alisnotesapp/views/registration_views/complete_sign_up_views/complete_email.dart';
import 'package:flutter/material.dart';

class CompleteName extends StatefulWidget {
  const CompleteName({super.key});

  @override
  State<CompleteName> createState() => _CompleteNameState();
}

class _CompleteNameState extends State<CompleteName> {

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  void goNext() {
    print('Name: ${_firstNameController.text} ${_lastNameController.text}');
    if (_firstNameController.text != "") {
      Navigator.push(
        context, 
        MaterialPageRoute(builder: (context) => CompleteEmail(firstName: _firstNameController.text, lastName: _lastNameController.text))
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your first name to continue.'),
          duration: Duration(seconds: 2),
          )
      );
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
            CircleAvatar(radius: 3, backgroundColor: Color.fromARGB(255, 252, 0, 0),),
            SizedBox(width: 20,),
            CircleAvatar(radius: 3, backgroundColor: Color.fromARGB(255, 187, 186, 186),),
            SizedBox(width: 20,),
            CircleAvatar(radius: 3, backgroundColor: Color.fromARGB(255, 187, 186, 186),),
            SizedBox(width: 20,),
            CircleAvatar(radius: 3, backgroundColor: Color.fromARGB(255, 187, 186, 186),),
          ],),
          const SizedBox(height: 30,),
          const Text("What's your name?", style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w600,
            letterSpacing: -1
          ),),
          const SizedBox(height: 10,),
          TextField(
            controller: _firstNameController,
            decoration: const InputDecoration(
            hintStyle: TextStyle(
              color: Colors.grey,
              fontStyle: FontStyle.italic,
              fontSize: 17
            ),
            hintText: "First Name (required)"),
            ),
          const SizedBox(height: 10,),
          TextField(
            controller: _lastNameController,
            decoration: const InputDecoration(
            hintStyle: TextStyle(
              color: Colors.grey,
              fontStyle: FontStyle.italic,
              fontSize: 17
            ),
            hintText: "Last Name"),
            ),
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
        ],),
      ),
    );
  }
}