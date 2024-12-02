import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:zenith_coffee_shop/helper/thoudsand_input_formater.dart';
import 'package:zenith_coffee_shop/models/extra_service.dart';
import 'package:zenith_coffee_shop/models/room_service.dart';
import 'package:zenith_coffee_shop/providers/extra_services_provider.dart';
import 'package:zenith_coffee_shop/providers/room_services_provider.dart';
import 'package:zenith_coffee_shop/themes/app_color.dart';

class EditExtraServices extends StatefulWidget {
  final String name;
  final int price;
  final String id;

  const EditExtraServices({
    super.key,
    required this.name,
    required this.price,
    required this.id,
  });

  @override
  State<EditExtraServices> createState() => _EditExtraServicesState();
}

class _EditExtraServicesState extends State<EditExtraServices> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    _nameController.text = widget.name;
    _priceController.text = widget.price.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text("Edit Extra Layanan",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Nama Layanan",
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
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
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() => _isLoading = true);

                          try {
                            final price = int.parse(_priceController.text
                                .replaceAll(RegExp(r'[^0-9]'), ''));

                            final service = ExtraService(
                              id: widget.id,
                              name: _nameController.text,
                              price: price,
                            );

                            await context
                                .read<ExtraServicesProvider>()
                                .updateExtraService(widget.id, service);

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
                                    content:
                                        Text('Gagal mengupdate layanan: $e')),
                              );
                            }
                          } finally {
                            if (context.mounted) {
                              setState(() => _isLoading = false);
                            }
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Simpan',
                        style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
