import 'package:flutter/material.dart';
import 'package:globe/admin/Books.dart';
import 'package:globe/admin/Reports.dart';
import 'package:globe/admin/Clients.dart';
import 'package:globe/admin/dashboard.dart';

class Sales extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      body: _buildBody(),
      currentIndex: 2, // Set the correct index for this screen
      onTabTapped: (index) {
        _onTabTapped(context, index);
      }, pageTitle: 'Sales Information',
    );
  }

  Widget _buildBody() {
    // Build the body content for the Books screen
    return Center(
      child: Text("Books Screen Content"),
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
}
