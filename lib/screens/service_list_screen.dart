import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zenith_coffee_shop/helper/idr_format_currency.dart';
import 'package:zenith_coffee_shop/providers/room_services_provider.dart';
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
                                          // Action for Edit
                                          print('Edit: ${service.name}');
                                        },
                                        icon: Icon(Icons.edit,
                                            color: AppColors.secondary),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          print('Delete: ${service.name}');
                                        },
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
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
