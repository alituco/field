import 'package:alisnotesapp/db/models/user_model.dart';
import 'package:flutter/material.dart';

class ViewProfile extends StatefulWidget {
  final UserProfile userProfile;

  const ViewProfile({super.key, required this.userProfile});

  @override
  State<ViewProfile> createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
                      widget.userProfile.profileBannerUrl ?? 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRIaBQyrvtJx-gCyXl2mXQwsK8P2KWJ_ycq8A&s',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        } else {
                          return const Center(child: CircularProgressIndicator());
                        }
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(child: Icon(Icons.error));
                      },
                    ),
                    Positioned(
                      top: 16,
                      left: 16,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
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
                          widget.userProfile.profilePictureUrl ?? 'https://jodilogik.com/wp-content/uploads/2016/05/people-1.png', // Placeholder for profile image
                        ),
                      ),
                    ),
                    const SizedBox(width: 25,),
                    Row(
                      children: [
                        const Icon(Icons.verified_outlined, size: 20,),
                        const SizedBox(width: 2,),
                        Text(widget.userProfile.username, style: const TextStyle(
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
                    child: Text(widget.userProfile.biography ?? 'bio'),
                  ),
                ),
              ),
              const SizedBox(height: 27),
              Padding(
                padding: const EdgeInsets.only(left: 50.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.date_range, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          'DOB: ${widget.userProfile.dob.toLocal().toIso8601String().substring(0, 10)}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.person, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          'Gender: ${widget.userProfile.gender}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.sports_soccer, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          'Favorite Sport: ${widget.userProfile.favoriteSport}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
