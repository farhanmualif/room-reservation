import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zenith_coffee_shop/providers/auth_provider.dart';
import 'package:zenith_coffee_shop/providers/profiles_provider.dart';
import 'package:zenith_coffee_shop/screens/order_history.dart';
import 'package:zenith_coffee_shop/screens/profile_page.dart';
import 'package:zenith_coffee_shop/screens/room_selection_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _children = [
    const RoomSelectionPage(),
    const ProfilePage(),
    OrderHistoryPage(),
    const ProfilePage(),
  ];

  void onBarTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ProfilesProvider>(
      builder: (context, authProvider, profileProvider, child) {
        if (profileProvider.currentProfile == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            profileProvider
                .fetchProfileByUid(authProvider.currentUser?.uid ?? '');
          });
          return const Center(child: CircularProgressIndicator());
        }

        final isAdmin = profileProvider.currentProfile?.role == 'admin';

        return Scaffold(
          body: _children[_currentIndex],
          bottomNavigationBar: !isAdmin
              ? BottomNavigationBar(
                  currentIndex: _currentIndex,
                  onTap: onBarTapped,
                  type: BottomNavigationBarType.fixed,
                  showSelectedLabels: false,
                  showUnselectedLabels: false,
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home_outlined),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.date_range),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.shopping_bag_outlined),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person_2_outlined),
                      label: '',
                    ),
                  ],
                )
              : null,
          floatingActionButton: isAdmin
              ? FloatingActionButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed("/add_room_form");
                  },
                  backgroundColor: Colors.orange,
                  child: const Icon(
                      Icons.add), // Sesuaikan dengan warna pada gambar
                )
              : null,
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },
    );
  }
}
