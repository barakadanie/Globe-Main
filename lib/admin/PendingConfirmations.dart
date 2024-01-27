import 'package:globe/admin/Clients.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:globe/admin/Books.dart';
import 'package:globe/admin/ConfirmedPayments.dart';
import 'package:globe/admin/Reports.dart';
import 'package:globe/admin/Sales.dart';
import 'package:globe/admin/dashboard.dart';
import 'package:intl/intl.dart';

class PendingConfirmations extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      body: _buildBody(),
      currentIndex: 2,
      onTabTapped: (index) {
        _onTabTapped(context, index);
      },
      pageTitle: 'Confirmed Payments Information',
      floatingButton: FloatingActionButton(
        onPressed: () {
          _showOptionsBottomSheet(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Mysales').where('Confirmation', isEqualTo: false).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error loading data');
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text('No unconfirmed payments available');
        } else {
          List<DataColumn> columns = [
            DataColumn(label: Text('Salesperson', style: TextStyle(color: Colors.blue))),
            DataColumn(label: Text('Book Category', style: TextStyle(color: Colors.blue))),
            DataColumn(label: Text('Book Name', style: TextStyle(color: Colors.blue))),
            DataColumn(label: Text('Book Price', style: TextStyle(color: Colors.blue))),
            DataColumn(label: Text('Quantity Sold', style: TextStyle(color: Colors.blue))),
            DataColumn(label: Text('Amount Paid', style: TextStyle(color: Colors.blue))),
            DataColumn(label: Text('Client Name', style: TextStyle(color: Colors.blue))),
            DataColumn(label: Text('Client Contact', style: TextStyle(color: Colors.blue))),
            DataColumn(label: Text('Payment Code', style: TextStyle(color: Colors.blue))),
            DataColumn(label: Text('Date Sold', style: TextStyle(color: Colors.blue))),
            DataColumn(label: Text('Confirmed', style: TextStyle(color: Colors.blue))),
            DataColumn(label: Text('Action', style: TextStyle(color: Colors.blue))),
          ];

          List<DataRow> rows = snapshot.data!.docs.map((document) {

            var salesperson = document['Salesperson'];
            var bookCategory = document['Book category'];
            var bookName = document['Book name'];
            var bookPrice = document['Book price'];
            var quantitySold = document['Quantity sold'];
            var amountPaid = document['Amount paid'];
            var clientName = document['Client name'];
            var clientContact = document['Client contact'];
            var paymentCode = document['Payment code'];
            var dateSoldTimestamp = (document['Date sold'] as Timestamp).toDate();
            var dateSold = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateSoldTimestamp);
            var confirmation = document['Confirmation'].toString(); // Convert boolean to string
            return DataRow(
              cells: [
                DataCell(Text(salesperson)),
                DataCell(Text(bookCategory)),
                DataCell(Text(bookName)),
                DataCell(Text(bookPrice)),
                DataCell(Text(quantitySold)),
                DataCell(Text(amountPaid)),
                DataCell(Text(clientName)),
                DataCell(Text(clientContact)),
                DataCell(Text(paymentCode)),
                DataCell(Text(dateSold)),
                DataCell(Text(confirmation)),
                DataCell(
                  ElevatedButton(
                    onPressed: () {
                      _showConfirmationDialog(context, document.id);
                    },
                    child: Text('Confirm'),
                  ),
                ),
              ],
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

  Future<void> _showConfirmationDialog(BuildContext context, String documentId) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Payment'),
          content: Text('Do you want to confirm this payment?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                FirebaseFirestore.instance.collection('Mysales').doc(documentId).update({'Confirmation': true});
                Navigator.of(context).pop();
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}
void _showAddSalesDialog(BuildContext context) {
  // //showDialog(
  //   context: context,
  //   //builder: (context) => _AddSalesDialog(),
  // );
}
