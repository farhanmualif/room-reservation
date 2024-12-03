import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:zenith_coffee_shop/helper/idr_format_currency.dart';
import 'package:zenith_coffee_shop/providers/auth_provider.dart';
import 'package:zenith_coffee_shop/providers/profiles_provider.dart';
import 'package:zenith_coffee_shop/providers/room_provider.dart';
import 'package:zenith_coffee_shop/screens/home_screen.dart';
import 'package:zenith_coffee_shop/themes/app_color.dart';

class RoomDetailScreen extends StatefulWidget {
  const RoomDetailScreen({super.key});

  @override
  State<RoomDetailScreen> createState() => RoomDetailScreenState();
}

class RoomDetailScreenState extends State<RoomDetailScreen> {
  DetailRoom? roomDetail;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRoomDetail();
  }

  Future<void> _loadRoomDetail() async {
    final roomProvider = Provider.of<RoomProvider>(context, listen: false);

    final selectedRoomId = roomProvider.selectedRoom!.id;

    if (selectedRoomId == null) {
      setState(() {
        errorMessage = 'No room selected';
        isLoading = false;
      });
      return;
    }

    try {
      final detail = await roomProvider.getRoomDetail(selectedRoomId);
      setState(() {
        roomDetail = detail;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load room details: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        body: Center(
            child:
                Text(errorMessage!, style: const TextStyle(color: Colors.red))),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.primary,
            expandedHeight: 500,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                margin: const EdgeInsets.all(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      roomDetail!.room.image,
                      fit: BoxFit.cover,
                      height: MediaQuery.of(context).size.height * 0.6,
                    ),
                    Positioned(
                      left: 0,
                      bottom: 0,
                      right: 0,
                      child: ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "${roomDetail!.room.name} ${roomDetail!.roomType.name}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    // const Row(
                                    //   children: [
                                    //     Icon(Icons.star,
                                    //         color: Colors.orange, size: 18),
                                    //     SizedBox(width: 4),
                                    //     Text(
                                    //       '4.6 (1,250)',
                                    //       style: TextStyle(color: Colors.white),
                                    //     ),
                                    //   ],
                                    // )
                                  ],
                                ),
                                ReadMoreText(
                                  roomDetail!.room.description!,
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        currencyFormatter.format(
                                            roomDetail!.room.pricePerHour),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    // ElevatedButton(
                                    //   onPressed: () {},
                                    //   style: ElevatedButton.styleFrom(
                                    //     backgroundColor: AppColors.secondary,
                                    //     shape: RoundedRectangleBorder(
                                    //         borderRadius:
                                    //             BorderRadius.circular(10)),
                                    //   ),
                                    //   child: const Text(
                                    //     "Add To Cart",
                                    //     style: TextStyle(color: Colors.white),
                                    //   ),
                                    // )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            leading: Container(
              height: 30,
              width: 30,
              margin: const EdgeInsets.only(left: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20), color: Colors.black),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Description',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    roomDetail!.room.description,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  Consumer3<AuthProvider, ProfilesProvider, RoomProvider>(
                    builder: (context, authProvider, profileProvider,
                        roomProvider, child) {
                      if (profileProvider.currentProfile == null) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          profileProvider.fetchProfileByUid(
                              authProvider.currentUser?.uid ?? '');
                        });
                        return const Center(
                            child:
                                CircularProgressIndicator()); // Tampilkan loading
                      }

                      final isAdmin =
                          profileProvider.currentProfile?.role == 'admin';
                      return isAdmin
                          ? Column(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    roomProvider.selectDetailRoom(roomDetail!);
                                    Navigator.of(context)
                                        .pushNamed("/update_room_form");
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.secondary,
                                    minimumSize:
                                        const Size(double.infinity, 50),
                                  ),
                                  child: const Text(
                                    'Update',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                ElevatedButton(
                                  onPressed: () => _deleteRoom(
                                      context, roomDetail!.room.id!),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.secondary,
                                    minimumSize:
                                        const Size(double.infinity, 50),
                                  ),
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                )
                              ],
                            )
                          : ElevatedButton(
                              onPressed: () {
                                roomProvider.selectDetailRoom(roomDetail!);
                                Navigator.of(context)
                                    .pushNamed("/order_room_form");
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              child: const Text(
                                'Next',
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteRoom(BuildContext context, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.primary,
        title: const Text('Konfirmasi', style: TextStyle(color: Colors.white)),
        content: const Text('Apakah Anda yakin ingin menghapus Room ini?',
            style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!context.mounted) return;
      final roomProvider = context.read<RoomProvider>();
      final authProvider = context.read<AuthProvider>();
      final profileProvider = context.read<ProfilesProvider>();

      await roomProvider.deleteRoom(id);
      await profileProvider
          .fetchProfileByUid(authProvider.currentUser?.uid ?? '');

      if (context.mounted) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()));
        await roomProvider.fetchRooms(); // Refresh daftar room
      }
    }
  }
}
