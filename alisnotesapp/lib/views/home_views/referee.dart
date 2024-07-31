import 'package:alisnotesapp/db/service_folder/event_service.dart';
import 'package:alisnotesapp/views/home_views/admin/event_page_admin.dart';
import 'package:flutter/material.dart';

import '../../db/models/event_model.dart';

class RefereeMainScreen extends StatefulWidget {
  const RefereeMainScreen({super.key});

  @override
  State<RefereeMainScreen> createState() => _RefereeMainScreenState();
}

class _RefereeMainScreenState extends State<RefereeMainScreen> {

  EventService eventService = EventService();
  late Future<List<Event>> _eventsFuture;
    @override
    void initState() {
      super.initState();
      _eventsFuture = getAllEvents();
    }

  Future<List<Event>> getAllEvents() async {
    List<Event> updatedEvents = [];
    try {
      updatedEvents = await eventService.getAllEvents();
      return updatedEvents;
    } catch (err){
      print('error, gang: $err');
    }
    return updatedEvents;
  }

  void navigateToEventPageAdmin(Event event){
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) {
        return EventPageAdmin(event: event);
      })
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(60.0),
        child: Column(
          children: [
            const Text('Pick the game managed.'),
            FutureBuilder(
              future: _eventsFuture, 
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting){
                  return CircularProgressIndicator();
                } else if (snapshot.hasError){
                  return Text('ERROR GANG. ${snapshot.error}');
                } else if (snapshot.hasData){
                  List<Event> events = snapshot.data!;
                  return SizedBox(
                    height: 300,
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: events.length,
                      itemBuilder: (context, index){
                        Event event = events[index];
                        return GestureDetector(
                          onTap: () {
                            navigateToEventPageAdmin(event);
                          },
                          child: ListTile(
                            title: Text(event.location),
                          ),
                        );
                      }),
                  );
                    
                } else {
                  return const Text('Something went very wrong good luck.');
                }
              })
          ],
        ),
      ),
    );
  }
}