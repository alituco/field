import 'package:alisnotesapp/views/phone_number.dart';
import 'package:flutter/material.dart';

class UserRegistration extends StatefulWidget {
  const UserRegistration({super.key});

  @override
  State<UserRegistration> createState() => _UserRegistrationState();
}

class _UserRegistrationState extends State<UserRegistration> {

  void navigateToPhoneNumber(){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>
        const PhoneNumber()
      ));
    }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("lib/assets/images/background_images/home_background_image.png"),
            fit: BoxFit.cover,
            )
        ),
        child: Padding(
          padding: const EdgeInsets.only(top:280.0),
          child: Column(
            children: <Widget>[
            Image.asset(
              'lib/assets/images/logo/field_logo_1.png',
              width: 80,
            ),
            const SizedBox(height: 90,),
            const SizedBox(
              width: 320,
              child: Text("Play, connect, and get involved.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color.fromRGBO(234, 254, 202, 1),
                fontFamily: 'Roboto',
                fontSize: 40,
                fontWeight: FontWeight.w700,
                height: 1.1,
                letterSpacing: 1.3
              ),),
            ),
            const SizedBox(height: 60,),
            SizedBox(
              width: 340,
              height: 45,
              child: ElevatedButton(onPressed: navigateToPhoneNumber,
              style: ButtonStyle(backgroundColor: MaterialStateProperty.all(const Color.fromRGBO(234, 254, 202, 1))),
                child: const Text("Sign up",
                style: TextStyle(
                  color: Color.fromRGBO(247, 50, 43, 1),
                  fontFamily: "Roboto",
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),)),
            ),
            const SizedBox(height: 15,),
            SizedBox(
              width: 340,
              height: 45,
              child: ElevatedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: const BorderSide(color: Color.fromRGBO(234, 254, 202, 1), width: 2)
                    )
                  ),
                  backgroundColor: MaterialStateProperty.all(const Color.fromRGBO(247, 50, 43, 1))
                ),
                onPressed: navigateToPhoneNumber, 
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                  Icon(Icons.phone, color: Color.fromRGBO(234, 254, 202, 1),),
                  SizedBox(width: 15,),
                  Text('Continue with phone number', style: TextStyle(
                    color: Color.fromRGBO(234, 254, 202, 1),
                    fontFamily: "Roboto",
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),),
                  SizedBox(height: 30,),
                ],)),
            
            
            ), 
            const SizedBox(height: 80,),
            InkWell(
              onTap: () => navigateToPhoneNumber(),
              child: const Text('Sign in', style: TextStyle(
                fontSize: 20,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w500,
                color: Color.fromRGBO(234, 254, 202, 1),
                decoration: TextDecoration.underline,
                decorationColor: Color.fromRGBO(234, 254, 202, 1),
                decorationThickness: 2,
              ),
              ),
            )
            ]
          ,),
        ),
      ),
    );
  }
}