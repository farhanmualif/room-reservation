import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zenith_coffee_shop/helper/idr_format_currency.dart';
import 'package:zenith_coffee_shop/providers/room_services_provider.dart';
import 'package:zenith_coffee_shop/screens/edit_room_services.dart';
import 'package:zenith_coffee_shop/themes/app_color.dart';

class ServiceListScreen extends StatefulWidget {
  const ServiceListScreen({super.key});

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  @override
  void initState() {
    super.initState();
    final roomProvider =
        Provider.of<RoomServicesProvider>(context, listen: false);
    roomProvider
        .getAllServices(); // Ambil data hanya sekali saat widget di-inisialisasi
  }

  Future<void> _refreshData() async {
    final roomProvider =
        Provider.of<RoomServicesProvider>(context, listen: false);
    await roomProvider.getAllServices(); // Ambil data terbaru
  }

  Future<void> _deleteService(String serviceId, String serviceName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.primary,
        title: const Text('Konfirmasi Hapus',
            style: TextStyle(color: Colors.white)),
        content: Text(
            'Apakah Anda yakin ingin menghapus layanan "$serviceName"?',
            style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        final roomProvider = context.read<RoomServicesProvider>();
        await roomProvider.deleteService(serviceId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Layanan berhasil dihapus')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus layanan: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RoomServicesProvider>(
      builder: (context, roomProvider, child) {
        return Scaffold(
          backgroundColor: AppColors.primary,
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).pushNamed("/add_room_service").then((_) {
                roomProvider.getAllServices(); // Refresh data setelah kembali
              });
            },
            backgroundColor: AppColors.secondary,
            child: const Icon(Icons.add),
          ),
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            leading: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: const Icon(Icons.arrow_back_ios, color: Colors.white),
            ),
            title: const Text(
              'Daftar Layanan',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: RefreshIndicator(
            onRefresh: _refreshData, // Fungsi yang dipanggil saat refresh
            child: roomProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : roomProvider.error != null
                    ? Center(child: Text(roomProvider.error!))
                    : roomProvider.services.isEmpty
                        ? const Center(
                            child: Text(
                              'Tidak ada layanan tersedia',
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : ListView.builder(
                            itemCount: roomProvider.services.length,
                            itemBuilder: (context, index) {
                              final service = roomProvider.services[index];
                              return Card(
                                color: AppColors.gray,
                                elevation: 0,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                child: ListTile(
                                  leading: Icon(
                                    Icons.cleaning_services,
                                    color: AppColors.secondary,
                                  ),
                                  title: Text(
                                    service.name,
                                    style:
                                        TextStyle(color: AppColors.secondary),
                                  ),
                                  subtitle: Text(
                                    currencyFormatter.format(service.price),
                                    style:
                                        TextStyle(color: AppColors.secondary),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      EditRoomServices(
                                                        id: service.id,
                                                        name: service.name,
                                                        price: service.price,
                                                      )));
                                        },
                                        icon: Icon(Icons.edit,
                                            color: AppColors.secondary),
                                      ),
                                      IconButton(
                                        onPressed: () => _deleteService(
                                            service.id, service.name),
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        );
      },
    );
  }
}
