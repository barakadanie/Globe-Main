import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:globe/admin/Reports.dart';
import 'package:globe/admin/Sales.dart';
import 'package:globe/admin/Clients.dart';
import 'package:globe/admin/dashboard.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Books extends StatefulWidget {
  @override
  _BooksState createState() => _BooksState();
}

class _BooksState extends State<Books> {
  String pageTitle = "Books Information";
  DateTime? selectedDate;
  TextEditingController dateController = TextEditingController();
  File? pickedImage;
  File? selectedImageFile; // Added to hold the selected image file
  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      body: _buildBody(),
      currentIndex: 1,
      onTabTapped: (index) {
        _onTabTapped(context, index);
      },
      floatingButton: FloatingActionButton(
        onPressed: () {
          _showOptions(context);
        },
        child: Icon(Icons.add),
      ),
      pageTitle: pageTitle,
    );
  }

  TextField _buildSearchField() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search by book name',
        contentPadding: EdgeInsets.all(16),
        prefixIcon: Icon(Icons.search),
      ),
      onChanged: (value) {
        // Implement search logic here
      },
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildSearchField(),
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection('Books').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error fetching books: ${snapshot.error}"));
              } else {
                List<DataRow> rows = snapshot.data!.docs.map<DataRow>((document) {
                  Map<String, dynamic> data = document.data()!;
                  return _buildDataRow(data);
                }).toList();

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.resolveWith<Color?>(
                              (Set<MaterialState> states) {
                            return Colors.blueAccent; // Header row color
                          }),
                      dataRowColor: MaterialStateProperty.resolveWith<Color?>(
                              (Set<MaterialState> states) {
                            return states.contains(MaterialState.selected)
                                ? Theme.of(context).colorScheme.primary.withOpacity(0.08)
                                : Colors.grey.shade200; // Data row color
                          }),
                      sortColumnIndex: 1,
                      sortAscending: true,
                      columns: [
                        DataColumn(
                          label: Text(
                            "Category",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onSort: (columnIndex, ascending) {
                            setState(() {
                              snapshot.data!.docs.sort((a, b) {
                                return ascending
                                    ? a['bookCategory'].compareTo(b['bookCategory'])
                                    : b['bookCategory'].compareTo(a['bookCategory']);
                              });
                            });
                          },
                        ),
                        DataColumn(
                          label: Text(
                            "Book Name",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onSort: (columnIndex, ascending) {
                            setState(() {
                              snapshot.data!.docs.sort((a, b) {
                                return ascending
                                    ? a['bookName'].compareTo(b['bookName'])
                                    : b['bookName'].compareTo(a['bookName']);
                              });
                            });
                          },
                        ),
                        DataColumn(
                          label: Text(
                            "Quantity",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "Price",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      rows: rows,
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  DataCell _buildDataCell(String text) {
    return DataCell(
      Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  DataRow _buildDataRow(Map<String, dynamic> data) {
    return DataRow(
      color: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
        return states.contains(MaterialState.selected)
            ? Theme.of(context).colorScheme.primary.withOpacity(0.08)
            : Colors.grey.shade200;
      }),
      onSelectChanged: (selected) {
        if (selected!) {
          _showUpdateDialog(data);
        }
      },
      cells: [
        _buildDataCell(data['bookCategory'] ?? ''),
        _buildDataCell(data['bookName'] ?? ''),
        _buildDataCell(data['quantity']?.toString() ?? ''),
        _buildDataCell(data['bookPrice']?.toString() ?? ''),
      ],
    );
  }

  void _showUpdateDialog(Map<String, dynamic> bookData) {
    TextEditingController bookNameController =
    TextEditingController(text: bookData['bookName']);
    TextEditingController quantityController =
    TextEditingController(text: bookData['quantity']);
    TextEditingController priceController =
    TextEditingController(text: bookData['bookPrice']);

    int? quantityToSend;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Update Book"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: bookNameController,
                      decoration: InputDecoration(labelText: "Book Name"),
                    ),
                    TextField(
                      controller: quantityController,
                      decoration: InputDecoration(labelText: "Quantity"),
                    ),
                    TextField(
                      controller: priceController,
                      decoration: InputDecoration(labelText: "Price"),
                    ),
                    // Add more text fields based on your data structure
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                  },
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () async {
                    // Get updated values from the text fields
                    String updatedBookName = bookNameController.text.trim();
                    String updatedQuantity = quantityController.text.trim();
                    String updatedPrice = priceController.text.trim();

                    // Check if any field is empty
                    if (updatedBookName.isEmpty ||
                        updatedQuantity.isEmpty ||
                        updatedPrice.isEmpty) {
                      // Show an error dialog
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Error"),
                            content: Text("All fields are required."),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context); // Close error dialog
                                },
                                child: Text("OK"),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      // Close the dialog
                      Navigator.pop(context);

                      try {
                        // Update Firestore document
                        await FirebaseFirestore.instance
                            .collection('Books')
                            .doc(bookData['bookId'])
                            .update({
                          'bookName': updatedBookName,
                          'quantity': updatedQuantity,
                          'bookPrice': updatedPrice,
                          // Update other fields accordingly
                        });

                        // Save the success message or take further action as needed
                        String successMessage = "Book updated successfully!";
                        // You can save the success message or perform additional actions here
                        print(successMessage);

                        // Show success message dialog
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Success"),
                              content: Text("Book updated successfully!"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Close success dialog
                                  },
                                  child: Text("OK"),
                                ),
                              ],
                            );
                          },
                        );
                      } catch (error) {
                        // Handle error
                        print("Error updating book: $error");

                        // Show error dialog
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Error"),
                              content: Text("Failed to update book. Please try again."),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Close error dialog
                                  },
                                  child: Text("OK"),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    }
                  },
                  child: Text("Update"),
                ),

              ],
            );
          },
        );
      },
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
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Sales()),
        );
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

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.library_books),
                title: Text('Add Book'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddBookDialog(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.shelves),
                title: Text('Add Book Category'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddBookCategoryDialog(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.auto_graph_outlined),
                title: Text('Books Stats'),
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

  void _showAddBookDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return FutureBuilder<List<String>>(
              future: _fetchCategories(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return AlertDialog(
                    title: Text("Error"),
                    content: Text("Failed to fetch categories. Please try again."),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Close error dialog
                        },
                        child: Text("OK"),
                      ),
                    ],
                  );
                } else {
                  List<String> categoryNames = snapshot.data ?? [];

                  TextEditingController bookNameController = TextEditingController();
                  TextEditingController bookPriceController = TextEditingController();
                  TextEditingController quantityController = TextEditingController();

                  return AlertDialog(
                    title: Text("Add Book"),
                    content: SingleChildScrollView(
                      child: Container(
                        width: double.maxFinite,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                File? selectedFile = await _pickImage();
                                if (selectedFile != null) {
                                  setState(() {
                                    selectedImageFile = selectedFile;
                                  });
                                }
                              },
                              child: Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: selectedImageFile != null
                                    ? Image.file(
                                  selectedImageFile!,
                                  key: ValueKey(selectedImageFile),
                                  fit: BoxFit.cover,
                                )
                                    : Container(),
                              ),
                            ),
                            SizedBox(height: 16),
                            Container(
                              width: double.maxFinite,
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: DropdownButton<String>(
                                value: selectedCategory,
                                items: [
                                  ...categoryNames.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ],
                                hint: Text("Select Category"), // Placeholder text
                                onChanged: (String? value) {
                                  setState(() {
                                    selectedCategory = value;
                                  });
                                },
                              ),
                            ),
                            SizedBox(height: 16),
                            Container(
                              width: double.maxFinite,
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: TextField(
                                controller: bookNameController,
                                decoration: InputDecoration(
                                  labelText: "Book Name",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            Container(
                              width: double.maxFinite,
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: TextField(
                                controller: bookPriceController,
                                decoration: InputDecoration(
                                  labelText: "Book Price",
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            SizedBox(height: 16),
                            Container(
                              width: double.maxFinite,
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: TextField(
                                controller: quantityController,
                                decoration: InputDecoration(
                                  labelText: "Quantity",
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            SizedBox(height: 16),
                            Container(
                              width: double.maxFinite,
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: TextFormField(
                                readOnly: true,
                                onTap: () {
                                  _selectDate(context);
                                },
                                decoration: InputDecoration(
                                  labelText: "Select Date",
                                  border: OutlineInputBorder(),
                                ),
                                controller: dateController,
                              ),
                            ),
                            SizedBox(height: 16),
                            Container(
                              width: double.maxFinite,
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: ElevatedButton(
                                onPressed: () async {
                                  // Check if book with similar name and category exists
                                  bool bookExists = await _checkBookExists(
                                    bookNameController.text.trim(),
                                    selectedCategory!,
                                  );

                                  if (bookExists) {
                                    // Show error dialog
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text("Error"),
                                          content: Text("Book with similar name and category already exists."),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context); // Close error dialog
                                              },
                                              child: Text("OK"),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  } else {
                                    // Book does not exist, proceed to save
                                    String? imageUrl = await _uploadImage(selectedImageFile!);
                                    if (imageUrl != null) {
                                      await _saveBook(
                                        bookNameController.text.trim(),
                                        selectedCategory!,
                                        bookPriceController.text.trim(),
                                        quantityController.text.trim(),
                                        imageUrl,
                                      );

                                      // Show success dialog
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text("Success"),
                                            content: Text("Book added successfully!"),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context); // Close success dialog
                                                  Navigator.pop(context); // Close add book dialog
                                                },
                                                child: Text("OK"),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    } else {
                                      // Handle image upload failure
                                      print("Failed to upload image.");
                                    }
                                  }
                                },
                                child: Text("Add Book"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
              },
            );
          },
        );
      },
    );
  }

  Future<bool> _checkBookExists(String bookName, String category) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection('Books')
          .where('bookName', isEqualTo: bookName)
          .where('bookCategory', isEqualTo: category)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (error) {
      print("Error checking if book exists: $error");
      return false;
    }
  }
  Future<String?> _uploadImage(File imageFile) async {
    try {
      // Get the file extension from the image file
      String fileExtension = imageFile.path.split('.').last;

      // Replace 'your-firebase-storage-path' with the actual path you want to use in Firebase Storage
      String storagePath = 'your-firebase-storage-path/${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

      // Upload the image to Firebase Storage
      await FirebaseStorage.instance.ref(storagePath).putFile(imageFile);

      // Get the download URL of the uploaded image
      String downloadURL = await FirebaseStorage.instance.ref(storagePath).getDownloadURL();

      return downloadURL;
    } catch (error) {
      print("Error uploading image: $error");
      return null;
    }
  }

  Future<void> _saveBook(
      String bookName,
      String category,
      String price,
      String quantity,
      String bookImageURL,
      ) async {
    try {
      // Show uploading dialog with spinner
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text("Uploading book..."),
              ],
            ),
          );
        },
      );

      CollectionReference books = FirebaseFirestore.instance.collection('Books');
      DocumentReference result = await books.add({
        'bookName': bookName,
        'bookCategory': category,
        'bookPrice': price,
        'quantity': quantity,
        'bookImageURL': bookImageURL,
        'dateAdded': selectedDate,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update the document with the assigned ID
      await result.update({'bookId': result.id});

      // Close the uploading dialog
      Navigator.pop(context);
    } catch (error) {
      print("Error saving book: $error");
      throw error;
    }
  }



  void _showAddBookCategoryDialog(BuildContext context) {
    TextEditingController categoryNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add Book Category"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: categoryNameController,
                decoration: InputDecoration(
                  labelText: "Category Name",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  // Validate category name
                  String categoryName = categoryNameController.text.trim();
                  if (categoryName.isNotEmpty) {
                    // Generate category ID manually
                    String categoryId = DateTime.now().millisecondsSinceEpoch.toString();

                    // Show uploading dialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Uploading"),
                          content: CircularProgressIndicator(),
                        );
                      },
                      barrierDismissible: false,
                    );

                    // Save category to Firestore with the manually generated ID
                    try {
                      CollectionReference categories =
                      FirebaseFirestore.instance.collection('BookCategories');
                      await categories.doc(categoryId).set({
                        'categoryName': categoryName,
                        // Add any additional fields you need
                      });

                      // Close the uploading dialog
                      Navigator.pop(context);

                      // Show success dialog
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Success"),
                            content: Text("Category uploaded successfully!"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context); // Close success dialog
                                  Navigator.pop(context); // Close category input dialog
                                },
                                child: Text("OK"),
                              ),
                            ],
                          );
                        },
                      );
                    } catch (error) {
                      print("Error uploading category: $error");

                      // Close the uploading dialog
                      Navigator.pop(context);

                      // Show error dialog
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Error"),
                            content: Text("Failed to upload category. Please try again."),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context); // Close error dialog
                                },
                                child: Text("OK"),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  } else {
                    // Show an error message or handle validation failure
                    print("Category name is required.");
                  }
                },
                child: Text("Save Category"),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<List<String>> _fetchCategories() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await FirebaseFirestore.instance.collection('BookCategories').get();

      List<String> categoryNames = querySnapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
      doc.data()['categoryName'] as String)
          .toList();

      return categoryNames;
    } catch (error) {
      print("Error fetching categories: $error");
      throw error;
    }
  }

  Future<File?> _pickImage() async {
    final ImagePicker _picker = ImagePicker();

    final PermissionStatus status = await Permission.storage.request();
    if (status.isGranted) {
      try {
        final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

        if (pickedFile != null) {
          final File imageFile = File(pickedFile.path);
          return imageFile;
        } else {
          print("Image selection canceled");
        }
      } catch (e) {
        print("Error picking image: $e");
      }
    } else {
      print("Permission denied to access storage");
    }

    return null;
  }

  void _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        dateController.text =
        "${selectedDate!.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _updateTitle("Books Information");
  }

  void _updateTitle(String newTitle) {
    setState(() {
      pageTitle = newTitle;
    });
  }
}

class BaseScreen extends StatelessWidget {
  final Widget body;
  final int currentIndex;
  final Function(int) onTabTapped;
  final Widget? floatingButton;
  final String pageTitle;

  BaseScreen({
    required this.body,
    required this.currentIndex,
    required this.onTabTapped,
    this.floatingButton,
    required this.pageTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle),
      ),
      body: body,
      floatingActionButton: floatingButton,
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.grey.shade800,
        unselectedItemColor: Colors.grey,
        currentIndex: currentIndex,
        onTap: onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: "Books",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.money),
            label: "Sales",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: "Clients",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: "Reports",
          ),
        ],
      ),
    );
  }
}
