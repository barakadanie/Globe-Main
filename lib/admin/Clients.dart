import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:globe/admin/Books.dart';
import 'package:globe/admin/Reports.dart';
import 'package:globe/admin/Sales.dart';
import 'package:globe/admin/dashboard.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Clients extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      body: _buildBody(),
      currentIndex: 3, // Index for Clients in the bottom navigation bar
      onTabTapped: (index) => _onTabTapped(context, index),
      floatingButton: _buildSpeedDial(context),
      pageTitle: 'Clients Information',
    );
  }

  Widget _buildBody() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Clients').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error loading data');
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text('No clients available');
        } else {
          List<DataColumn> columns = [
            DataColumn(label: Text('Client Name', style: TextStyle(color: Colors.blue))),
            DataColumn(label: Text('Phone Number', style: TextStyle(color: Colors.blue))),
            DataColumn(label: Text('Salesperson', style: TextStyle(color: Colors.blue))),
          ];

          List<DataRow> rows = snapshot.data!.docs.map((document) {
            var clientName = document['Client name'];
            var phoneNumber = document['Client contact'];
            var salesperson = document['Salesperson'];

            return DataRow(
              cells: [
                DataCell(Text(clientName)),
                DataCell(Text(phoneNumber)),
                DataCell(Text(salesperson)),
              ],
              onSelectChanged: (selected) {
                if (selected != null && selected) {
                  _showContactOptionsDialog(context, clientName, phoneNumber);
                }
              },
            );
          }).toList();

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: columns,
              rows: rows,
              showCheckboxColumn: false,
            ),
          );
        }
      },
    );
  }

  void _showContactOptionsDialog(BuildContext context, String clientName, String phoneNumber) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Contact Options for $clientName'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildOptionTile('Call', Icons.phone, () {
                _launchPhoneDial(phoneNumber);
                Navigator.of(context).pop();
              }),
              _buildOptionTile('SMS', Icons.message, () {
                _launchSMS(phoneNumber, clientName);
                Navigator.of(context).pop();
              }),
              _buildOptionTile('WhatsApp', Icons.whatshot, () {
                _launchWhatsApp(phoneNumber, clientName);
                Navigator.of(context).pop();
              }),
            ],
          ),
        );
      },
    );
  }

  ListTile _buildOptionTile(String title, IconData icon, void Function()? onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }

  void _launchPhoneDial(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // Handle error
      print('Could not launch $url');
    }
  }

  void _launchSMS(String phoneNumber, String clientName) async {
    final url = 'sms:$phoneNumber?body=Hello $clientName!';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // Handle error
      print('Could not launch $url');
    }
  }

  void _launchWhatsApp(String phoneNumber, String clientName) async {
    final url = 'https://wa.me/$phoneNumber?text=Hello%20$clientName!';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // Handle error
      print('Could not launch $url');
    }
  }
}
void _showAddClientDialog(BuildContext context) {
  TextEditingController clientNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Add Client'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: clientNameController,
              decoration: InputDecoration(labelText: 'Client Name'),
            ),
            TextField(
              controller: phoneNumberController,
              decoration: InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _addClientToFirestore(clientNameController.text, phoneNumberController.text, context);
            },
            child: Text('Add Client'),
          ),
        ],
      );
    },
  );
}
void _addClientToFirestore(String clientName, String phoneNumber, BuildContext context) {
  // Get the email of the current user
  String? userEmail = FirebaseAuth.instance.currentUser?.email;

  // Check if the user is logged in
  if (userEmail != null) {
    // Reference to the "Users" collection
    CollectionReference usersCollection = FirebaseFirestore.instance.collection('Users');

    // Query to find the user document by email
    usersCollection.where('email', isEqualTo: userEmail).get().then((userQuerySnapshot) {
      if (userQuerySnapshot.size == 1) {
        // If a user document with the matching email is found, get the full name
        String salesperson = userQuerySnapshot.docs.first['fullName'] ?? 'Unknown Salesperson';

       // print('Found user document. Salesperson: $salesperson');

        // Add the client to the "Clients" collection
        FirebaseFirestore.instance.collection('Clients').add({
          'Client name': clientName,
          'Client contact': phoneNumber,
          'Salesperson': salesperson,
        }).then((value) {
          print('Client added to Firestore');
          Navigator.of(context).pop(); // Close the dialog
        }).catchError((error) {
          print('Error adding client to Firestore: $error');
        });
      } else {
        print('User document not found or multiple documents with the same email');
        userQuerySnapshot.docs.forEach((doc) {
          print('Document data: ${doc.data()}');
        });
      }
    }).catchError((error) {
      print('Error fetching user information: $error');
    });
  } else {
    print('User not logged in');
  }
}
SpeedDial _buildSpeedDial(BuildContext context) {
  return SpeedDial(
    icon: Icons.add,
    activeIcon: Icons.remove,
    buttonSize: Size(56.0, 56.0),
    visible: true,
    closeManually: false,
    renderOverlay: false,
    curve: Curves.bounceIn,
    children: [
      SpeedDialChild(
        child: Icon(Icons.add),
        label: 'Add Client',
        onTap: () {
          _showAddClientDialog(context);
        },
      ),
      SpeedDialChild(
        child: Icon(Icons.auto_graph_outlined),
        label: 'Clients Statistics',
        onTap: () {
          // Add the functionality for searching clients here
        },
      ),
    ],
  );
}
void _onTabTapped(BuildContext context, int index) {
  switch (index) {
    case 0:
    // Navigate to HomeScreen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Dashboard()),
      );
      break;
    case 1:
    // Do nothing if already on this
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Books()),
      );
      break;
    case 2:
    // Navigate to SalesScreen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Sales()),
      );
      break;
    case 3:
    // Navigate to ClientsScreen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Clients()),
      );
      break;
    case 4:
    // Navigate to ReportsScreen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Reports()),
      );
      break;
  }
}


