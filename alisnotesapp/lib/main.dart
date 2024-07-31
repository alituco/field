import 'package:alisnotesapp/firebase_options.dart';
//import 'package:alisnotesapp/views/registration_views/complete_sign_up_views/complete_name.dart';
import 'package:alisnotesapp/views/user_registration.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark, 
    statusBarBrightness: Brightness.dark, 
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        
        useMaterial3: true,
      ),
      home: const UserRegistration(),
    );  
  }
}


