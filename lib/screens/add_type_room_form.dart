import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:zenith_coffee_shop/models/room_type_class.dart';
import 'package:zenith_coffee_shop/providers/room_type_class_provider.dart';
import 'package:zenith_coffee_shop/themes/app_color.dart';

class AddTypeRoomForm extends StatefulWidget {
  const AddTypeRoomForm({super.key});

  @override
  State<AddTypeRoomForm> createState() => _AddTypeRoomFormState();
}

class _AddTypeRoomFormState extends State<AddTypeRoomForm> {
  final _formKey = GlobalKey<FormState>();

  final _nameControler = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final roomServicesProvider =
        Provider.of<RoomTypeClassProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text(
          "Tambah Layanan Ruangan",
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

              const SizedBox(height: 32.0),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      String name = _nameControler.text;
                      RoomTypeClass newService = RoomTypeClass(
                        id: const Uuid().v4(),
                        name: name,
                      );
                      roomServicesProvider
                          .create(newService); // Create a new service
                      Navigator.pop(context);
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
