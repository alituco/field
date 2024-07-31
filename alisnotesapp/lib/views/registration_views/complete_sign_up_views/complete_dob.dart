import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:alisnotesapp/views/registration_views/complete_sign_up_views/complete_username.dart';
import 'package:intl/intl.dart';  // Make sure to add this line if you're using any formatting

class CompleteDOB extends StatefulWidget {
  final String firstName;
  final String? lastName;
  final String? email;

  const CompleteDOB({super.key, required this.firstName, this.lastName, this.email});

  @override
  State<CompleteDOB> createState() => _CompleteDOBState();
}

class _CompleteDOBState extends State<CompleteDOB> {
  TextEditingController _dayController = TextEditingController();
  TextEditingController _monthController = TextEditingController();
  TextEditingController _yearController = TextEditingController();

  void finishSignUp() {
    // Parse date components
    int day = int.tryParse(_dayController.text.trim()) ?? 0;
    int month = int.tryParse(_monthController.text.trim()) ?? 0;
    int year = int.tryParse(_yearController.text.trim()) ?? 0;

    // Check for valid date inputs
    if (day == 0 || month == 0 || year == 0) {
      _showError("Please enter a valid date.");
      return;
    }

    // Calculate age
    DateTime birthDate = DateTime(year, month, day);
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    if (birthDate.month > currentDate.month || (birthDate.month == currentDate.month && birthDate.day > currentDate.day)) {
      age--;
    }

    // Check age restriction
    if (age < 13) {
      _showError("You must be at least 13 years old to sign up.");
    } else if (age > 70) {
        _showError("You must under 70 years old");
      } else {
      print("First Name: ${widget.firstName}");
      print("Last Name: ${widget.lastName}");
      print("Email: ${widget.email}");
      print("DOB: $birthDate");
      Navigator.push(context, MaterialPageRoute(builder: (context) => CompleteUsername(
        firstName: widget.firstName,
        dob: birthDate,
        )));
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('lib/assets/images/logo/field-logo-white-backgroud.png', height: 50),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 50.0, left: 32, right: 32, bottom: 3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(children: [
              CircleAvatar(radius: 3, backgroundColor: Color.fromARGB(255, 187, 186, 186)),
              SizedBox(width: 20),
              CircleAvatar(radius: 3, backgroundColor: Color.fromARGB(255, 187, 186, 186)),
              SizedBox(width: 20),
              CircleAvatar(radius: 3, backgroundColor: Color.fromARGB(255, 252, 0, 0)),
              SizedBox(width: 20),
              CircleAvatar(radius: 3, backgroundColor: Color.fromARGB(255, 187, 186, 186)),
            ]),
            const SizedBox(height: 30),
            const Text("Birth Date", style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w600,
              letterSpacing: -1
            )),
            const Text('We use this to calculate the age on your profile.', style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Color.fromRGBO(113, 112, 112, 1),
              letterSpacing: 0,
              height: 1.2,
              fontSize: 14.5
            )),
            const SizedBox(height: 50),
            Row(
              children: [
                SizedBox(
                  width: 70,
                  child: PinCodeTextField(
                    hintCharacter: 'D',
                    appContext: context,
                    length: 2,
                    controller: _dayController,
                    obscureText: false,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.underline,
                      fieldHeight: 50,
                      fieldWidth: 30,
                      activeFillColor: Colors.white,
                      selectedFillColor: Colors.white,
                      inactiveFillColor: Colors.grey[200],
                      borderWidth: 1,
                    ),
                    onChanged: (value) {
                      print("Entered day: $value");
                    },
                    onCompleted: (value) {
                      print("Day Completed: $value");
                    },
                  ),
                ),
                SizedBox(width: 35),
                SizedBox(
                  width: 70,
                  child: PinCodeTextField(
                    hintCharacter: 'M',
                    appContext: context,
                    length: 2,
                    controller: _monthController,
                    obscureText: false,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.underline,
                      fieldHeight: 50,
                      fieldWidth: 30,
                      activeFillColor: Colors.white,
                      selectedFillColor: Colors.white,
                      inactiveFillColor: Colors.grey[200],
                      borderWidth: 1,
                    ),
                    onChanged: (value) {
                      print("Entered month: $value");
                    },
                    onCompleted: (value) {
                      print("Month Completed: $value");
                    },
                  ),
                ),
                SizedBox(width: 35),
                SizedBox(
                  width: 150,
                  child: PinCodeTextField(
                    hintCharacter: 'Y',
                    appContext: context,
                    length: 4,
                    controller: _yearController,
                    obscureText: false,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.underline,
                      fieldHeight: 50,
                      fieldWidth: 30,
                      activeFillColor: Colors.white,
                      selectedFillColor: Colors.white,
                      inactiveFillColor: Colors.grey[200],
                      borderWidth: 1,
                    ),
                    onChanged: (value) {
                      print("Entered year: $value");
                    },
                    onCompleted: (value) {
                      print("Year Completed: $value");
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
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
                onPressed: () => finishSignUp(),
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
      ),
    );
  }
}
