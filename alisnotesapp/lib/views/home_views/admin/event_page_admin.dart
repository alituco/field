import 'package:alisnotesapp/db/service_folder/event_service.dart';
import 'package:flutter/material.dart';
import '../../../db/models/event_model.dart';

class EventPageAdmin extends StatefulWidget {
  final Event event;
  const EventPageAdmin({super.key, required this.event});

  @override
  State<EventPageAdmin> createState() => _EventPageAdminState();
}

class _EventPageAdminState extends State<EventPageAdmin> {
  EventService eventService = EventService();
  String _selectedWinner = 'Draw';
  List<String> teams = ['Draw'];

  @override
  void initState() {
    super.initState();
    teams.add(widget.event.clan1Id);
    teams.add(widget.event.clan2Id ?? 'Searching for opponent.');
  }

  Future<void> saveWinner(String winnerClanName) async {
    await eventService.updateWinner(widget.event, winnerClanName);
    print('Update winner in event db done.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.event.clan1Id} vs ${widget.event.clan2Id ?? "Unknown"}')),
      body: Center(
        child: Column(
          children: [
            Text(widget.event.time.toString()),
            Text('Is event filled? ${widget.event.isFilled.toString()}'),
            Text('Location: ${widget.event.location}'),
            const SizedBox(height: 40),
            const Text('Select which team won and save:', style: TextStyle(fontSize: 25)),
            Row(
              children: [
                DropdownButton<String>(
                  value: _selectedWinner,
                  items: teams.map((String team) {
                    return DropdownMenuItem<String>(
                      value: team,
                      child: Text(team)
                    );
                  }).toList(),
                  onChanged: (String? newTeam) {
                    if (newTeam != null) {
                      setState(() {
                        _selectedWinner = newTeam;
                      });
                    }
                  },
                ),
                ElevatedButton(
                  onPressed: () => saveWinner(_selectedWinner),
                  child: const Text('Update Winner')
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
