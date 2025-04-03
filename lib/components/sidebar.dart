import 'package:flutter/material.dart';
import 'package:RecoverSmart/api/auth_service.dart';
import 'package:RecoverSmart/api/user_details.dart';
import 'dart:async';

class Sidebar extends StatefulWidget {
  static int _selectedIndex = 0;

  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();

  // Sidebar(this._selectedIndex);
}

class _SidebarState extends State<Sidebar> {
  // int _selectedIndex = 0;

  String _path = '';
  User? user;
  String baseUrl = AuthService.baseUrl;
  final String? _access_token = AuthService.accessToken;

  String? username = 'Loading...';
  String email = 'Loading...';
  String profileText = '...';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Method to fetch user data
  Future<void> _fetchUserData() async {
    if (_access_token == null) {
      print('Access token is null');
      return;
    }

    setState(() {});

    try {
      final fetchedUser = await fetchUser(_access_token, baseUrl);
      setState(() {
        user = fetchedUser;
        username = '${user!.firstName} ${user!.lastName}';
        email = user!.email;
        profileText = '${user!.firstName[0]}${user!.lastName[0]}';
      });
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        username = 'Error loading user';
      });
    }
  }

  void _onItemTapped(int index) {
    Sidebar._selectedIndex = index;
    setState(() {
      _path = switch (index) {
        0 => '/dashboard',
        1 => '/milestone',
        2 => '/records',
        3 => '/notes',
        _ => throw UnimplementedError(),
      };

      Navigator.pushNamed(context, _path);

      // Navigator.of(context).pushAndRemoveUntil(
      //   _path as Route<Object?>,
      //   (Route<dynamic> route) => false,
      // );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(username!),
            accountEmail: Text(email),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                profileText,
                style: TextStyle(
                  fontSize: 40.0,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Dashboard'),
            selected: Sidebar._selectedIndex == 0,
            onTap: () => _onItemTapped(0),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Healing Milestone'),
            selected: Sidebar._selectedIndex == 1,
            onTap: () => _onItemTapped(1),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.article_outlined),
            title: const Text('Records'),
            selected: Sidebar._selectedIndex == 2,
            onTap: () => _onItemTapped(2),
          ),
          ListTile(
            leading: const Icon(Icons.edit_note),
            title: const Text('Notes'),
            selected: Sidebar._selectedIndex == 3,
            onTap: () => _onItemTapped(3),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Color.fromRGBO(255, 0, 0, 100),
            ),
            title: const Text(
              'Logout',
              style: TextStyle(color: Color.fromRGBO(255, 0, 0, 100)),
            ),
            onTap: () => _logout(),
          ),
        ],
      ),
    );
  }

  void _logout() {
    AuthService.logout();

    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
  }
}
