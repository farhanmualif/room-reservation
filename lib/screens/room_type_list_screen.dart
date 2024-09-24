import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zenith_coffee_shop/providers/room_type_class_provider.dart';
import 'package:zenith_coffee_shop/themes/app_color.dart';

class RoomTypeListScreen extends StatefulWidget {
  const RoomTypeListScreen({super.key});

  @override
  State<RoomTypeListScreen> createState() => _RoomTypeListScreenState();
}

class _RoomTypeListScreenState extends State<RoomTypeListScreen> {
  @override
  void initState() {
    super.initState();
    final roomProvider = Provider.of<RoomTypeClassProvider>(context, listen: false);
    roomProvider.getAllTypes();
  }

  Future<void> _refreshData() async {
    final roomProvider = Provider.of<RoomTypeClassProvider>(context, listen: false);
    await roomProvider.getAllTypes(); // Ambil data terbaru
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RoomTypeClassProvider>(
      builder: (context, roomType, child) {
        return Scaffold(
          backgroundColor: AppColors.primary,
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).pushNamed("/add_type_room").then((_) {
                roomType.getAllTypes(); 
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
              'Daftar Type Ruangan',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: RefreshIndicator(
            onRefresh: _refreshData, // Fungsi yang dipanggil saat refresh
            child: roomType.isLoading
                ? const Center(child: CircularProgressIndicator())
                : roomType.error != null
                    ? Center(child: Text(roomType.error!))
                    : roomType.types.isEmpty
                        ? const Center(
                            child: Text(
                              'Tidak ada layanan tersedia',
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : ListView.builder(
                            itemCount: roomType.types.length,
                            itemBuilder: (context, index) {
                              final service = roomType.types[index];
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
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
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
