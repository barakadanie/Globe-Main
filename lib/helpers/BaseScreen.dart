import 'package:flutter/material.dart';

class BaseScreen extends StatelessWidget {
  final Widget body;
  final int currentIndex;
  final Function(int) onTabTapped;
  final Widget? floatingButton;
  final String pageTitle;
  final Color? appBarColor; // Added appBarColor parameter

  BaseScreen({
    required this.body,
    required this.currentIndex,
    required this.onTabTapped,
    this.floatingButton,
    required this.pageTitle,
    this.appBarColor, // Added this line
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle),
        backgroundColor: Colors.blue,

        // Use the appBarColor parameter
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
