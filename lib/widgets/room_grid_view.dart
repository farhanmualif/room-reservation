import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zenith_coffee_shop/helper/idr_format_currency.dart';
import 'package:zenith_coffee_shop/models/room.dart';
import 'package:zenith_coffee_shop/providers/room_provider.dart';
import 'package:zenith_coffee_shop/themes/app_color.dart';

class RoomGridView extends StatelessWidget {
  final String? typeClassId;
  const RoomGridView({super.key, this.typeClassId});

  void _selectRoomAndNavigate(
      BuildContext context, RoomProvider roomsProvider, int index) {
    roomsProvider.selectRoom(roomsProvider.rooms[index]);
    Navigator.of(context).pushNamed("/detail_room");
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RoomProvider>(
      builder: (context, roomsProvider, child) {
        List<Room> getRooms = roomsProvider.rooms;

        if (roomsProvider.rooms.isEmpty) {
          return const Center(
            child: Text(
              'Tidak ada kamar tersedia',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        if (typeClassId != null && typeClassId != "All") {
          getRooms = roomsProvider.rooms
              .where((room) => room.roomTypeId == typeClassId)
              .toList();
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 9 / 16,
          ),
          itemCount: getRooms.length,
          itemBuilder: (context, index) {
            final room = getRooms[index];
            return GestureDetector(
              onTap: () =>
                  _selectRoomAndNavigate(context, roomsProvider, index),
              child: Card(
                color: AppColors.gray,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(12)),
                      child: room.image != null && room.image!.isNotEmpty
                          ? FadeInImage.assetNetwork(
                              placeholder: 'assets/images/placeholder.png',
                              image: room.image!,
                              width: double.infinity,
                              height: 176,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: double.infinity,
                              height: 176,
                              color: Colors.grey,
                              child: const Icon(Icons.image,
                                  size: 50, color: Colors.white),
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            room.name ?? 'Kamar Tanpa Nama',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            room.description ?? 'Tidak ada deskripsi',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            currencyFormatter.format(room.price ?? 0.0),
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
