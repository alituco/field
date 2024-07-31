import 'package:alisnotesapp/db/service_folder/api_service.dart';
import 'package:alisnotesapp/views/home_views/Clans/Match/clan_matches.dart';
import 'package:alisnotesapp/views/home_views/Profile/view_profile.dart';
import 'package:flutter/material.dart';
import 'package:alisnotesapp/db/service_folder/clan_service.dart';
import 'package:alisnotesapp/db/models/clan_model.dart';
import 'package:alisnotesapp/db/service_folder/user_service.dart';
import 'package:alisnotesapp/db/models/user_model.dart';
import 'dart:math' as math;

class ViewClan extends StatefulWidget {
  final Clan clan;

  const ViewClan({super.key, required this.clan});

  @override
  State<ViewClan> createState() => _ViewClanState();
}

class _ViewClanState extends State<ViewClan> {
  UserService _userService = UserService();
  ClanService _clanService = ClanService();
  ApiService _apiService = ApiService();
  Future<List<UserProfile>>? members;

  @override
  void initState() {
    super.initState();
    members = fetchMembers(widget.clan.membersIDs);
    contactAPI();
  }

  Future<List<UserProfile>> fetchMembers(List<String> phoneNumbers) async {
    try {
      List<UserProfile> membersList = [];
      for (String memberId in phoneNumbers) {
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

  void navigateToUserPage(UserProfile userProfile) {
    print("Navigating to ${userProfile.username} profile");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ViewProfile(userProfile: userProfile)),
    );
  }

  void navigateToMatches(Clan resolvedClan) {
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => ClanMatches(clan: resolvedClan))
    );
  }

  Future<String> contactAPI() async{
    try {
      final data = await ApiService.getTimeframes();
      print(data);
      return data;
    } catch (err){
      print(err);
      return err.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Clan Details"),),
      body: Padding(
        padding: const EdgeInsets.only(top: 10.0, left: 14, right: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 1),
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
                          widget.clan.clanName,
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
                        widget.clan.description ?? '',
                        style: const TextStyle(
                          color: Colors.black,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                    Text('SR: ${widget.clan.skillRating}')
                  ],
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: widget.clan.skillRating / 200.0, // Normalize the value
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        const Color.fromARGB(255, 71, 71, 80),
                      ),
                    ),
                    onPressed: () => navigateToMatches(widget.clan),
                    child: const Text(
                      'Matches',
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
                ],
              ),
            ),
            FutureBuilder<List<UserProfile>>(
              future: members,
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
      ),
    );
  }
}
