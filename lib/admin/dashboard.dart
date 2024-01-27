import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:globe/admin/Books.dart';
import 'package:globe/admin/Reports.dart';
import 'package:globe/admin/Sales.dart';
import 'package:globe/admin/ProfileAdmin.dart';
import 'package:globe/admin/Clients.dart';
import 'package:globe/common/Chat.dart';
import 'package:globe/helpers/assets.dart';

class Dashboard extends StatelessWidget {
  static const String path = "admin/dashboard.dart";
  final String avatar = avatars[0];
  final TextStyle whiteText = const TextStyle(color: Colors.white);
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>(); // Add this line

  Dashboard({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key, // Add this line
      appBar: AppBar(
        title: Text('Pen To Paper LTD'), // Change this to your app title
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            _key.currentState!.openDrawer();
          },
        ),
      ),
      drawer: _buildDrawer(context), // Add this line
      backgroundColor: Colors.white,
      body: _buildBody(context),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return BottomNavigationBar(
      selectedItemColor: Colors.grey.shade800,
      unselectedItemColor: Colors.grey,
      currentIndex: 0,
      onTap: (index) {
        _handleNavigation(index, context);
      },
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
    );
  }

  void _handleNavigation(int index, BuildContext context) {
    switch (index) {
      case 1: // Books
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Books()),
        );
        break;
      case 2: // Sales
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Sales()),
        );
        break;
      case 3: // Clients
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Clients()),
        );
        break;
      case 4: // Reports
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Reports()),
        );
        break;
    // Add more cases for additional items as needed
    }
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildHeader(),
          const SizedBox(height: 20.0),
          const Padding(
            padding: EdgeInsets.only(left: 16.0),
            child: Text(
              "Sales",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
            ),
          ),
          Card(
            elevation: 4.0,
            color: Colors.white,
            margin: const EdgeInsets.all(16.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: ListTile(
                    leading: Container(
                      alignment: Alignment.bottomCenter,
                      width: 45.0,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Container(
                            height: 20,
                            width: 8.0,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(width: 4.0),
                          Container(
                            height: 25,
                            width: 8.0,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(width: 4.0),
                          Container(
                            height: 40,
                            width: 8.0,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 4.0),
                          Container(
                            height: 30,
                            width: 8.0,
                            color: Colors.grey.shade300,
                          ),
                        ],
                      ),
                    ),
                    title: const Text("This Month Sales"),
                    subtitle: const Text("Ksh.0"),
                  ),
                ),
                const VerticalDivider(),
                Expanded(
                  child: ListTile(
                    leading: Container(
                      alignment: Alignment.bottomCenter,
                      width: 45.0,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Container(
                            height: 20,
                            width: 8.0,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(width: 4.0),
                          Container(
                            height: 25,
                            width: 8.0,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(width: 4.0),
                          Container(
                            height: 40,
                            width: 8.0,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 4.0),
                          Container(
                            height: 30,
                            width: 8.0,
                            color: Colors.grey.shade300,
                          ),
                        ],
                      ),
                    ),
                    title: const Text("Total Sales Today"),
                    subtitle: const Text("Ksh.0"),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: _buildTile(
                    color: Colors.pink,
                    icon: Icons.portrait,
                    title: "Number of books instore",
                    data: "0",
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: _buildTile(
                    color: Colors.green,
                    icon: Icons.portrait,
                    title: "Admitted",
                    data: "857",
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _buildTile(
                    color: Colors.blue,
                    icon: Icons.favorite,
                    title: "Discharged",
                    data: "864",
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: _buildTile(
                    color: Colors.pink,
                    icon: Icons.portrait,
                    title: "Dropped",
                    data: "857",
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: _buildTile(
                    color: Colors.blue,
                    icon: Icons.favorite,
                    title: "Arrived",
                    data: "698",
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20.0),
        ],
      ),
    );
  }

  Container _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 50.0, 0, 32.0),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.0),
          bottomRight: Radius.circular(20.0),
        ),
        color: Colors.blue,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            title: Text(
              "Dashboard",
              style: whiteText.copyWith(
                  fontWeight: FontWeight.bold, fontSize: 20.0),
            ),
            trailing: CircleAvatar(
              radius: 25.0,
              backgroundImage: NetworkImage(avatar),
            ),
          ),
          const SizedBox(height: 10.0),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(
              "Dr. John Doe",
              style: whiteText.copyWith(
                fontSize: 18.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 5.0),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(
              "Md, (General Medium), DM\n(Cardiology)",
              style: whiteText,
            ),
          ),
        ],
      ),
    );
  }
  Container _buildTile(
      {Color? color,
        IconData? icon,
        required String title,
        required String data}) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      height: 150.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.0),
        color: color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Icon(
            icon,
            color: Colors.white,
          ),
          Text(
            title,
            style: whiteText.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            data,
            style: whiteText.copyWith(fontWeight: FontWeight.bold, fontSize: 20.0),
          ),
        ],
      ),
    );
  }
}

_buildDrawer(BuildContext context) {
  return ClipPath(
    clipper: OvalRightBorderClipper(),
    child: Drawer(
      child: Container(
        padding: const EdgeInsets.only(left: 16.0, right: 40),
        decoration: BoxDecoration(
            color: Colors.white, boxShadow: const [BoxShadow(color: Colors.black45)]),
        width: 300,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
            Container(
            alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(
                  Icons.power_settings_new,
                  color: Colors.grey.shade800,
                ),
                onPressed: () async {
                  // Perform logout actions
                  await _logout();

                  // Redirect to login screen
                  Navigator.of(context).pushReplacementNamed('/login');
                },
              ),
            ),
                Container(
                  height: 90,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: [Colors.orange, Colors.deepOrange])),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(avatars[0]), // Assuming avatars is accessible here
                  ),
                ),
                const SizedBox(height: 5.0),
                const Text(
                  "Your Name",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600),
                ),
                Text(
                  "@yourUsername",
                  style: TextStyle(color: Colors.grey.shade800, fontSize: 16.0),
                ),
                const SizedBox(height: 30.0),
                _buildRow(context, Icons.home, "Home"),
                _buildDivider(),
                _buildRow(context, Icons.person_pin, "My profile"),
                _buildDivider(),
                _buildRow(context, Icons.message, "Messages", showBadge: true),
                _buildDivider(),
                _buildRow(context, Icons.notifications, "Notifications", showBadge: true),
                _buildDivider(),
                _buildRow(context, Icons.settings, "Settings"),
                _buildDivider(),
                _buildRow(context, Icons.email, "Contact us"),
                _buildDivider(),
                _buildRow(context, Icons.info_outline, "Help"),
                _buildDivider(),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> _logout() async {
  try {
    await FirebaseAuth.instance.signOut();
    // Optionally, you can perform additional cleanup or tasks during logout
  } catch (e) {
    print('Error during logout: $e');
  }
}

Divider _buildDivider() {
  return Divider(
    color: Colors.grey.shade600,
  );
}
Widget _buildRow(BuildContext context, IconData icon, String title, {bool showBadge = false}) {
  final TextStyle tStyle = TextStyle(color: Colors.grey.shade800, fontSize: 16.0);

  void _handleDrawerAction(String actionTitle) {
    switch (actionTitle) {
      case "Home":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Dashboard()),
        );
        break;
      case "My profile":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfileAdmin()),
        );
        break;
      case "Messages":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Chat()),
        );
        break;
      case "Notifications":
      // Add your logic for Notifications action here
        print("Notifications action");
        break;
      case "Settings":
      // Add your logic for Settings action here
        print("Settings action");
        break;
      case "Contact us":
      // Add your logic for Contact us action here
        print("Contact us action");
        break;
      case "Help":
      // Add your logic for Help action here
        print("Help action");
        break;
    }
  }

  return Container(
    padding: const EdgeInsets.symmetric(vertical: 5.0),
    child: InkWell(
      onTap: () {
        _handleDrawerAction(title);
      },
      child: Row(children: [
        IconButton(
          icon: Icon(
            icon,
            color: Colors.grey.shade800,
          ),
          onPressed: () {
            _handleDrawerAction(title);
          },
        ),
        const SizedBox(width: 10.0),
        Text(
          title,
          style: tStyle,
        ),
        const Spacer(),
        if (showBadge)
          Material(
            color: Colors.deepOrange,
            elevation: 5.0,
            shadowColor: Colors.red,
            borderRadius: BorderRadius.circular(5.0),
            child: Container(
              width: 25,
              height: 25,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.deepOrange,
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: const Text(
                "10+",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
          )
      ]),
    ),
  );
}

