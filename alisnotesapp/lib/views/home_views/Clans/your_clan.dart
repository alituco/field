import 'package:alisnotesapp/views/home_views/Clans/Match/clan_matches.dart';
import 'package:alisnotesapp/views/home_views/Profile/view_profile.dart';
import 'package:flutter/material.dart';
import 'package:alisnotesapp/db/service_folder/clan_service.dart';
import 'package:alisnotesapp/db/models/clan_model.dart';
import 'package:alisnotesapp/db/service_folder/user_service.dart';
import 'package:alisnotesapp/db/models/user_model.dart';
import 'dart:math' as math;

class YourClan extends StatefulWidget {
  final String phoneNumber;

  const YourClan({super.key, required this.phoneNumber});

  @override
  State<YourClan> createState() => _YourClanState();
}

class _YourClanState extends State<YourClan> {
  UserService _userService = UserService();
  ClanService _clanService = ClanService();
  Future<Clan?>? clan;
  Future<List<UserProfile>>? members;

  @override
  void initState() {
    super.initState();
    clan = fetchUserClans();
  }

  Future<Clan?> fetchUserClans() async {
    try {
      var user = await _userService.getUserByPhoneNumber(widget.phoneNumber);
      if (user != null && user.clans.isNotEmpty) {
        return await _clanService.getClanData(user.clans[0]);
      }
      return null;
    } catch (e) {
      print('Error fetching clan: $e');
      return null;
    }
  }

  Future<List<UserProfile>> fetchMembers(List<String> memberIDs) async {
    try {
      List<UserProfile> membersList = [];
      for (String memberId in memberIDs) {
        var member = await _userService.getUserByPhoneNumber(memberId);
        if (member != null) {
          membersList.add(member);
        }
      }
      return membersList;
    } catch (e) {
      print('Error fetching members: $e');
      return [];
    }
  }

  void mockButtonFunction() {
    print('Mock button pressed');
  }

  void navigateToUserPage(UserProfile userProfile) {
    print("Navigating to ${userProfile.username} profile");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ViewProfile(userProfile: userProfile)),
    );
  }

  Future<void> leaveClan() async {
    try {
      var user = await _userService.getUserByPhoneNumber(widget.phoneNumber);
      var currentClan = await clan;

      if (user != null && currentClan != null) {
        await _clanService.kickUser(currentClan, user);
        setState(() {
          clan = fetchUserClans(); // Refresh the clan data
        });
      }
    } catch (e) {
      print('Error leaving clan: $e');
    }
  }

  void navigateToMatches(Clan resolvedClan) {
    if (clan != null) {
      Navigator.push(
        context, 
        MaterialPageRoute(builder: (context) => ClanMatches(clan: resolvedClan))
        );
    }
  }

  void showLeaveConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Leave"),
          content: const Text("Are you sure you want to leave the clan?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await leaveClan(); // Perform the leave action
              },
              child: const Text("Leave"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Clan?>(
        future: clan,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.data != null) {
            Clan resolvedClan = snapshot.data!;
            final int sr = snapshot.data!.skillRating; // Directly use as int
            final int maxSr = 200; // Max SR value
            return Padding(
              padding: const EdgeInsets.only(top: 60.0, left: 14, right: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'Your Clan',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 78, 72, 54),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipOval(
                        child: Image.asset(
                          'lib/assets/images/mock_images/clan-mock-pfp.jpg',
                          width: 130,
                          height: 130,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 9),
                          Row(
                            children: [
                              Text(
                                snapshot.data?.clanName ?? '',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -1.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(
                                  color: Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Contender',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 250,
                            child: Text(
                              snapshot.data?.description ?? '',
                              style: const TextStyle(
                                color: Colors.black,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ),
                          Text('SR: $sr')
                        ],
                      )
                    ],
                  ),
                  // New: Progress indicator
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: sr / maxSr.toDouble(), // Normalize the value
                              backgroundColor: Colors.grey[300],
                              color: const Color.fromARGB(255, 3, 235, 14),
                              minHeight: 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              const Color.fromARGB(255, 71, 71, 80),
                            ),
                          ),
                          onPressed: () => navigateToMatches(resolvedClan),
                          child: const Text(
                            'Matches',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 17,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.red),
                          ),
                          onPressed: showLeaveConfirmationDialog,
                          child: const Text(
                            'Leave',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Members',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '+',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FutureBuilder<List<UserProfile>>(
                    future: fetchMembers(snapshot.data!.membersIDs),
                    builder: (context, memberSnapshot) {
                      if (memberSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (memberSnapshot.hasError) {
                        return Center(child: Text("Error: ${memberSnapshot.error}"));
                      } else if (memberSnapshot.data != null) {
                        return Column(
                          children: memberSnapshot.data!.map((member) {
                            return ListTile(
                              leading: CircleAvatar(
                                radius: 22,
                                backgroundColor: Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0),
                                //child: Text(member.username[0].toUpperCase()),
                              ),
                              title: Text(member.username),
                              subtitle: const Text('Member'),
                              onTap: () => navigateToUserPage(member),
                            );
                          }).toList(),
                        );
                      } else {
                        return const Center(child: Text("No members found."));
                      }
                    },
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text("You are not part of any clan."));
          }
        },
      ),
    );
  }
}
