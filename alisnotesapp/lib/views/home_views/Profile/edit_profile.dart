import 'package:alisnotesapp/views/user_registration.dart';
import 'package:flutter/material.dart';
import '../../../db/models/user_model.dart';
import '../../../db/service_folder/user_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfilePage extends StatefulWidget {
  final UserProfile userProfile;

  const EditProfilePage({Key? key, required this.userProfile}) : super(key: key);
  
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _biographyController = TextEditingController();
  late UserService _userService;
  bool isLoading = false;
  File? _profileImage;
  File? _bannerImage;

  @override
  void initState() {
    super.initState();
    _userService = UserService();
    _usernameController.text = widget.userProfile.username;
    _biographyController.text = widget.userProfile.biography ?? '';
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path); // 'File' class is used here
      });
    }
  }

Future<void> pickBannerImage() async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  if (pickedFile != null) {
    setState(() {
      _bannerImage = File(pickedFile.path);  // 'File' class is used here
    });
  }
}

Future<void> deleteUser() async {
  print('Deletion started');
  await _userService.deleteUser(widget.userProfile.phoneNumber);
  print("User deleted.");
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: isLoading ? Center(child: CircularProgressIndicator()): 
          Column(
            children: [
              if (_profileImage != null)
                Image.file(_profileImage!),
              ElevatedButton(
                onPressed: pickImage,
                child: const Text('Change Profile Picture'),
              ),
              if (_bannerImage != null)
                Image.file(_bannerImage!),
              ElevatedButton(
                onPressed: pickBannerImage,
                child: const Text('Change Banner Image'),
              ),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: _biographyController,
                decoration: const InputDecoration(labelText: 'Bio'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Call a method to update the profile
                  updateProfile();
                },
                child: const Text('Save Changes'),
              ),
              ElevatedButton(onPressed: () {
                deleteUser();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const UserRegistration())
                  );
              }, child: const Text('DELETE YOUR PROFILE.'))
            ],
          ),
        ),
      ),
    );
  }

void updateProfile() async {
  setState(() {
    isLoading = true;
  });
  if (_usernameController.text.isNotEmpty) {
    bool takenUsername = await _userService.isUsernameTaken(_usernameController.text);
    if (takenUsername && _usernameController.text != widget.userProfile.username) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username is already taken.'))
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    String? profileImageUrl;
    String? bannerImageUrl;

    // Upload profile image if it's new
    if (_profileImage != null) {
      profileImageUrl = await _userService.uploadProfilePicture(widget.userProfile.phoneNumber, _profileImage!);
      if (profileImageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload profile image.'))
        );
        setState(() {
          isLoading = false;
        });
        return;
      }
    }

    // Upload banner image if it's new
    if (_bannerImage != null) {
      bannerImageUrl = await _userService.uploadBannerPicture(widget.userProfile.phoneNumber, _bannerImage!);
      if (bannerImageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload banner image.'))
        );
        setState(() {
          isLoading = false;
        });
        return;
      }
    }

    // Update user details
    Map<String, dynamic> updateData = {
      'username': _usernameController.text,
      'biography': _biographyController.text,
    };
    if (profileImageUrl != null) updateData['profilePictureUrl'] = profileImageUrl;
    if (bannerImageUrl != null) updateData['profileBannerUrl'] = bannerImageUrl;

    _userService.updateUser(widget.userProfile.phoneNumber, updateData).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!'))
      );
      Navigator.pop(context, true);  // Ensuring refresh when profile info changes
    }).catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $err'))
      );
    });
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please make sure all fields have content'))
    );
  }
}

}
