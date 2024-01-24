import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:globe/admin/Books.dart';
import 'package:globe/admin/Reports.dart';
import 'package:globe/admin/Clients.dart';
import 'package:globe/admin/dashboard.dart';

class Sales extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      body: _buildBody(),
      currentIndex: 2,
      onTabTapped: (index) {
        _onTabTapped(context, index);
      },
      pageTitle: 'Sales Information',
      floatingButton: FloatingActionButton(
        onPressed: () {
          _showAddSalesDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    return Center(
      child: Text("Sales Screen Content"),
    );
  }

  void _onTabTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Dashboard()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Books()),
        );
        break;
      case 2:
      // Do nothing if already on this screen
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Clients()),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Reports()),
        );
        break;
    }
  }

  void _showAddSalesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddSalesDialog();
      },
    );
  }
}

class AddSalesDialog extends StatefulWidget {
  @override
  _AddSalesDialogState createState() => _AddSalesDialogState();
}

class _AddSalesDialogState extends State<AddSalesDialog> {
  String selectedBookName = ''; // Example variable for selected book name
  String selectedCategory = ''; // Example variable for selected category
  String selectedUser = ''; // Example variable for selected user
  int bookQuantity = 0; // Example variable for book quantity
  double bookPrice = 0.0; // Example variable for book price
  int numberOfBooksToSend = 0; // Example variable for number of books to send out
  DateTime selectedDate = DateTime.now(); // Example variable for selected date
  String bookImageUrl = ''; // Example variable for book image URL

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(
        child: Text("Sales Information"),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image holder from Firestore field bookImageUrl
            FutureBuilder<String>(
              future: _fetchBookImageUrl(selectedBookName),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text("Error loading image");
                } else {
                  bookImageUrl = snapshot.data!;
                  return Image.network(
                    bookImageUrl,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  );
                }
              },
            ),
            SizedBox(height: 16),
            // Spinner for users
            DropdownButton<String>(
              value: selectedUser,
              onChanged: (String? newValue) {
                setState(() {
                  selectedUser = newValue!;
                });
              },
              items: <String>['User1', 'User2', 'User3'] // Replace with actual user data
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            // Spinner for book categories
            DropdownButton<String>(
              value: selectedCategory,
              onChanged: (String? newValue) {
                setState(() {
                  selectedCategory = newValue!;
                  // Reset selectedBookName when the category changes
                  selectedBookName = '';
                });
              },
              items: <String>['Category1', 'Category2', 'Category3'] // Replace with actual category data
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            // Spinner for book names
            DropdownButton<String>(
              value: selectedBookName,
              onChanged: (String? newValue) {
                setState(() {
                  selectedBookName = newValue!;
                });
              },
              items: <String>['Book1', 'Book2', 'Book3'] // Replace with actual book name data based on selected category
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            // Text input for current quantity
            TextFormField(
              decoration: InputDecoration(labelText: 'Current Quantity'),
              initialValue: bookQuantity.toString(),
              readOnly: true,
            ),
            SizedBox(height: 16),
            // Text input for book price
            TextFormField(
              decoration: InputDecoration(labelText: 'Book Price'),
              initialValue: bookPrice.toString(),
              readOnly: true,
            ),
            SizedBox(height: 16),
            // Text input for the number of books to send out
            TextFormField(
              decoration: InputDecoration(labelText: 'Number of Books to Send Out'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  numberOfBooksToSend = int.parse(value);
                });
              },
            ),
            SizedBox(height: 16),
            // Date picker
            ElevatedButton(
              onPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2022),
                  lastDate: DateTime(2130),
                );
                if (pickedDate != null && pickedDate != selectedDate) {
                  setState(() {
                    selectedDate = pickedDate;
                  });
                }
              },
              child: Text('Select Date'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            // Validate and save data
            if (_validateData()) {
              // Add your logic to save data to Firestore
              Navigator.pop(context);
            } else {
              // Show an error message or handle validation errors
            }
          },
          child: Text('Add'),
        ),
      ],
    );
  }

  Future<String> _fetchBookImageUrl(String bookName) async {
    try {
      // Replace 'books' with the actual name of your Firestore collection
      DocumentSnapshot bookSnapshot = await _firestore.collection('books').doc(bookName).get();
      return bookSnapshot['bookImageUrl'];
    } catch (error) {
      print('Error fetching book image URL: $error');
      return ''; // Return an empty string or a default image URL in case of an error
    }
  }

  bool _validateData() {
    // Implement your validation logic here
    // Return true if all data is valid, otherwise return false
    return true;
  }
}
