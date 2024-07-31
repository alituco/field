import 'package:alisnotesapp/db/models/clan_model.dart';
import 'package:alisnotesapp/db/models/event_model.dart';
import 'package:alisnotesapp/db/service_folder/clan_service.dart';
import 'package:alisnotesapp/db/service_folder/event_service.dart';
import 'package:alisnotesapp/views/home_views/Clans/view_clan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';  // Make sure you have the intl package added to your pubspec.yaml

class ClanMatches extends StatefulWidget {
  final Clan clan;

  const ClanMatches({super.key, required this.clan});

  @override
  State<ClanMatches> createState() => _ClanMatchesState();
}

class _ClanMatchesState extends State<ClanMatches> {
  final EventService _eventService = EventService();
  final ClanService _clanService = ClanService();
  Future<List<Event>>? events;

  @override
  void initState() {
    super.initState();
    events = fetchClanEvents();
  }

  Future<List<Event>> fetchClanEvents() async {
    try {
      return await _eventService.getEvents(widget.clan);
    } catch (err) {
      print('Error fetching clan events: $err');
      return [];
    }
  }

  String getOpponentClanName(Event event) {
    if (event.clan1Id == widget.clan.clanName) {
      return event.clan2Id ?? 'Opponent Pending';
    } else {
      return event.clan1Id ?? 'Error fetching clan name';
    }
  }

  void navigateToClanPage(Event event) async{
    Clan clan = await _clanService.getClanByName(getOpponentClanName(event));
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => ViewClan(clan: clan))
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clan Matches', style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 30
        ),),
      ),
      body: FutureBuilder<List<Event>>(
        future: events,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error fetching clan matches'));
          } else if (snapshot.hasData) {
            List<Event> upcomingEvents = [];
            List<Event> pastEvents = [];

            DateTime now = DateTime.now();

            for (var event in snapshot.data!) {
              if (event.time.isAfter(now)) {
                upcomingEvents.add(event);
              } else {
                pastEvents.add(event);
              }
            }

            // Sort events by time
            upcomingEvents.sort((a, b) => a.time.compareTo(b.time));
            pastEvents.sort((a, b) => b.time.compareTo(a.time));

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (upcomingEvents.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.only(left: 25.0, top: 32, bottom: 6),
                    child: Text(
                      'Upcoming Match',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 40, right: 40, top: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all( color: const Color.fromARGB(31, 46, 2, 2))
                        //color: const Color.fromRGBO(249, 237, 237, 0.698),
                      ),
                      child: SizedBox(
                        height: 200,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: SizedBox(
                                width: 170,
                                child: Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () => navigateToClanPage(upcomingEvents[0]),
                                      child: const CircleAvatar(
                                        radius: 50,
                                        backgroundColor: Color.fromRGBO(255, 0, 0, 1),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(maxWidth: 200),
                                      child: Text(
                                        getOpponentClanName(upcomingEvents[0]),
                                        softWrap: true,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: -1,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            //const SizedBox(width: 5),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        child: Text(
                                          upcomingEvents[0].location ?? 'Error',
                                          softWrap: true,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        child: Text(
                                          DateFormat('yyyy-MM-dd – kk:mm').format(upcomingEvents[0].time) ?? 'Error',
                                          softWrap: true,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 3,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  const Row(
                                    children: [
                                      Icon(Icons.star_border_outlined),
                                      SizedBox(width: 5),
                                      Expanded(
                                        child: Text(
                                          'Contender',
                                          softWrap: true,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                if (pastEvents.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Past Events',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: pastEvents.length,
                      itemBuilder: (context, index) {
                        Event event = pastEvents[index];
                        return EventCard(event: event);
                      },
                    ),
                  ),
                ],
              ],
            );
          } else {
            return const Center(child: Text('No matches found.'));
          }
        },
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.clan1Id,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: 4),
            Text(
              event.clan2Id ?? '',
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: 4),
            Text(
              'Location: ${event.location}',
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: 4),
            Text(
              'Time: ${DateFormat('yyyy-MM-dd – kk:mm').format(event.time)}',
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: 4),
            Text(
              'Filled: ${event.isFilled ? "Yes" : "No"}',
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: 4),
            Text(
              'Winner: ${event.winner ?? "TBD"}',
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}
