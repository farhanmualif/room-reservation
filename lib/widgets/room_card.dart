import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zenith_coffee_shop/helper/idr_format_currency.dart';
import 'package:zenith_coffee_shop/models/room.dart';
import 'package:zenith_coffee_shop/providers/extra_services_provider.dart';
import 'package:zenith_coffee_shop/themes/app_color.dart';

class RoomCard extends StatelessWidget {
  final Room room;
  final bool isSelected;

  const RoomCard({
    super.key,
    required this.room,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.55,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.secondary : Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: room.image != null && room.image!.isNotEmpty
                ? Image.network(
                    room.image!,
                    width: 300,
                    height: 276,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print('Error saat memuat gambar: $error');
                      return Container(
                        width: 300,
                        height: 276,
                        color: Colors.grey,
                        child: const Icon(Icons.error,
                            size: 50, color: Colors.white),
                      );
                    },
                  )
                : Container(
                    width: 300,
                    height: 276,
                    color: Colors.grey,
                    child:
                        const Icon(Icons.image, size: 50, color: Colors.white),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.name ?? 'Kamar Tanpa Nama',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  room.description ?? 'Tidak ada deskripsi',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  currencyFormatter.format(room.pricePerHour),
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
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
        title: const Text(
          'Konfirmasi',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Apakah Anda yakin ingin menghapus layanan ini?',
          style: TextStyle(color: Colors.white),
        ),
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
      if (context.mounted) {
        await context.read<ExtraServicesProvider>().deleteExtraService(id);
      }
    }
  }
}
