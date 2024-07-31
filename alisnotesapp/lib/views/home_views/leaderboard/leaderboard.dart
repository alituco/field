import 'package:flutter/material.dart';
import 'package:alisnotesapp/db/service_folder/clan_service.dart';
import '../../../db/models/clan_model.dart';

class ClanLeaderboard extends StatefulWidget {
  const ClanLeaderboard({super.key});

  @override
  State<ClanLeaderboard> createState() => _ClanLeaderboardState();
}

class _ClanLeaderboardState extends State<ClanLeaderboard> {
  final ClanService _clanService = ClanService();
  late Future<List<Clan>> _topClans;

  @override
  void initState() {
    super.initState();
    _topClans = _clanService.getTop10Clans(); // Assumes getTop10Clans returns Future<List<Clan>>
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 90.0, left: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Leaderboard', 
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20), // Provides consistent spacing
            Expanded(
              child: FutureBuilder<List<Clan>>(
                future: _topClans,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        Clan clan = snapshot.data![index];
                        return ListTile(
                          title: Text('${index + 1}: ${clan.clanName}'),
                        );
                      }
                    );
                  } else {
                    return const Text('No clans found.'); // Handle empty or null data
                  }
                }
              )
            ),
          ],
        ),
      ),
    );
  }
}
