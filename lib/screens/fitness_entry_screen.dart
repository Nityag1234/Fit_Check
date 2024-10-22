import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:intl/intl.dart';

class FitnessEntryScreen extends StatefulWidget {
  @override
  _FitnessEntryScreenState createState() => _FitnessEntryScreenState();
}

class _FitnessEntryScreenState extends State<FitnessEntryScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedMood = 'Endurance'; // Default mood
  final List<String> _moods = ['Endurance', 'Flexibility Training', 'Strength Training', 'Anerobic Exercise']; // Mood options

  User? user = FirebaseAuth.instance.currentUser; // Get the current user

  // Format the date to a Firestore-friendly string format (yyyy-MM-dd)
  String _formatDateForFirestore(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Function to fetch Fitness entry from Firestore based on user ID and selected date
  Future<void> _fetchFitnessEntry() async {
    if (user == null) return; // Make sure the user is logged in

    final formattedDate = _formatDateForFirestore(_selectedDate); // Format the date

    final FitnessEntry = await FirebaseFirestore.instance
        .collection('Fitness_entries')
        .doc('${user!.uid}_$formattedDate') // Use formatted date and userId in the document ID
        .get();

    if (FitnessEntry.exists) {
      // If entry exists, populate the text controllers with the existing data
      _titleController.text = FitnessEntry['title'];
      _contentController.text = FitnessEntry['content'];
      _selectedMood = FitnessEntry['mood']; // Set selected mood from existing entry
    }
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) return;
      setState(() {
        _selectedDate = pickedDate;
        _fetchFitnessEntry(); // Fetch Fitness entry for the newly selected date
      });
    });
  }

  // Function to save or update the Fitness entry in Firestore
  Future<void> _saveEntry() async {
    if (user == null) return; // Make sure the user is logged in

    final formattedDate = _formatDateForFirestore(_selectedDate); // Format the date
    await FirebaseFirestore.instance.collection('Fitness_entries').doc('${user!.uid}_$formattedDate').set({
      'title': _titleController.text,
      'content': _contentController.text,
      'mood': _selectedMood,
      'date': _selectedDate,
      'userId': user!.uid, // Save the userId
    });

    // Show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Fitness entry saved!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Fitness Entry'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _contentController,
              maxLines: 10,
              decoration: InputDecoration(
                labelText: 'Content',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: <Widget>[
                Text(
                  'Date: ${_selectedDate.toLocal()}'.split(' ')[0],
                ),
                TextButton(
                  onPressed: _presentDatePicker,
                  child: Text('Select Date'),
                ),
              ],
            ),
            SizedBox(height: 10),
            DropdownButton<String>(
              value: _selectedMood,
              items: _moods.map((String mood) {
                return DropdownMenuItem<String>(
                  value: mood,
                  child: Text(mood.capitalize()), // Capitalizing mood strings
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedMood = newValue!;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveEntry,
              child: Text('Save Entry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple, // Using preferred color
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension StringCasingExtension on String {
  String capitalize() {
    return this[0].toUpperCase() + this.substring(1);
  }
}
