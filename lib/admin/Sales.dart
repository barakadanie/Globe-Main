import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:globe/admin/Books.dart';
import 'package:globe/admin/ConfirmedPayments.dart';
import 'package:globe/admin/PendingConfirmations.dart';
import 'package:globe/admin/Reports.dart';
import 'package:globe/admin/Clients.dart';
import 'package:globe/admin/dashboard.dart';
import 'package:intl/intl.dart';
class Sales extends StatefulWidget {
  @override
  _SalesState createState() => _SalesState();
}

class _SalesState extends State<Sales> {
  Map<String, dynamic>? selectedSalesData;
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('BooksOut').orderBy('Salesperson').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          List<QueryDocumentSnapshot> docs = snapshot.data!.docs;
          Map<String, List<Map<String, dynamic>>> groupedSales = {};

          docs.forEach((doc) {
            var data = doc.data() as Map<String, dynamic>;
            String salesperson = data['Salesperson'];

            if (!groupedSales.containsKey(salesperson)) {
              groupedSales[salesperson] = [];
            }

            groupedSales[salesperson]!.add(data);
          });

          // Debug print to check if data is correctly grouped
          print('Grouped Sales Data: $groupedSales');

          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: DataTable(
              columnSpacing: 16.0,
              sortColumnIndex: 0,
              sortAscending: true,
              headingRowColor: MaterialStateColor.resolveWith((states) => Colors.blue!),
              columns: [
                DataColumn(
                  label: Text('Salesperson',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onSort: (columnIndex, ascending) {
                    setState(() {
                      groupedSales = Map.fromEntries(groupedSales.entries.toList()
                        ..sort((a, b) => ascending
                            ? a.key.compareTo(b.key)
                            : b.key.compareTo(a.key)));
                    });
                  },
                ),
                DataColumn(
                  label: Text('Book Name',style: TextStyle(fontWeight: FontWeight.bold),),

                  onSort: (columnIndex, ascending) {
                    setState(() {
                      groupedSales = Map.fromEntries(groupedSales.entries.toList()
                        ..sort((a, b) => ascending
                            ? a.value.first['Book Name'].compareTo(b.value.first['Book Name'])
                            : b.value.first['Book Name'].compareTo(a.value.first['Book Name'])));
                    });
                  },
                ),
                DataColumn(
                  label: Text('Book Price',style: TextStyle(fontWeight: FontWeight.bold),),
                  onSort: (columnIndex, ascending) {
                    setState(() {
                      groupedSales = Map.fromEntries(groupedSales.entries.toList()
                        ..sort((a, b) => ascending
                            ? a.value.first['Book Price'].compareTo(b.value.first['Book Price'])
                            : b.value.first['Book Price'].compareTo(a.value.first['Book Price'])));
                    });
                  },
                ),
                // Add similar DataColumn entries for other columns
                DataColumn(label: Text('Date Sent',style: TextStyle(fontWeight: FontWeight.bold),)),
                DataColumn(label: Text('Quantity',style: TextStyle(fontWeight: FontWeight.bold),)),
                DataColumn(label: Text('New Amount', style: TextStyle(fontWeight: FontWeight.bold),)),
              ],
              rows: groupedSales.keys.expand((salesperson) {
                var salesData = groupedSales[salesperson]!;
                bool isEven = groupedSales.keys.toList().indexOf(salesperson) % 2 == 0;
                Color backgroundColor = isEven ? Colors.white : Colors.grey[200]!;

                return salesData.map((data) {
                  return DataRow(

                    cells: [
                      DataCell(Text(salesperson)),
                      DataCell(Text(data['Book Name'])),
                      DataCell(Text(data['Book Price'].toString())),
                      DataCell(
                        Text(
                          DateFormat('yyyy-MM-dd HH:mm:ss').format(data['Date Sent'].toDate()),
                        ),
                      ),
                      DataCell(
                        Text(
                          (data['Quantity'] ?? 0.0).toString(),
                        ),
                      ),
                      DataCell(
                        Text(
                          (data['newAmount'] ?? 0.0).toString(),
                        ),
                      ),
                    ],
                    color: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                      return backgroundColor;
                    }),
                  );
                });
              }).toList(),
            ),
          );
        },
      ),
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
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PendingConfirmations()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.checklist),
                title: Text('Confirmed Sales'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ConfirmedPayments()),
                  );
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
  TextEditingController stockController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  DateTime selectedDate = DateTime.now();
  String? selectedCategory;
  String? selectedBookName;
  String? bookImageURL; // New variable to store book price
  String bookPrice = 'N/A';
  String currentStock = 'N/A';
  String? selectedUser; // Initial empty string
  int? quantityToSend;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Form(
        key: _formKey,
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
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  image: bookImageURL != null
                      ? DecorationImage(
                    image: NetworkImage(bookImageURL!),
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
              ),
              _buildSpinner(
                label: 'Select User',
                items: ['User1', 'User2', 'User3'],
                onChanged: (value) {
                  setState(() {
                    selectedUser = value;
                    print('Selected User: $selectedUser');
                  });
                },
              ),


              _buildCategorySpinner(
                label: 'Select Category',
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                    selectedBookName = null;
                  });
                },
              ),
              _buildBookNameSpinner(
                label: 'Select Book Name',
                onChanged: (value) {
                  // Handle book name selection
                },
              ),
              _buildQuantityToSendTextInput(
                label: 'Quantity to Send',
                onChanged: (value) {
                  // Handle the quantity to send input
                },
              ),
              _buildUneditableTextInput(
                label: 'Book Price',
                value: bookPrice!,
              ),
              Builder(
                builder: (context) {
                  return _quantityTextInput(
                    label: 'Current Stock',
                    value: currentStock != null ? currentStock : 'Loading...',
                  );
                },
              ),
              _buildDatePicker(),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Form is valid, continue with the submission
                _saveSalesDataToFirestore();
                // Close the dialog
                Navigator.pop(context);
              }
            },
            child: Text('Add Sales'),
          )

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpinner({ required String label, required List<String> items, required void Function(String?) onChanged,}) {
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
            value: selectedUser,
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
            value: selectedCategory,
            onChanged: (value) {
              setState(() {
                selectedCategory = value;
                selectedBookName = null; // Reset selectedBookName when category changes
              });
              onChanged(value);
            },
            items: categories.map((item) => DropdownMenuItem<String>(value: item, child: Text(item))).toList(),
          );
        }
      },
    );
  }
  Widget _buildBookNameSpinner({required String label, required void Function(String?) onChanged}) {return FutureBuilder<List<String>>(
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
            value: selectedBookName,
            onChanged: (value) {
              setState(() {
                selectedBookName = value;
                _fetchBookImageURL();
                _fetchBookPrice();
                _fetchCurrentStock(); // Add this line to fetch current stock when book name is selected
              });
              onChanged(value);
            },
            items: bookNames.map((item) => DropdownMenuItem<String>(value: item, child: Text(item))).toList(),
          );
        }
      },
    );  }
  Widget _quantityTextInput({required String label, required String value}) {
    return TextFormField(
      controller: stockController,
      decoration: InputDecoration(
        labelText: label,
        errorText: _validateQuantity(value),
      ),
    );
  }
  Widget _buildQuantityToSendTextInput({ required String label,required void Function(String) onChanged,}) {
    return TextFormField(
      onChanged: (value) {
        onChanged(value);
        // Capture the entered quantity directly
        quantityToSend = int.tryParse(value);
      },
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        return _validateQuantity(value!);
      },
    );
  }
  Widget _buildUneditableTextInput({required String label, required String value}) {
    return TextFormField(
      controller: priceController, // Set the controller
      readOnly: true,
      decoration: InputDecoration(labelText: label),
    );
  }
  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        DateTime pickedDate = (await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
          selectableDayPredicate: (DateTime day) {
            // Disable dates before today
            return day.isAfter(DateTime.now().subtract(Duration(days: 1)));
          },
        )) ?? selectedDate;

        // Handle date selection
        setState(() {
          selectedDate = pickedDate;
        });
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: 'Select Date'),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              '${selectedDate.toLocal()}'.split(' ')[0],
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
  Future<void> _fetchBookImageURL() async {
    if (selectedCategory != null && selectedBookName != null) {
      try {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('Books')
            .where('bookCategory', isEqualTo: selectedCategory)
            .where('bookName', isEqualTo: selectedBookName)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          var bookData = querySnapshot.docs.first.data() as Map<String, dynamic>;
          setState(() {
            bookImageURL = bookData['bookImageURL'];
          });
        } else {
          setState(() {
            bookImageURL = null; // Set to null if no matching document is found
          });
        }
      } catch (e) {
        print('Error fetching book image URL: $e');
      }
    }
  }
  Future<void> _fetchBookPrice() async {
    if (selectedCategory != null && selectedBookName != null) {
      try {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('Books')
            .where('bookCategory', isEqualTo: selectedCategory)
            .where('bookName', isEqualTo: selectedBookName)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          var bookData = querySnapshot.docs.first.data() as Map<String, dynamic>;
          String fetchedPrice = bookData['bookPrice'].toString();
          print('Fetched Book Price: $fetchedPrice');
          setState(() {
            bookPrice = fetchedPrice;
            priceController.text = fetchedPrice; // Set the text for the controller
          });
        } else {
          setState(() {
            bookPrice = 'N/A';
            priceController.text = 'N/A'; // Set default value if no document is found
          });
          print('No document found for book price.');
        }
      } catch (e) {
        print('Error fetching book price: $e');
        setState(() {
          bookPrice = 'Error';
          priceController.text = 'Error'; // Set default value in case of an error
        });
      }
    }
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
  Future<void> _fetchCurrentStock() async {
    if (selectedCategory != null && selectedBookName != null) {
      try {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('Books')
            .where('bookCategory', isEqualTo: selectedCategory)
            .where('bookName', isEqualTo: selectedBookName)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          var bookData = querySnapshot.docs.first.data() as Map<String, dynamic>;
          String fetchedStock = bookData['quantity'].toString();
          print('Fetched Current Stock: $fetchedStock');
          setState(() {
            currentStock = fetchedStock;
            stockController.text = fetchedStock; // Set the text for the controller
          });
        } else {
          setState(() {
            currentStock = 'N/A';
            stockController.text = 'N/A'; // Set default value if no document is found
          });
          print('No document found for current stock.');
        }
      } catch (e) {
        print('Error fetching current stock: $e');
        setState(() {
          currentStock = 'Error';
          stockController.text = 'Error'; // Set default value in case of an error
        });
      }
    }
  }

  Future<void> _saveSalesDataToFirestore() async {
    try {
      // Validate the entered quantity against the current stock
      String? quantityValidation = _validateQuantity(quantityToSend.toString());
      if (quantityValidation != null) {
        // Display an error message if the quantity is greater than the current stock
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Quantity Error'),
              content: Text(quantityValidation),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
        return; // Exit the method if there is a quantity validation error
      }

      // Prepare the data to be saved to Firestore
      Map<String, dynamic> salesData = {
        'Salesperson': selectedUser,
        'Book Category': selectedCategory,
        'Book Name': selectedBookName,
        'Book Price': double.parse(bookPrice),
        'Quantity': quantityToSend,
        'Date Sent': selectedDate,
        'Collected':false,
        // Add any other fields you want to save
      };

      // Check if the Salesperson has a book in BooksOut with the same bookName and bookCategory
      QuerySnapshot existingBooksOut = await FirebaseFirestore.instance
          .collection('BooksOut')
          .where('Salesperson', isEqualTo: selectedUser)
          .where('Book Name', isEqualTo: selectedBookName)
          .where('Book Category', isEqualTo: selectedCategory)
          .get();

      if (existingBooksOut.docs.isNotEmpty) {
        // Update the quantity in the existing record in BooksOut
        var existingBookOutDoc = existingBooksOut.docs.first;
        int existingQuantity = existingBookOutDoc['Quantity'];
        int updatedQuantity = existingQuantity + quantityToSend!;
        //double newAmount = double.parse(bookPrice) * updatedQuantity; // Calculate new amount

        FirebaseFirestore.instance.collection('BooksOut').doc(existingBookOutDoc.id).update({
          'Quantity': updatedQuantity,
          'newAmount': quantityToSend,
        });

        // Create a copy of the updated document in BooksOutUpdates with salesID
        FirebaseFirestore.instance.collection('BooksOutUpdates').add({
          ...existingBookOutDoc.data() as Map<String, dynamic>,
          'newAmount': quantityToSend,
          'salesID': existingBookOutDoc.id,
        });
      } else {
        // Add the sales data to the 'BooksOut' collection
        await FirebaseFirestore.instance.collection('BooksOut').add({
          ...salesData,
          'newAmount': quantityToSend, // Calculate new amount
        });
      }

      // Update the quantity in the 'Books' collection
      if (selectedCategory != null && selectedBookName != null) {
        await FirebaseFirestore.instance.collection('Books')
            .where('bookCategory', isEqualTo: selectedCategory)
            .where('bookName', isEqualTo: selectedBookName)
            .get()
            .then((querySnapshot) {
          if (querySnapshot.docs.isNotEmpty) {
            var bookDoc = querySnapshot.docs.first;
            String currentStockValue = bookDoc['quantity'];
            int currentStockIntValue = int.parse(currentStockValue);
            int updatedStockValue = currentStockIntValue - quantityToSend!;

            // Print the values for debugging
            print('Current Stock Value: $currentStockValue');
            print('Quantity to Send: $quantityToSend');
            print('Updated Stock Value: $updatedStockValue');

            // Update the quantity in the 'Books' collection
            FirebaseFirestore.instance.collection('Books').doc(bookDoc.id).update({
              'quantity': updatedStockValue.toString(), // Convert back to string
            });

            print('Quantity updated in Firestore successfully');
          }
        });
      }

      print('Sales data saved to Firestore successfully');
    } catch (e) {
      print('Error saving sales data to Firestore: $e');
      // Handle the error appropriately
    }
  }

  String? _validateQuantity(String value) {if (int.tryParse(value) == null) {return 'Enter a valid quantity'; }

    int enteredQuantity = int.parse(value);
    int currentStockValue = currentStock != 'N/A' ? int.parse(currentStock) : 0;

    if (enteredQuantity > currentStockValue) {
      return 'Entered quantity exceeds current stock';
    }

    return null; // Return null if validation passes
  }
}


