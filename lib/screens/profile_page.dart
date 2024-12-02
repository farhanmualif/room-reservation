import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zenith_coffee_shop/providers/profiles_provider.dart';
import 'package:zenith_coffee_shop/themes/app_color.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _isLoading = false;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

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
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      title: const Text(
        'Profile Page',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<ProfilesProvider>(
      builder: (context, profile, child) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProfileImage(),
                const SizedBox(height: 40),
                _buildUsernameField(profile),
                const SizedBox(height: 16),
                _buildEmailField(),
                const SizedBox(height: 16),
                _buildPhoneField(profile),
                const SizedBox(height: 16),
                _buildRoleField(profile),
                const SizedBox(height: 24),
                _buildSaveButton(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileImage() {
    return Container(
      width: 120,
      height: 120,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: Image.network(
        'https://picsum.photos/seed/picsum/200/300',
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildUsernameField(ProfilesProvider profile) {
    return TextField(
      style: const TextStyle(color: Colors.white),
      decoration: _buildInputDecoration(
        hintText: "Nama: ${profile.currentProfile?.username}",
      ),
    );
  }

  Widget _buildEmailField() {
    return TextField(
      style: const TextStyle(color: Colors.white),
      decoration: _buildInputDecoration(
        hintText: "Email: ${_firebaseAuth.currentUser?.email}",
      ),
    );
  }

  Widget _buildPhoneField(ProfilesProvider profile) {
    return TextField(
      style: const TextStyle(color: Colors.white),
      decoration: _buildInputDecoration(
        hintText: "No Handphone: ${profile.currentProfile?.phoneNumber}",
      ),
    );
  }

  Widget _buildRoleField(ProfilesProvider profile) {
    if (profile.currentProfile?.role != "admin") return const SizedBox.shrink();

    return TextField(
      style: const TextStyle(color: Colors.white),
      decoration: _buildInputDecoration(
        hintText: "Role: ${profile.currentProfile?.role}",
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: () {
        debugPrint("click");
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: _isLoading
          ? CircularProgressIndicator(
              color: AppColors.secondary,
            )
          : const Text(
              'Simpan',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
    );
  }

  InputDecoration _buildInputDecoration({required String hintText}) {
    return InputDecoration(
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.2),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
