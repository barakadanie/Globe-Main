import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
          _showOptionsBottomSheet(context);
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

  void _showOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.shopping_basket),
                title: Text('Add Sales'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddSalesDialog(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.pending_actions),
                title: Text('Pending Sales'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.checklist),
                title: Text('Confirmed Sales'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddSalesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _AddSalesDialog(),
    );
  }

}

class _AddSalesDialog extends StatefulWidget {
  @override
  _AddSalesDialogState createState() => _AddSalesDialogState();
}

class _AddSalesDialogState extends State<_AddSalesDialog> {
  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sales Information',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),

            _buildSpinner(
              label: 'Select User',
              items: ['User1', 'User2', 'User3'],
              onChanged: (value) {
                // Handle user selection
              },
            ),
            _buildCategorySpinner(
              label: 'Select Category',
              onChanged: (value) {
                setState(() {
                  selectedCategory = value; // This line updates the selectedCategory variable
                });
              },
            ),
            _buildBookNameSpinner(
              label: 'Select Book Name',
              onChanged: (value) {
                // Handle book name selection
              },
            ),


            _buildTextInput(
              label: 'Quantity',
              onChanged: (value) {
                // Handle quantity input
              },
            ),
            _buildUneditableTextInput(
              label: 'Book Price',
              value: '\$29.99',
            ),
            _buildUneditableTextInput(
              label: 'Current Stock',
              value: '100',
            ),
            _buildDatePicker(),
            ElevatedButton(
              onPressed: () {
                // Validate and save data
                // ...

                // Close the dialog
                Navigator.pop(context);
              },
              child: Text('Add Sales'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpinner({required String label, required List<String> items, required void Function(String?) onChanged}) {
    return FutureBuilder<List<String>>(
      future: _fetchUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error loading users');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('No users available');
        } else {
          List<String> users = snapshot.data!;
          return DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: label),
            value: users.isNotEmpty ? users[0] : null,
            items: users.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
            onChanged: onChanged,
          );
        }
      },
    );
  }
  Widget _buildCategorySpinner({required String label, required void Function(String?) onChanged}) {
    return FutureBuilder<List<String>>(
      future: _fetchCategory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error loading categories');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('No categories available');
        } else {
          List<String> categories = snapshot.data!;
          return DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: label),
            value: selectedCategory, // Set the initial value to the selectedCategory
            onChanged: onChanged,
            items: categories.map((item) => DropdownMenuItem<String>(value: item, child: Text(item))).toList(),
          );

        }
      },
    );
  }
  Widget _buildBookNameSpinner({required String label, required void Function(String?) onChanged}) {
    return FutureBuilder<List<String>>(
      future: selectedCategory != null ? _fetchBooksByCategory(selectedCategory!) : Future.value([]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error loading book names');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('No book names available for the selected category');
        } else {
          List<String> bookNames = snapshot.data!;
          return DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: label),
            value: bookNames.isNotEmpty ? bookNames[0] : null,
            onChanged: onChanged,
            items: bookNames.map((item) => DropdownMenuItem<String>(value: item, child: Text(item))).toList(),
          );
        }
      },
    );
  }
  Widget _buildTextInput({required String label, required Function(String) onChanged}) {
    return TextField(
      onChanged: onChanged,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
    );
  }

  Widget _buildUneditableTextInput({required String label, required String value}) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      decoration: InputDecoration(labelText: label),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        DateTime pickedDate = (await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        )) ?? DateTime.now();

        // Handle date selection
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: 'Select Date'),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'Selected Date',
            ),
            Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Future<List<String>> _fetchUsers() async {
    List<String> users = [];

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Users').get();

      querySnapshot.docs.forEach((doc) {
        var userData = doc.data() as Map<String, dynamic>;
        String userName = userData['fullName']; // Replace 'fullName' with the actual field name in your Firestore document
        users.add(userName);
      });
    } catch (e) {
      print('Error fetching users: $e');
    }

    return users;
  }
  Future<List<String>> _fetchBooksByCategory(String selectedCategory) async {
    List<String> bookNames = [];

    try {
      print('Selected Category: $selectedCategory');

      // Get the documents from the 'Books' collection where 'categoryName' is equal to the selected category
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Books')
          .where('bookCategory', isEqualTo: selectedCategory)
          .get();

      querySnapshot.docs.forEach((doc) {
        var bookData = doc.data() as Map<String, dynamic>;
        String bookName = bookData['bookName']; // Replace 'bookName' with the actual field name in your Firestore document
        bookNames.add(bookName);
      });

      print('Fetched Book Names: $bookNames');
    } catch (e) {
      print('Error fetching books by category: $e');
    }

    return bookNames;
  }

  Future<List<String>> _fetchCategory() async {
    List<String> category = [];

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('BookCategories').get();

      querySnapshot.docs.forEach((doc) {
        var categoryData = doc.data() as Map<String, dynamic>;
        String categoryName = categoryData['categoryName']; // Replace 'fullName' with the actual field name in your Firestore document
        category.add(categoryName);
      });
    } catch (e) {
      print('Error fetching users: $e');
    }

    return category;
  }
}

