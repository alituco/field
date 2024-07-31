import 'package:alisnotesapp/db/service_folder/event_service.dart';
import 'package:flutter/material.dart';
import '../../../../db/models/event_model.dart';

class CreateMatch extends StatefulWidget {
  final String clanId;
  final String clanName;

  const CreateMatch({Key? key, required this.clanId, required this.clanName}) : super(key: key);

  @override
  _CreateMatchState createState() => _CreateMatchState();
}

class _CreateMatchState extends State<CreateMatch> {
  List<String> fields = ['Manama', 'Isa Town', 'Saar', 'Sanad', 'Sanabis'];

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _notesController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedItem;

  final EventService _eventService = EventService();

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _selectLocation(String? selectedField) {
    setState(() {
      _selectedItem = selectedField;
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      DateTime eventDateTime;
      if (_selectedDate != null && _selectedTime != null) {
        eventDateTime = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        );
      } else {
        eventDateTime = DateTime.now();
      }

      final event = Event(
        id: '',
        clan1Id: widget.clanName,
        clan2Id: '',
        time: eventDateTime,
        location: _selectedItem ?? _notesController.text,
        isFilled: false, 
        winner: null,
      );

      _eventService.createEvent(event).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event created successfully')),
        );
        Navigator.pop(context);
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create event: $error')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a Match!'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Text('Clan: ${widget.clanName}'),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter location';
                  }
                  return null;
                },
              ),
              DropdownButton<String>(
                value: _selectedItem,
                hint: const Text('Select a field'),
                items: fields.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newVal) => _selectLocation(newVal),
              ),
              Row(
                children: <Widget>[
                  Text(
                    _selectedDate == null
                        ? 'No date selected!'
                        : 'Date: ${_selectedDate.toString()}',
                  ),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: const Text('Select date'),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Text(
                    _selectedTime == null
                        ? 'No time selected!'
                        : 'Time: ${_selectedTime!.format(context)}',
                  ),
                  TextButton(
                    onPressed: () => _selectTime(context),
                    child: const Text('Select time'),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Create Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
