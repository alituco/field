import 'package:alisnotesapp/views/registration_views/complete_sign_up_views/complete_name.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:alisnotesapp/views/home_views/signed_in_view_controller.dart';

class SMSVerificationScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;
  const SMSVerificationScreen({Key? key, required this.verificationId, required this.phoneNumber}) : super(key: key);

  @override
  _SMSVerificationScreenState createState() => _SMSVerificationScreenState();
}

class _SMSVerificationScreenState extends State<SMSVerificationScreen> {
  final TextEditingController _smsController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  

  void verifySMSCode(String code) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: code.trim(),
      );
      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        // Call checkUserProfile to determine where to navigate
        checkUserProfile(userCredential.user!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification failed, please try again'))
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error occurred: $e'))
      );
    }
  }




    void checkUserProfile(User user) async {
      // Corrected query to fetch user profile based on phone number

      String fullPhoneNumber = _auth.currentUser?.phoneNumber! ?? 'No phone number. Error';

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('phoneNumber', isEqualTo: fullPhoneNumber) // Make sure this field name matches your Firestore
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Extract the data as a Map, assuming there's only one match
        Map<String, dynamic> data = querySnapshot.docs.first.data() as Map<String, dynamic>;
        // Check if 'username' key exists and is not null
        if (data.containsKey('username') && data['username'] != null) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const SignedInParent()));
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const CompleteName()));
        }
      } else {
        // No user found with this phone number, handle accordingly
        Navigator.push(context, MaterialPageRoute(builder: (context) => const CompleteName()));
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('lib/assets/images/logo/field-logo-white-backgroud.png', height: 50,),
      ),
      body: Column(
        children: [
          const SizedBox(height: 35,),
          const SizedBox(
            width: 350,
            child: Text('Verify phone number', style: TextStyle(
              height: 1.3,
              fontSize: 39,
              fontWeight: FontWeight.w600,
              letterSpacing: -1
            ),),
          ),
          const SizedBox(height: 12,),
        
          SizedBox(
            width: 350,
            child: Text('Sent to ${widget.phoneNumber}. Edit')),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 50),
            child: Column(
              children: [
                PinCodeTextField(
                  appContext: context,
                  length: 6,
                  obscureText: false,
                  animationType: AnimationType.fade,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.underline,
                    fieldHeight: 50,
                    fieldWidth: 50,
                    //activeFillColor: Colors.white,
                  ),
                  animationDuration: const Duration(milliseconds: 300),
                  //enableActiveFill: true,
                  onCompleted: (v) {
                    verifySMSCode(v);
                  },
                  onChanged: (value) {
                    print(value);
                  },
                  beforeTextPaste: (text) {
                    return true;
                  },
                ),
                const SizedBox(
                  width: 350,
                  child: Text("Didn't get a code?")),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // ElevatedButton(
          //   onPressed: () => verifySMSCode(_smsController.text),
          //   child: const Text('Verify'),
          // ),
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
                      onPressed: () => verifySMSCode(_smsController.text),
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
                  ],
                ),
              );
            }

  @override
  void dispose() {
    _smsController.dispose();
    super.dispose();
  }
}
