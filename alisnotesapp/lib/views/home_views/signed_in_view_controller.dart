import 'package:alisnotesapp/views/home_views/Clans/clans_home.dart';
import 'package:alisnotesapp/views/home_views/Clans/your_clan.dart';
import 'package:alisnotesapp/views/home_views/leaderboard/leaderboard.dart';
import 'package:alisnotesapp/views/home_views/profile.dart';
import 'package:alisnotesapp/views/home_views/referee.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class SignedInParent extends StatefulWidget {
  const SignedInParent({super.key});

  @override
  State<SignedInParent> createState() => _SignedInParentState();
}

class _SignedInParentState extends State<SignedInParent> {
  late final String userPhoneNumber;
  int _selectedIndex = 4;
  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    userPhoneNumber = FirebaseAuth.instance.currentUser!.phoneNumber!;
    _widgetOptions = [
      YourClan(phoneNumber: userPhoneNumber),
      RefereeMainScreen(),
      ClanHome(),
      ClanLeaderboard(),
      Profile(),
    ];
  }

  void onItemTapped(int index){
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex)
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem> [
          BottomNavigationBarItem(icon: Icon(Icons.email_rounded), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: ''),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.red,
        selectedIconTheme: const IconThemeData(size: 40),
        unselectedIconTheme: const IconThemeData(size: 30),
        unselectedItemColor: const Color.fromARGB(255, 121, 120, 120),
        onTap: onItemTapped,
      )
    );
  }
}
