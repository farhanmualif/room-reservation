import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zenith_coffee_shop/providers/auth_provider.dart';
import 'package:zenith_coffee_shop/providers/profiles_provider.dart';
import 'package:zenith_coffee_shop/screens/order_history.dart';
import 'package:zenith_coffee_shop/screens/order_room_form.dart';
import 'package:zenith_coffee_shop/screens/profile_page.dart';
import 'package:zenith_coffee_shop/screens/room_selection_screen.dart';
import 'package:zenith_coffee_shop/themes/app_color.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _children = [
    const RoomSelectionPage(),
    const OrderRoomForm(),
    const OrderHistoryPage(),
    const ProfilePage(),
  ];

  void onBarTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _initializeProfile();
  }

  void _initializeProfile() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = _firebaseAuth.currentUser?.uid ?? '';
      if (mounted) {
        context.read<ProfilesProvider>().fetchProfileByUid(uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: RefreshIndicator(
        color: AppColors.secondary,
        backgroundColor: AppColors.primary,
        onRefresh: () async {
          if (mounted) {
            final profileProvider = context.read<ProfilesProvider>();
            final authProvider = context.read<AuthProvider>();
            debugPrint('user id ${authProvider.currentUser?.uid}');
            await profileProvider
                .fetchProfileByUid(authProvider.currentUser?.uid ?? '');
          }
        },
        child: Consumer2<AuthProvider, ProfilesProvider>(
          builder: (context, authProvider, profileProvider, child) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: _children[_currentIndex],
              ),
            );
          },
        ),
      ),
      floatingActionButton: Consumer<ProfilesProvider>(
        builder: (context, profileProvider, child) {
          return profileProvider.currentProfile?.role == 'admin'
              ? FloatingActionButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/add_room_form');
                  },
                  backgroundColor: Colors.orange,
                  child: const Icon(Icons.add),
                )
              : const SizedBox.shrink();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
