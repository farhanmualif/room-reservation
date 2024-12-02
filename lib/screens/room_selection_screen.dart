import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zenith_coffee_shop/main.dart';
import 'package:zenith_coffee_shop/models/room.dart';
import 'package:zenith_coffee_shop/providers/auth_provider.dart';
import 'package:zenith_coffee_shop/providers/profiles_provider.dart';
import 'package:zenith_coffee_shop/providers/room_provider.dart';
import 'package:zenith_coffee_shop/providers/room_type_class_provider.dart';
import 'package:zenith_coffee_shop/screens/room_detail_screen.dart';
import 'package:zenith_coffee_shop/themes/app_color.dart';
import 'package:zenith_coffee_shop/widgets/room_card.dart';
import 'package:zenith_coffee_shop/widgets/room_grid_view.dart';

class RoomSelectionPage extends StatefulWidget {
  const RoomSelectionPage({super.key});

  @override
  State<RoomSelectionPage> createState() => _RoomSelectionPageState();
}

class _RoomSelectionPageState extends State<RoomSelectionPage> {
  // ===== PROPERTIES =====
  File? pickedImage;
  bool isPicked = false;
  String _classRoomSelected = "All";
  String? _classIdSelected;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // ===== LIFECYCLE METHODS =====
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _initializeData() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final roomProvider = Provider.of<RoomProvider>(context, listen: false);
      final profileProvider =
          Provider.of<ProfilesProvider>(context, listen: false);
      final roomTypeProvider =
          Provider.of<RoomTypeClassProvider>(context, listen: false);

      try {
        await Future.wait([
          roomProvider.fetchRooms(),
          profileProvider
              .fetchProfileByUid(authProvider.currentUser?.uid ?? ''),
          roomTypeProvider.getAllTypes(),
        ]);
      } catch (e) {
        debugPrint('Error initializing data: $e');
      }
    });
  }

  Future<void> _refreshData() async {
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final roomProvider = context.read<RoomProvider>();
    final profileProvider = context.read<ProfilesProvider>();
    final roomTypeProvider = context.read<RoomTypeClassProvider>();
    debugPrint('user id ${authProvider.currentUser?.uid}');
    await roomProvider.fetchRooms();
    await profileProvider
        .fetchProfileByUid(authProvider.currentUser?.uid ?? '');
    await roomTypeProvider.getAllTypes();
  }

  void _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyApp()),
      );
    }
  }

  void _onRoomTap(Room room, RoomProvider roomProvider) {
    roomProvider.selectRoom(room);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RoomDetailScreen(),
      ),
    );
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildRoomList(),
                const SizedBox(height: 32),
                _buildPopularSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Text(
      'Pilih Ruangan Kamu!',
      style: TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildRoomList() {
    return Consumer<RoomProvider>(
      builder: (context, roomProvider, child) {
        if (roomProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (roomProvider.error != null) {
          return Center(child: Text(roomProvider.error!));
        } else if (roomProvider.rooms.isEmpty) {
          return const Center(
              child: Text(
            'Tidak ada kamar tersedia',
            style: TextStyle(color: Colors.white),
          ));
        }

        final filteredRooms = roomProvider.rooms.where((room) {
          final name = room.name.toLowerCase();
          final description = room.description.toLowerCase();
          return name.contains(_searchQuery) ||
              description.contains(_searchQuery);
        }).toList();

        if (filteredRooms.isEmpty) {
          return const Center(
              child: Text(
            'Tidak ada ruangan yang sesuai pencarian',
            style: TextStyle(color: Colors.white),
          ));
        }

        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.45,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: filteredRooms.length,
            itemBuilder: (context, index) {
              final room = filteredRooms[index];
              return GestureDetector(
                onTap: () => _onRoomTap(room, roomProvider),
                child: Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: RoomCard(
                    room: room,
                    isSelected: room == roomProvider.selectedRoom,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPopularSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Populer Sekarang',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildFilterChips(),
        const SizedBox(height: 16),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: RoomGridView(typeClassId: _classIdSelected),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return Consumer<RoomTypeClassProvider>(
      builder: (context, roomTypeClassProvider, child) {
        return Wrap(
          spacing: 8,
          children: [
            FilterChip(
              selectedColor: AppColors.secondary,
              label: const Text("All"),
              onSelected: (value) {
                setState(() {
                  _classRoomSelected = "All";
                  _classIdSelected = null;
                });
              },
              selected: _classRoomSelected == "All",
            ),
            ...roomTypeClassProvider.types
                .map((chips) => FilterChip(
                      selectedColor: AppColors.secondary,
                      label: Text(chips.name),
                      onSelected: (value) {
                        setState(() {
                          _classRoomSelected = chips.name;
                          _classIdSelected = chips.id;
                        });
                      },
                      selected: chips.name == _classRoomSelected,
                    ))
                .toList()
          ],
        );
      },
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppColors.gray,
      child: ListView(
        children: [
          const DrawerHeader(
            child: Column(
              children: [
                Text(
                  "Menu",
                  style: TextStyle(color: Colors.white),
                ),
                // Center(
                //   child: GestureDetector(
                //     onTap: () async {
                //       final ImagePicker picker = ImagePicker();
                //       final XFile? image =
                //           await picker.pickImage(source: ImageSource.gallery);
                //       if (image != null) {
                //         pickedImage = File(image.path);
                //         setState(() {
                //           isPicked = true;
                //         });
                //       }
                //     },
                //     child: Container(
                //       child: isPicked
                //           ? Stack(
                //               children: [
                //                 // Profile Image
                //                 CircleAvatar(
                //                   radius: MediaQuery.of(context).size.width *
                //                       0.20, // Set radius
                //                   backgroundImage: FileImage(
                //                       pickedImage!), // Use pickedImage
                //                 ),
                //                 // Edit Icon (Pencil)
                //                 Positioned(
                //                   bottom: 0,
                //                   right: 0,
                //                   child: InkWell(
                //                     onTap: () {
                //                       // Handle edit image action
                //                     },
                //                     child: Container(
                //                       decoration: const BoxDecoration(
                //                         shape: BoxShape.circle,
                //                         color: Colors
                //                             .blue, // Background color of the pencil icon
                //                       ),
                //                       padding: const EdgeInsets.all(
                //                           8), // Padding for better look
                //                       child: const Icon(
                //                         Icons.edit, // Pencil icon
                //                         color: Colors.white, // Icon color
                //                         size: 20,
                //                       ),
                //                     ),
                //                   ),
                //                 ),
                //               ],
                //             )
                //           : Container(
                //               color: Colors.blueGrey[100],
                //               height: MediaQuery.of(context).size.height * 0.1,
                //               width: MediaQuery.of(context).size.width * 0.2,
                //             ),
                //     ),
                //   ),
                // )
              ],
            ),
          ),
          Consumer2<AuthProvider, ProfilesProvider>(
            builder: (context, authProvider, profileProvider, child) {
              if (profileProvider.currentProfile == null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  profileProvider
                      .fetchProfileByUid(authProvider.currentUser?.uid ?? '');
                });
                return const Center(
                    child: CircularProgressIndicator()); // Tampilkan loading
              }

              final isAdmin = profileProvider.currentProfile?.role == 'admin';

              return isAdmin
                  ? Column(
                      children: [
                        ListTile(
                          leading: const Icon(
                            Icons.room_service_outlined, // Icon logout
                            color: Colors.white, // Warna ikon
                          ),
                          title: const Text(
                            'Layanan',
                            style: TextStyle(color: Colors.white),
                          ),
                          onTap: () {
                            Navigator.of(context).pushNamed("/service_list");
                          },
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.food_bank_outlined,
                            color: Colors.white,
                          ),
                          title: const Text(
                            'Extra Layanan',
                            style: TextStyle(color: Colors.white),
                          ),
                          onTap: () {
                            Navigator.of(context)
                                .pushNamed("/extra_service_list");
                          },
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.checklist,
                            color: Colors.white,
                          ),
                          title: const Text(
                            'Histori Pemesanan',
                            style: TextStyle(color: Colors.white),
                          ),
                          onTap: () {
                            Navigator.of(context).pushNamed("/order_history");
                          },
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.class_outlined,
                            color: Colors.white,
                          ),
                          title: const Text(
                            'Tipe Kelas Ruangan',
                            style: TextStyle(color: Colors.white),
                          ),
                          onTap: () {
                            Navigator.of(context).pushNamed("/room_type_list");
                          },
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.logout,
                            color: Colors.white,
                          ),
                          title: const Text(
                            'Logout',
                            style: TextStyle(color: Colors.white),
                          ),
                          onTap: () => _handleLogout(), // Fungsi logout
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        ListTile(
                          leading: const Icon(
                            Icons.logout, // Icon logout
                            color: Colors.white, // Warna ikon
                          ),
                          title: const Text(
                            'Logout',
                            style: TextStyle(color: Colors.white),
                          ),
                          onTap: () => _handleLogout(), // Fungsi logout
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.checklist,
                            color: Colors.white,
                          ),
                          title: const Text(
                            'Histori Pemesanan',
                            style: TextStyle(color: Colors.white),
                          ),
                          onTap: () {
                            Navigator.of(context)
                                .pushNamed("/user_order_history");
                          },
                        )
                      ],
                    );
            },
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      leading: Builder(
        builder: (BuildContext context) {
          return IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          );
        },
      ),
      title: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Cari ruangan...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.search, color: Colors.white),
        ),
        onChanged: _onSearchChanged,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.favorite_border, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }
}
