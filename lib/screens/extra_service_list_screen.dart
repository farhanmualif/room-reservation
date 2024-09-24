import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zenith_coffee_shop/helper/idr_format_currency.dart';
import 'package:zenith_coffee_shop/providers/extra_services_provider.dart';
import 'package:zenith_coffee_shop/themes/app_color.dart';

class ExtraServiceListScreen extends StatefulWidget {
  const ExtraServiceListScreen({super.key});

  @override
  State<ExtraServiceListScreen> createState() => _ExtraServiceListScreenState();
}

class _ExtraServiceListScreenState extends State<ExtraServiceListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExtraServicesProvider>().getAllExtraService();
    });
  }

  Future<void> _refreshData() async {
    await context.read<ExtraServicesProvider>().getAllExtraService();
  }

  Future<void> _deleteService(BuildContext context, String id) async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .pushNamed("/add_room_extra_service")
              .then((_) => _refreshData());
        },
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: const Text('Daftar Extra Layanan',
            style: TextStyle(color: Colors.white)),
      ),
      body: Consumer<ExtraServicesProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (provider.error != null) {
            return Center(
                child: Text(provider.error!,
                    style: const TextStyle(color: Colors.white)));
          } else if (provider.extraServices.isEmpty) {
            return const Center(
                child: Text('Tidak ada layanan tersedia',
                    style: TextStyle(color: Colors.white)));
          }

          return RefreshIndicator(
            onRefresh: _refreshData,
            child: ListView.builder(
              itemCount: provider.extraServices.length,
              itemBuilder: (context, index) {
                final service = provider.extraServices[index];
                return Card(
                  color: AppColors.gray,
                  elevation: 0,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: Icon(Icons.cleaning_services,
                        color: AppColors.secondary),
                    title: Text(service.name,
                        style: TextStyle(color: AppColors.secondary)),
                    subtitle: Text(currencyFormatter.format(service.price),
                        style: TextStyle(color: AppColors.secondary)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            print('Edit: ${service.name}');
                          },
                          icon: Icon(Icons.edit, color: AppColors.secondary),
                        ),
                        IconButton(
                          onPressed: () => _deleteService(context, service.id),
                          icon: const Icon(Icons.delete, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
