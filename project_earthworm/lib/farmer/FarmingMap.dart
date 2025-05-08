import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fetch User Name',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: UserNameFetcher(),
    );
  }
}

class UserNameFetcher extends StatefulWidget {
  @override
  _UserNameFetcherState createState() => _UserNameFetcherState();
}

class _UserNameFetcherState extends State<UserNameFetcher> {
  final TextEditingController _uidController = TextEditingController();
  String? _userName;

  Future<String?> getUserName(String uid) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    try {
      DocumentSnapshot documentSnapshot = await users.doc(uid).get();

      if (documentSnapshot.exists) {
        var data = documentSnapshot.data() as Map<String, dynamic>;
        print("User found: ${data['name']}"); // Debugging line
        return data['name'];
      } else {
        print("No user found with UID: $uid"); // Debugging line
        return null;
      }
    } catch (e) {
      print("Error fetching user: $e"); // Debugging line
      return null;
    }
  }

  Future<void> _fetchUserName() async {
    String uid = _uidController.text.trim();
    String? name = await getUserName(uid);
    setState(() {
      _userName = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fetch User Name'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _uidController,
              decoration: InputDecoration(
                labelText: 'Enter User UID',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchUserName,
              child: Text('Fetch Name'),
            ),
            SizedBox(height: 20),
            if (_userName != null)
              Text('User Name: $_userName')
            else
              Text('No name found'),
          ],
        ),
      ),
    );
  }
}