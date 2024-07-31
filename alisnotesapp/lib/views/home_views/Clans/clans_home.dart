import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../db/models/clan_model.dart';
import '../../../db/models/user_model.dart';
import '../../../db/service_folder/clan_service.dart';
import '../../../db/service_folder/user_service.dart';
import './create_clan.dart';
import './clan_page.dart';

class ClanHome extends StatefulWidget {
  const ClanHome({Key? key}) : super(key: key);

  @override
  State<ClanHome> createState() => _ClanHomeState();
}

class _ClanHomeState extends State<ClanHome> {
  final ClanService _clanService = ClanService();
  UserProfile currentUserProfile = UserProfile(
    id: '',
    firstName: '',
    phoneNumber: '',
    username: 'username',
    biography: 'bio',
    dob: DateTime.parse('0001-01-01 01:01:04Z'),
    gender: 'gender',
    favoriteSport: 'favoriteSport',
    clans: List.empty(),
    profilePictureUrl: 'https://jodilogik.com/wp-content/uploads/2016/05/people-1.png',
  );
  bool isLoading = false;
  final User? firebaseUser = FirebaseAuth.instance.currentUser;
  late Future<List<Clan>> _clansFuture;

  @override
  void initState() {
    super.initState();
    fetchProfileData();
    _clansFuture = getClans();
  }

  Future<void> fetchProfileData() async {
    setState(() {
      isLoading = true;
    });

    final User? firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null && firebaseUser.phoneNumber != null) {
      UserProfile? userProfile = await UserService().getUserByPhoneNumber(firebaseUser.phoneNumber!);
      if (userProfile != null) {
        setState(() {
          currentUserProfile = userProfile;
        });
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  void navigateToCreateClan() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateClan()),
    );
  }

  void navigateToClanPage(Clan clan) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ClanPage(clan: clan)),
    ).then((_) {
      setState(() {
        _clansFuture = getClans();
      });
    });
  }

  Future<List<Clan>> getClans() async {
    setState(() {
      isLoading = true;
    });
    try {
      List<Clan> clans = await _clanService.getClans();
      setState(() {
        isLoading = false;
      });
      print('fetched clans.');
      return clans;
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      throw err;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 90.0, left: 40.0, right: 40.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  const Text(
                    'Clans',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: navigateToCreateClan,
                    icon: const Icon(Icons.add, size: 30),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const SizedBox(
                height: 50,
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Find a clan',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20,),
              const Text(
                'Explore clans',
                style: TextStyle(fontSize: 25),
              ),
              const SizedBox(height: 5,),
              FutureBuilder<List<Clan>>(
                future: _clansFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    List<Clan> clans = snapshot.data!;
                    return SizedBox(
                      height: 150, // Specify a height for the ListView
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: clans.length,
                        itemBuilder: (context, index) {
                          Clan clan = clans[index];
                          return GestureDetector(
                            onTap: () => navigateToClanPage(clan),
                            child: Card(
                              child: SizedBox(
                                width: 150,
                                child: ListTile(
                                  title: Text(clan.clanName),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  } else {
                    return const Text('No clans found');
                  }
                },
              ),
              const SizedBox(height: 100,),
              const Text('Your clans', style: TextStyle(fontSize: 25),),
              const SizedBox(height: 5,),
              FutureBuilder<List<Clan>>(
                future: _clanService.getClansByNames(currentUserProfile.clans),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (snapshot.hasData) {
                    List<Clan> clans = snapshot.data!;
                    return SizedBox(
                      height: 150, // Specify a height for the ListView
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: clans.length,
                        itemBuilder: (context, index) {
                          Clan clan = clans[index];
                          return GestureDetector(
                            onTap: () => navigateToClanPage(clan),
                            child: Card(
                              child: SizedBox(
                                width: 150,
                                child: ListTile(
                                  title: Text(clan.clanName),
                                  subtitle: Text('Owner: ${clan.clanOwnerId}'),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  } else {
                    return const Text('No clans found');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

 
}