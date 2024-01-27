import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileAdmin extends StatefulWidget {
  static const String path = "lib/src/pages/profile/profile12.dart";

  const ProfileAdmin({Key? key}) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<ProfileAdmin> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final bool _isOpen = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController roleController = TextEditingController();
  @override
  void initState() {
    super.initState();
    // Fetch user data when the page is initialized
    _fetchUserData();
  }
  Future<void> _fetchUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // User is logged in, fetch data from Firestore
        DocumentSnapshot<Map<String, dynamic>?> snapshot =
        await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();

        // Update the UI with the fetched data
        setState(() {
          nameController.text = snapshot['fullName'] ?? '';
          emailController.text = snapshot['email'] ?? '';
          phoneController.text = snapshot['phoneNumber'] ?? '';
          roleController.text = snapshot['role'] ?? '';
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          FractionallySizedBox(
            alignment: Alignment.topCenter,
            heightFactor: 0.7,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                      'https://firebasestorage.googleapis.com/v0/b/dl-flutter-ui-challenges.appspot.com/o/img%2F1.jpg?alt=media'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          FractionallySizedBox(
            alignment: Alignment.bottomCenter,
            heightFactor: 0.5,
            child: Container(
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(50))),
              child: panelBody(),
            ),
          ),
        ],
      ),
    );
  }

  SingleChildScrollView panelBody() {
    double hPadding = 40;
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: hPadding),
            height: MediaQuery
                .of(context)
                .size
                .height * 0.35,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _titleSection(),
                _actionSection(hPadding: hPadding),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Row _actionSection({double? hPadding}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Visibility(
          visible: !_isOpen,
          child: Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(labelText: 'Phone'),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.blue),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () {
                    // Handle update profile logic using the provided controllers
                    print('Update Profile tapped');
                    print('Name: ${nameController.text}');
                    print('Email: ${emailController.text}');
                    print('Phone: ${phoneController.text}');
                    print('Role: ${roleController.text}');
                  },
                  child: const Text(
                    'UPDATE PROFILE',
                    style: TextStyle(
                      fontFamily: 'NimbusSanL',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Visibility(
          visible: !_isOpen,
          child: const SizedBox(
            width: 16,
          ),
        ),
        Expanded(
          child: Container(
            alignment: Alignment.center,
            child: SizedBox(
              width: _isOpen
                  ? (MediaQuery
                  .of(context)
                  .size
                  .width - (2 * hPadding!)) / 1.6
                  : double.infinity,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () => print('Message tapped'),
                child: const Text(
                  'UPLOAD PROFILE',
                  style: TextStyle(
                    fontFamily: 'NimbusSanL',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Column _titleSection() {
    return Column(
      children: <Widget>[
        StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(_auth.currentUser?.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(); // Loading indicator while data is being fetched
            }

            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (!snapshot.hasData || snapshot.data == null || snapshot.data!.data() == null) {
              return Text('No user data available'); // Display a message when no user data is found
            }

            var userData = snapshot.data!.data() as Map<String, dynamic>;

            return Column(
              children: <Widget>[
                Text(
                  userData['fullName'] ?? '',
                  style: TextStyle(
                    fontFamily: 'NimbusSanL',
                    fontWeight: FontWeight.w700,
                    fontSize: 30,
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  userData['role'] ?? '',
                  style: TextStyle(
                    fontFamily: 'NimbusSanL',
                    fontStyle: FontStyle.italic,
                    fontSize: 16,
                  ),
                ),
              ],
            );
          },
        ),


      ],
    );
  }
}