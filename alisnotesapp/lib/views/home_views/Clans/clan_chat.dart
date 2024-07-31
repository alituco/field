import 'package:alisnotesapp/db/models/user_model.dart';
import 'package:alisnotesapp/db/service_folder/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../db/models/clan_model.dart';

class ClanChat extends StatefulWidget {
  final Clan clan;
  ClanChat({Key? key, required this.clan}) : super(key: key);

  @override
  State<ClanChat> createState() => _ClanChatState();
}

class _ClanChatState extends State<ClanChat> {
  UserService userService = UserService();
  final User? firebaseUser = FirebaseAuth.instance.currentUser;
  final TextEditingController _messageController = TextEditingController();
  UserProfile? userProfile;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    if (firebaseUser?.phoneNumber != null) {
      try {
        userProfile = await userService.getUserByPhoneNumber(firebaseUser!.phoneNumber!);
        setState(() {});  // Update the UI after fetching the user profile
      } catch (err) {
        print('Error fetching user profile: $err');
      }
    } else {
      print('No phone number available for the current user.');
    }
  }

  Future<String> fetchMessagerUsername(String phoneNumber) async {
    try {
      UserProfile? messager = await userService.getUserByPhoneNumber(phoneNumber);
      return messager?.username ?? "Unknown user";  // Provide a default username if null
    } catch (err) {
      print('Error fetching messager profile: $err');
      return 'Error fetching username';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.clan.clanName} Chat"),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('clans')
                  .doc(widget.clan.clanName)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                var documents = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    var message = documents[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(message['text']),
                      subtitle: FutureBuilder<String>(
                        future: fetchMessagerUsername(message['senderId']),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Text("Loading...");
                          } else if (snapshot.hasError) {
                            return Text("Failed to load");
                          } else {
                            return Text(snapshot.data ?? "Unknown user");
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      labelText: 'Send a message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      FirebaseFirestore.instance.collection('clans').doc(widget.clan.clanName)
        .collection('messages').add({
          'text': _messageController.text,
          'senderId': userProfile?.phoneNumber ?? 'Anonymous',  // Use a fallback if phoneNumber is null
          'timestamp': FieldValue.serverTimestamp(),
        });
      _messageController.clear();
    }
  }
}
