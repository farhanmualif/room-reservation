import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:zenith_coffee_shop/helper/thoudsand_input_formater.dart';
import 'package:zenith_coffee_shop/models/room.dart';
import 'package:zenith_coffee_shop/providers/room_provider.dart';
import 'package:zenith_coffee_shop/providers/room_services_provider.dart';
import 'package:zenith_coffee_shop/providers/room_type_class_provider.dart';
import 'package:zenith_coffee_shop/themes/app_color.dart';
import 'package:image_picker/image_picker.dart';

class AddRoomForm extends StatefulWidget {
  const AddRoomForm({super.key});

  @override
  State<AddRoomForm> createState() => _AddRoomFormState();
}

class _AddRoomFormState extends State<AddRoomForm> {
  final _formKey = GlobalKey<FormState>();

  final _nameControler = TextEditingController();
  final _serviceControler = TextEditingController();
  final _pricePerHourController = TextEditingController();
  final _roomTypeControler = TextEditingController();
  final _descriptionControler = TextEditingController();

  File? pickedImage;
  bool isPicked = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoomTypeClassProvider>().getAllTypes();
      context.read<RoomServicesProvider>().getAllServices();
    });
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference storageRef =
          FirebaseStorage.instance.ref().child('room_images/$fileName');
      final UploadTask uploadTask = storageRef.putFile(imageFile);
      final TaskSnapshot taskSnapshot = await uploadTask;
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Terjadi error ketika upload gambar"),
          backgroundColor: Colors.redAccent,
        ));
        return null;
      }
    }
    return null;
  }

  Future<String> _getImageUrl(BuildContext context) async {
    if (pickedImage != null) {
      final imageUrl = await _uploadImage(pickedImage!);
      if (imageUrl != null) {
        return imageUrl;
      }
    }

    // Use default image if no image is picked or upload fails
    final defaultImageRef = FirebaseStorage.instance
        .ref()
        .child('room_images/room-default-image.jpg');
    return await defaultImageRef.getDownloadURL();
  }

  Future<void> _saveRoom() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final imageUrl = await _getImageUrl(context);

      final room = Room(
        id: const Uuid().v4(),
        name: _nameControler.text,
        image: imageUrl,
        description: _descriptionControler.text,
        roomTypeId: _roomTypeControler.text,
        serviceId: _serviceControler.text,
        price: 0,
        pricePerHour: int.parse(
            _pricePerHourController.text.replaceAll(RegExp(r'[^0-9]'), '')),
        isAvailable: true,
      );
      if (mounted) {
        await context.read<RoomProvider>().create(room);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Berhasil Menyimpan data Room',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
      if (mounted) {
        await context.read<RoomProvider>().fetchRooms();
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving room: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text(
          "Form Tambah Ruangan",
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
      body: SingleChildScrollView(
        child: Consumer2<RoomServicesProvider, RoomTypeClassProvider>(
          builder: (context, roomServicesProvider, roomTypeProvider, child) {
            return Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(
                      child: GestureDetector(
                        onTap: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(
                              source: ImageSource.gallery);
                          if (image != null) {
                            pickedImage = File(image.path);
                            setState(() {
                              isPicked = true;
                            });
                          }
                        },
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.4,
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: isPicked
                              ? Stack(
                                  children: [
                                    // Profile Image (Square)
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        image: DecorationImage(
                                          image: FileImage(pickedImage!),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    // Edit Icon (Pencil)
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: InkWell(
                                        onTap: () {
                                          // Handle edit image action
                                        },
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.blue,
                                          ),
                                          padding: const EdgeInsets.all(8),
                                          child: const Icon(
                                            Icons.edit,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Stack(alignment: Alignment.center, children: [
                                  Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.4,
                                    width:
                                        MediaQuery.of(context).size.width * 0.5,
                                    decoration: BoxDecoration(
                                      color: Colors.blueGrey[100],
                                      image: isPicked
                                          ? DecorationImage(
                                              image: FileImage(pickedImage!),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                    child: !isPicked
                                        ? Icon(
                                            Icons.home,
                                            size: 80,
                                            color: Colors.blueGrey[300],
                                          )
                                        : null,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ]),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50.0),
                    // image picker
                    TextFormField(
                      controller: _nameControler,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama tdak bileh kosong';
                        }
                        return null;
                      },
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Nama Ruangan",
                        hintStyle:
                            TextStyle(color: Colors.white.withOpacity(0.7)),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonFormField<String>(
                        validator: (value) =>
                            value == null ? 'field required' : null,
                        decoration: InputDecoration(
                          hintText: "Tipe Class",
                          hintStyle:
                              TextStyle(color: Colors.white.withOpacity(0.7)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                        style: const TextStyle(color: Colors.white),
                        dropdownColor: Colors.grey[800],
                        items: roomTypeProvider.types.map((service) {
                          return DropdownMenuItem<String>(
                            value: service.id,
                            child: Text(service.name),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          if (value != null) {
                            _roomTypeControler.text = value;
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonFormField<String>(
                        validator: (value) =>
                            value == null ? 'field required' : null,
                        decoration: InputDecoration(
                          hintText: "Layanan",
                          hintStyle:
                              TextStyle(color: Colors.white.withOpacity(0.7)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                        style: const TextStyle(color: Colors.white),
                        dropdownColor: Colors.grey[800],
                        items: roomServicesProvider.services.map((service) {
                          return DropdownMenuItem<String>(
                            value: service.id,
                            child: Text(service.name),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          if (value != null) {
                            _serviceControler.text = value;
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Deskripsi tidak boleh kosong';
                        }
                        return null;
                      },
                      controller: _descriptionControler,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Deskripsi",
                        hintStyle:
                            TextStyle(color: Colors.white.withOpacity(0.7)),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _pricePerHourController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Harga per jam tidak boleh kosong';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        ThousandsSeparatorInputFormatter(),
                      ],
                      decoration: InputDecoration(
                        hintText: "Harga Per Jam",
                        hintStyle:
                            TextStyle(color: Colors.white.withOpacity(0.7)),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        prefixText: 'Rp ',
                        prefixStyle: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    const SizedBox(height: 32.0),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _saveRoom();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                        ),
                        child: _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                    color: Colors.white),
                              )
                            : const Text(
                                'Simpan',
                                style: TextStyle(color: Colors.black),
                              ),
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
  }
}
