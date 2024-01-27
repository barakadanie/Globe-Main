import 'package:globe/admin/Clients.dart';
import 'package:flutter/material.dart';
import 'package:globe/admin/Books.dart';
import 'package:globe/admin/Reports.dart';
import 'package:globe/admin/Sales.dart';
import 'package:globe/admin/dashboard.dart';
import 'package:intl/intl.dart';

class ClientStats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      body: _buildBody(context),
      currentIndex: 2,
      onTabTapped: (index) {
        _onTabTapped(context, index);
      },
      pageTitle: 'Confirmed Payments Information',
    );
  }

  Widget _buildBody(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        // Use the appBarColor parameter
      ),
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

