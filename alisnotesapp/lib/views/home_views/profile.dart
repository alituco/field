import 'package:alisnotesapp/db/models/user_model.dart';
import 'package:alisnotesapp/views/home_views/Profile/edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../db/service_folder/user_service.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String displayName = '';
  String biography = '';
  bool isLoading = true;
  bool isBannerLoading = false; // New state variable for banner loading
  UserProfile currentUserProfile = UserProfile(
    phoneNumber: '',
    firstName: 'firstname',
    username: 'username',
    biography: 'bio',
    dob: DateTime.parse('0001-01-01 01:01:04Z'),
    gender: 'gender',
    favoriteSport: 'favoriteSport',
    clans: List.empty(),
    id: '',
    profilePictureUrl: 'https://jodilogik.com/wp-content/uploads/2016/05/people-1.png',
    profileBannerUrl: 'https://via.placeholder.com/150', // Placeholder URL
  );

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  void fetchProfileData() async {
    final User? firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null && firebaseUser.phoneNumber != null) {
      UserProfile? userProfile = await UserService().getUserByPhoneNumber(firebaseUser.phoneNumber!);
      if (userProfile != null) {
        if (mounted) {
          setState(() {
            displayName = userProfile.username;
            currentUserProfile = userProfile;
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            displayName = 'error fetching username';
            isLoading = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void editProfile() async {
    final User? firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null && firebaseUser.phoneNumber != null) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EditProfilePage(userProfile: currentUserProfile)),
      );

      // Check if the result indicates a need for refresh
      if (result == true) {
        fetchProfileData();
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        isLoading
            ? const Padding(
                padding: EdgeInsets.only(top: 200.0),
                child: Center(child: CircularProgressIndicator()),
              )
            : Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none, // Allows the profile image to overlap the banner
                    alignment: Alignment.bottomLeft,
                    children: <Widget>[
                      Container(
                        height: 200.0, // Banner height
                        decoration: BoxDecoration(
                          color: Colors.blue, // Placeholder color for the banner
                        ),
                        child: Stack(
                          children: [
                            Image.network(
                              currentUserProfile.profileBannerUrl!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                } else {
                                  return Center(child: CircularProgressIndicator());
                                }
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Center(child: Icon(Icons.error));
                              },
                            ),
                            if (isBannerLoading)
                              Center(child: CircularProgressIndicator()),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 36, // Horizontal position
                        bottom: -63, // Overlap amount (half of the profile image size)
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 45,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.white,
                                backgroundImage: NetworkImage(
                                  currentUserProfile.profilePictureUrl ?? 'https://jodilogik.com/wp-content/uploads/2016/05/people-1.png', // Placeholder for profile image
                                ),
                              ),
                            ),
                            const SizedBox(width: 25,),
                            Row(
                              children: [
                                const Icon(Icons.verified_outlined, size: 20,),
                                const SizedBox(width: 2,),
                                Text(displayName, style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Color.fromRGBO(45, 7, 7, 1),
                                ),),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 80),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 30, right: 30),
                        child: Container(
                          width: 350,
                          decoration: const BoxDecoration(
                            color: Color.fromRGBO(249, 217, 104, 1),
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(currentUserProfile.biography ?? 'bio'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 27),
                      Padding(
                        padding: const EdgeInsets.only(left: 50.0),
                        child: SizedBox(
                          height: 32,
                          child: Row(
                            children: [
                              ElevatedButton(
                                onPressed: editProfile,
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 244, 242, 242)),
                                ),
                                child: const Text(
                                  'Edit profile',
                                  style: TextStyle(color: Color.fromARGB(255, 74, 74, 74)),
                                ),
                              ),
                              const SizedBox(width: 20,),
                              ElevatedButton(
                                onPressed: editProfile,
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 244, 242, 242)),
                                ),
                                child: const Text(
                                  'Settings',
                                  style: TextStyle(color: Color.fromARGB(255, 74, 74, 74)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
      ],
    );
  }
}
