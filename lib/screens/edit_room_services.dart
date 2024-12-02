import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:zenith_coffee_shop/helper/thoudsand_input_formater.dart';
import 'package:zenith_coffee_shop/models/room_service.dart';
import 'package:zenith_coffee_shop/providers/room_services_provider.dart';
import 'package:zenith_coffee_shop/themes/app_color.dart';

class EditRoomServices extends StatefulWidget {
  final String name;
  final int price;
  final String id;

  const EditRoomServices({
    super.key,
    required this.name,
    required this.price,
    required this.id,
  });

  @override
  State<EditRoomServices> createState() => EditRoomServicesState();
}

class EditRoomServicesState extends State<EditRoomServices> {
  final _formKey = GlobalKey<FormState>();

  final _nameControler = TextEditingController();
  final _priceControler = TextEditingController();

  File? pickedImage;
  bool isPicked = false;
  bool _isLoading = false;

  @override
  void initState() {
    _nameControler.text = widget.name;
    _priceControler.text = widget.price.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final roomServicesProvider =
        Provider.of<RoomServicesProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text(
          "Edit Layanan Ruangan",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.black,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // image picker
              TextFormField(
                controller: _nameControler,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Nama",
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                keyboardType: TextInputType.number,
                controller: _priceControler,
                style: const TextStyle(color: Colors.white),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  ThousandsSeparatorInputFormatter(),
                ],
                decoration: InputDecoration(
                  hintText: "Harga",
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 16.0),
              const SizedBox(height: 32.0),
              Center(
                child: ElevatedButton(
                  onPressed: () async { 
                    setState(() {
                      _isLoading = true;
                    });
                    if (_formKey.currentState!.validate()) {
                      final price = int.parse(_priceControler.text
                          .replaceAll(RegExp(r'[^0-9]'), ''));

                      RoomService updatedService = RoomService(
                        id: widget.id,
                        name: _nameControler.text,
                        price: price,
                      );

                      try {
                        final provider = context.read<RoomServicesProvider>();
                        await provider.updateService(widget.id, updatedService);

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Layanan berhasil diupdate')),
                          );
                          Navigator.pop(context);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Gagal mengupdate layanan: $e')),
                          );
                        }
                      } finally {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                  ),
                  child: const Text(
                    'Simpan',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
