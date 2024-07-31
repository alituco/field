import 'package:alisnotesapp/views/home_views/signed_in_view_controller.dart';
import 'package:alisnotesapp/views/registration_views/complete_sign_up_views/complete_sign_up.dart';
import 'package:alisnotesapp/views/registration_views/verify_phone.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PhoneNumber extends StatefulWidget {
  const PhoneNumber({super.key});

  @override
  State<PhoneNumber> createState() => _PhoneNumberState();
}

class _PhoneNumberState extends State<PhoneNumber> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _smsController = TextEditingController(); // For SMS code input
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _selectedCountryCode = ''; // Default country code
  int? _resendToken;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId; // To store the Firebase verification ID
  String? _errorMessage;

  final List<String> _countryCodes = ['', '+973', '+966', '+1'];
  Future<void> verifyPhoneNumber() async {

    
    if (_formKey.currentState!.validate()) {
      String fullPhoneNumber = '$_selectedCountryCode${_phoneNumberController.text}';

      await _auth.verifyPhoneNumber(
        phoneNumber: fullPhoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          if (mounted) {
            Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) {
              return const SignedInParent();
            }));
          // Update your state or UI here to reflect successful sign-in
        }},
        verificationFailed: (FirebaseAuthException e) {
          // Log the error or update your UI to show the error message
          ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error occurred: ${e.message}'),
            backgroundColor: Colors.red, // Optional: to enhance visibility
        )
        );
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId; // Store the verification ID
          //_showDialog(); // Trigger UI to enter the verification code
          _resendToken = resendToken;
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(content: Text('Verifcation code sent to $fullPhoneNumber'),
          //   backgroundColor: Colors.green,
          //   )
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => SMSVerificationScreen(verificationId: verificationId, phoneNumber: fullPhoneNumber,))
            );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Handle the timeout case as needed
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Verifcation code auto-retrival timeout'),
            backgroundColor: Colors.amber,
            )
          );
        },
      );
    }
  }


//   void _showDialog() {
//   showDialog(
//     context: context,
//     barrierDismissible: true, 
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: const Text('Enter SMS Code'),
//         content: TextField(
//           controller: _smsController,
//           decoration: const InputDecoration(hintText: 'SMS Code'),
//         ),
//         actions: <Widget>[
//           TextButton(
//             child: const Text('Verify'),
//             onPressed: () async {
//               PhoneAuthCredential credential = PhoneAuthProvider.credential(
//                 verificationId: _verificationId!,
//                 smsCode: _smsController.text,
//               );
//               UserCredential userCredential = await _auth.signInWithCredential(credential);

//               if (userCredential.user != null) {
//                 Navigator.of(context).pop(); // Close the dialog
//                 checkUserProfile(userCredential.user!); // Check if user has a username
//               } else {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Verification failed, user not signed in'))
//                 );
//               }
//             }
//           ),
//           TextButton(
//             onPressed: resendCode, 
//             child: const Text('Resend Code'))
//         ],
//       );
//     },
//   );
// }

  void resendCode() async {
    String fullPhoneNumber = '$_selectedCountryCode${_phoneNumberController.text}';
    await _auth.verifyPhoneNumber(
      phoneNumber: fullPhoneNumber,
      forceResendingToken: _resendToken,  // Use the stored resend token
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        if (mounted) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const SignedInParent()));
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to resend verification code: ${e.message}'), backgroundColor: Colors.red)
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;  // Update the verification ID if necessary
        _resendToken = resendToken;  // Update the resend token
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification code re-sent to $fullPhoneNumber'), backgroundColor: Colors.green)
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;  // Update with the latest verification ID
      },
    );
  }

  void checkUserProfile(User user) async {
    // Corrected query to fetch user profile based on phone number

    String fullPhoneNumber = '$_selectedCountryCode${_phoneNumberController.text}';

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
        Navigator.push(context, MaterialPageRoute(builder: (context) => const CompleteSignIn()));
      }
    } else {
      // No user found with this phone number, handle accordingly
      Navigator.push(context, MaterialPageRoute(builder: (context) => const CompleteSignIn()));
    }
  }






  @override
  Widget build(BuildContext context) {
    bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          title: Image.asset('lib/assets/images/logo/field-logo-white-backgroud.png', height: 50,),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical:30.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 310,
                    child: Text("What's your phone number?",
                        style: TextStyle(
                          fontSize: 38, 
                          fontWeight: FontWeight.w600,
                          letterSpacing: -1,
                          height: 1.3
                          ),),
                  ),
                  const SizedBox(height: 20),
                  const SizedBox(
                    width: 350,
                    child: Text("We'll send a verification code when you tap “Continue” to confirm that it's you.", style: TextStyle(
                      fontSize: 15
                    ),),
                  ),

                  // Country code and phone number fields here...
                  const SizedBox(height: 40,),
                  const Text('Country Code', style: TextStyle(
                    fontSize: 14,
                    color: Color.fromRGBO(87,87,87,1),
                    fontWeight: FontWeight.bold
                  ),),
                  Container(
                    height: 78,
                    width: 370,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DropdownButton<String>(
                          value: _selectedCountryCode,
                          icon: const Icon(Icons.arrow_drop_down),
                          elevation: 16,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                          underline: Container(
                            height: 0,
                            color: Colors.deepPurpleAccent,
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedCountryCode = newValue;
                            });
                          },
                          items: _countryCodes.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value, style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),),
                            );
                          }).toList(),
                        ),
                        const SizedBox(width: 11,),
                        Expanded(
                          child: TextFormField(
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                            controller: _phoneNumberController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Phone Number',  // Re-added labelText for clarity
                              contentPadding: EdgeInsets.symmetric(vertical: 9),
                              enabledBorder: UnderlineInputBorder(  // Defines the border style when the TextFormField is enabled and not focused
                                borderSide: BorderSide(color: Colors.grey, width: 1.0),
                              ),
                              focusedBorder: UnderlineInputBorder(  // Defines the border style when the TextFormField is focused
                                borderSide: BorderSide(color: Colors.blue, width: 2.0),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                setState(() {
                                  _errorMessage = 'Please enter your phone number';
                                });
                                return 'Phone number is required';  // Providing a direct error message
                              } else {
                                setState(() {
                                  _errorMessage = null;
                                });
                              }
                              return null;
                            },
                          ),
                        ),

                      ],
                    ),
                  ),
                  const SizedBox(height: 20,),
                  Center(
                    child: Text( _errorMessage ?? '' ,
                              style: const TextStyle(
                                color: Color.fromRGBO(234, 254, 202, 1)
                                ),
                            
                        ),
                  ),
                              
                if (!isKeyboardVisible) const SizedBox(height: 280,),  // This pushes the button to the bottom when keyboard is not visible
                Center(
                  child: SizedBox(
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
                      onPressed: verifyPhoneNumber,
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _smsController.dispose();
    super.dispose();
  }
}
