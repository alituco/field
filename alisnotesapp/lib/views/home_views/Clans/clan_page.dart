import 'package:alisnotesapp/db/service_folder/clan_service.dart';
import 'package:alisnotesapp/db/service_folder/event_service.dart';
import 'package:alisnotesapp/db/service_folder/user_service.dart';
import 'package:alisnotesapp/views/home_views/Clans/Match/find_match.dart';
import 'package:alisnotesapp/views/home_views/Clans/clan_chat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../db/models/clan_model.dart';
import '../../../db/models/event_model.dart';
import '../../../db/models/user_model.dart';

class ClanPage extends StatefulWidget {
  final Clan clan;
  const ClanPage({super.key, required this.clan});

  @override
  State<ClanPage> createState() => _ClanPageState();
}

class _ClanPageState extends State<ClanPage> {
  final currentUser = FirebaseAuth.instance.currentUser;
  final UserService userService = UserService();
  final ClanService clanService = ClanService();
  final EventService eventService = EventService();
  bool isLoading = true;
  List<UserProfile> members = [];
  List<Event> events = [];
  late UserProfile? _currentUser;

  @override
  void initState() {
    super.initState();
    fetchClanMembers();
    getEvents();
    getUserProfile();
  }

  Future<void> getUserProfile() async{
   _currentUser = await userService.getUserByPhoneNumber(currentUser?.phoneNumber ?? '0');
  }

  Future<void> getEvents() async{
    setState(() {
      isLoading = true;
    });
    List<Event> fetchedEvents = [];
    fetchedEvents = await eventService.getEvents(widget.clan);
    setState(() {
      events = fetchedEvents;
    });
    isLoading = false;
  }

  Future<void> fetchClanMembers() async {
    setState(() {
      isLoading = true;
    });
    List<UserProfile> fetchedMembers = [];
    for (String phoneNumber in widget.clan.membersIDs) {
      UserProfile? user = await userService.getUserByPhoneNumber(phoneNumber);
      if (user != null) {
        fetchedMembers.add(user);
      }
    }
    if (mounted){
      setState(() {
        members = fetchedMembers;
        isLoading = false; // Set isLoading to false after fetching members
      });
    }
  }

  bool isAdmin() {
    if (currentUser != null) {
      return currentUser?.phoneNumber == widget.clan.clanOwnerId;
    }
    return false;
  }

  Future<void> kickUser(Clan clan, UserProfile userProfile) async{
    setState(() {
      isLoading = true;
    });
    try {
      await clanService.kickUser(clan, userProfile);
      setState(() {
        isLoading = false;
      });
      print('User should have been kicked succesfully!');
    } catch (err){
      print("ERROR.");
      setState(() {
        isLoading = false;
      });
    }
    if (_currentUser != null){
      members.remove(_currentUser);
    }
  }

  bool showJoinButton(){
    if(widget.clan.membersIDs.contains(currentUser?.phoneNumber)) {
      return false;
    } else {
      return true;
    }
  }

  Future<void> joinClan() async {
    setState(() {
      isLoading = true;
    });
    if (_currentUser != null ) {
      await clanService.joinClan(widget.clan, _currentUser!);
    }
    setState(() {
      if (_currentUser != null) {
        members.add(_currentUser!);
      }
    });
    setState(() {
      isLoading = false;
    });
  }

  void navigateToFindMatch(){
    Navigator.push(context, MaterialPageRoute(builder: (context) => FindMatch(clanId: widget.clan.clanOwnerId, clanName: widget.clan.clanName,)));
  }

  void navigateToClanChat(){
    Navigator.push(context, MaterialPageRoute(builder: (context) => ClanChat(clan: widget.clan,)));
  }

  Future<void> deleteClan(Clan clan) async{
    try {
      await clanService.deleteClan(clan.clanName);
    } catch (error) {
      print('Deletion failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final clan = widget.clan;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          clan.clanName,
          style: const TextStyle(fontSize: 40, color: Colors.green),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(), 
                        borderRadius: BorderRadius.circular(20),
                        color: Color.fromARGB(255, 255, 24, 24)
                        ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(255, 243, 33, 33), // Background color for the container
                                    shape: BoxShape.circle, // This makes the container a circle
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.5), // Shadow color with some transparency
                                        spreadRadius: 2, // The size of shadow
                                        blurRadius: 5, // How blurry the shadow should be
                                        offset: const Offset(0, 4), // Changes position of shadow
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.sports_soccer,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),


                                const SizedBox(width: 10,),
                                
                                Text(
                                  clan.description ?? 'No description available.',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600
                                    ),
                                ),
                              ],
                            ),
                            Text('Clan size: ${clan.membersIDs.length}/13', style: const TextStyle(
                              color: Colors.white
                            ),),
                            Text('Skill rating: ${clan.skillRating}', style: const TextStyle(
                              color: Colors.white
                            ),),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => navigateToFindMatch(),
                    child: const Text('Find a match!'),
                  ),
                  const SizedBox(height: 20),
                  for (var entry in members.asMap().entries) ...[
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            title: Row(
                              children: [
                                Text('${entry.key + 1}. '), // Display the index
                                Text(entry.value.username),
                              ],
                            ),
                            subtitle: Text(entry.value.phoneNumber),
                          ),
                        ),
                        if (currentUser?.phoneNumber == clan.clanOwnerId)...[
                        ElevatedButton(
                          onPressed: () => kickUser(clan, entry.value),
                          child: const Text('Kick'),
                        ),
                        ]
                      ],
                    ),
                  ],
                  if (showJoinButton())...[
                    ElevatedButton(onPressed: joinClan, child: const Text('Join Clan'))
                  ],
                  SizedBox(height: 20,),
                  Text('Events'),
                  for (var event in events) ...[
                    Text('${event.clan1Id} ${event.location}'),
                  ],
                  if (clan.clanOwnerId == currentUser?.phoneNumber) ...[
                    ElevatedButton(onPressed: () => deleteClan(clan), child: const Text('Delete clan.'))
                  ],
                  ElevatedButton(onPressed: navigateToClanChat, child: const Text('CHAT YO'))
                ],
              ),
      ),
    );
  }
}
