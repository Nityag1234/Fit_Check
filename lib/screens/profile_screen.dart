// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({super.key});
//
//   Future<Map<String, dynamic>?> _getUserInfo() async {
//     User? user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
//       if (doc.exists) {
//         return doc.data() as Map<String, dynamic>?;
//       }
//     }
//     return null;
//   }
//
//   Future<void> _updateBirthdate(String birthdate) async {
//     User? user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
//         'birthdate': birthdate,
//       });
//     }
//   }
//
//   Future<void> _selectBirthdate(BuildContext context) async {
//     DateTime? selectedDate = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(1900),
//       lastDate: DateTime.now(),
//     );
//
//     if (selectedDate != null) {
//       String formattedDate = "${selectedDate.toLocal()}".split(' ')[0]; // Format as YYYY-MM-DD
//       await _updateBirthdate(formattedDate);
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text('Birthday updated to $formattedDate'),
//       ));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     User? user = FirebaseAuth.instance.currentUser;
//
//     if (user == null) {
//       return const Center(child: Text('No user is logged in'));
//     }
//
//     return FutureBuilder<Map<String, dynamic>?>(
//       future: _getUserInfo(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         } else if (snapshot.hasError) {
//           return const Center(child: Text('Error fetching user info'));
//         } else if (!snapshot.hasData) {
//           return const Center(child: Text('User info not found'));
//         }
//
//         Map<String, dynamic>? userInfo = snapshot.data;
//
//         return Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               if (user.photoURL != null)
//                 CircleAvatar(
//                   backgroundImage: NetworkImage(user.photoURL!),
//                   radius: 50,
//                 ),
//               const SizedBox(height: 20),
//               Text('Name: ${user.displayName}', style: const TextStyle(fontSize: 18)),
//               const SizedBox(height: 10),
//               Text('Email: ${user.email}', style: const TextStyle(fontSize: 16)),
//               const SizedBox(height: 10),
//               if (userInfo != null && userInfo['birthdate'] != null) ...[
//                 Text('Birthdate: ${userInfo['birthdate']}', style: const TextStyle(fontSize: 16)),
//               ] else ...[
//                 Text('Birthdate not set', style: const TextStyle(fontSize: 16)),
//                 ElevatedButton(
//                   onPressed: () => _selectBirthdate(context),
//                   child: const Text('Set Birthday'),
//                 ),
//               ],
//             ],
//           ),
//         );
//       },
//     );
//   }
// }









import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<Map<String, dynamic>?> _getUserInfo() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
    }
    return null;
  }

  Future<void> _updateField(String field, dynamic value) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        field: value,
      });
    }
  }

  Future<void> _selectBirthdate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      String formattedDate = "${selectedDate.toLocal()}".split(' ')[0]; // Format as YYYY-MM-DD
      await _updateField('birthdate', formattedDate);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Birthday updated to $formattedDate'),
      ));
    }
  }

  Future<void> _setWeight(BuildContext context) async {
    final TextEditingController weightController = TextEditingController();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Weight'),
          content: TextField(
            controller: weightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: "Weight (kg)"),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (weightController.text.isNotEmpty) {
                  await _updateField('weight', double.tryParse(weightController.text));
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Weight updated to ${weightController.text} kg'),
                  ));
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _setHeight(BuildContext context) async {
    final TextEditingController heightController = TextEditingController();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Height'),
          content: TextField(
            controller: heightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: "Height (cm)"),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (heightController.text.isNotEmpty) {
                  await _updateField('height', double.tryParse(heightController.text));
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Height updated to ${heightController.text} cm'),
                  ));
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('No user is logged in'));
    }

    return FutureBuilder<Map<String, dynamic>?>(
      future: _getUserInfo(), // This is the missing 'future' argument
      builder: (context, snapshot) { // This is the missing 'builder' argument
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error fetching user info'));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('User info not found'));
        }

        Map<String, dynamic>? userInfo = snapshot.data;

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (user.photoURL != null)
                CircleAvatar(
                  backgroundImage: NetworkImage(user.photoURL!),
                  radius: 50,
                ),
              const SizedBox(height: 20),
              Text('Name: ${user.displayName}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Text('Email: ${user.email}', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              if (userInfo != null && userInfo['birthdate'] != null) ...[
                Text('Birthdate: ${userInfo['birthdate']}', style: const TextStyle(fontSize: 16)),
              ] else ...[
                Text('Birthdate not set', style: const TextStyle(fontSize: 16)),
                ElevatedButton(
                  onPressed: () => _selectBirthdate(context),
                  child: const Text('Set Birthday'),
                ),
              ],
              const SizedBox(height: 10),
              if (userInfo != null && userInfo['weight'] != null) ...[
                Text('Weight: ${userInfo['weight']} kg', style: const TextStyle(fontSize: 16)),
              ] else ...[
                Text('Weight not set', style: const TextStyle(fontSize: 16)),
                ElevatedButton(
                  onPressed: () => _setWeight(context),
                  child: const Text('Set Weight'),
                ),
              ],
              const SizedBox(height: 10),
              if (userInfo != null && userInfo['height'] != null) ...[
                Text('Height: ${userInfo['height']} cm', style: const TextStyle(fontSize: 16)),
              ] else ...[
                Text('Height not set', style: const TextStyle(fontSize: 16)),
                ElevatedButton(
                  onPressed: () => _setHeight(context),
                  child: const Text('Set Height'),
                ),
              ],
            ],
          ),
        );
      },
    );

  }
}
