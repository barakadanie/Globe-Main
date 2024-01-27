import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Reports extends StatefulWidget {
  @override
  _ReportsState createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  String selectedSalesperson = "";
  String selectedMonth = "";
  String selectedFullName = "";

  // Assuming you have a Firestore collection named 'mysales'
  CollectionReference mySalesCollection = FirebaseFirestore.instance.collection('Mysales');

  // Assuming you have a Firestore collection named 'users'
  CollectionReference usersCollection = FirebaseFirestore.instance.collection('Users');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sales Data'),
      ),
      body: Column(
        children: [
          // Spinner for Salesperson
          StreamBuilder<QuerySnapshot>(
            stream: usersCollection.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }

              var userNames = snapshot.data!.docs
                  .map<String>((DocumentSnapshot document) {
                Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                return data['fullName'].toString();
              })
                  .toSet()
                  .toList();

              return DropdownButton<String>(
                value: selectedFullName,
                hint: Text('Select Salesperson Name'),
                onChanged: (String? value) {
                  setState(() {
                    selectedFullName = value!;
                  });
                },
                items: userNames
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                })
                    .toList(),
              );
            },
          ),

          // Spinner for Months
          DropdownButton<String>(
            value: selectedMonth,
            hint: Text('Select Month'),
            onChanged: (String? value) {
              setState(() {
                selectedMonth = value!;
              });
            },
            items: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            })
                .toList(),
          ),

          // Display data in DataTable
          StreamBuilder<QuerySnapshot>(
            stream: usersCollection.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }

              var userNames = snapshot.data!.docs
                  .map<String>((DocumentSnapshot document) {
                Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                return data['fullName'].toString();
              })
                  .toList();

              return DropdownButton<int>(
                value: userNames.indexOf(selectedFullName), // Use index instead of the actual value
                hint: Text('Select Salesperson Name'),
                onChanged: (int? index) {
                  setState(() {
                    selectedFullName = userNames[index!];
                  });
                },
                items: userNames
                    .map<DropdownMenuItem<int>>((String value) {
                  return DropdownMenuItem<int>(
                    value: userNames.indexOf(value),
                    child: Text(value),
                  );
                })
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
