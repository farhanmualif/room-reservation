import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:zenith_coffee_shop/models/room_service.dart';

class RoomServicesProvider with ChangeNotifier {
  static final DatabaseReference _firebaseInstance =
      FirebaseDatabase.instance.ref();

  final List<RoomService> _roomServices = [];
  List<RoomService> get services => _roomServices;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;
  RoomService? _currentService;
  RoomService? get currentService => _currentService;

  Future<void> create(RoomService service) async {
    try {
      Map<String, dynamic> data = {
        "id": service.id,
        "name": service.name,
        "price": service.price,
      };
      await _firebaseInstance.child("room_services").push().set(data);
    } catch (e) {
      debugPrint("Failed to create Service: $e");
    }
  }

  static Future<void> update(String key, RoomService service) async {
    try {
      Map<String, dynamic> data = {
        "id": service.id,
        "name": service.name,
        "price": service.price,
      };
      await _firebaseInstance.child("Services").child(key).update(data);
    } catch (e) {
      debugPrint("Failed to update Service: $e");
    }
  }

  Future<List<RoomService>> getAllServices() async {
    try {
      // Kosongkan daftar layanan sebelum mengambil yang baru
      _roomServices.clear();

      List<RoomService> services = [];
      DataSnapshot snapshot =
          await _firebaseInstance.child("room_services").get();

      debugPrint("Snapshot data: ${snapshot.value}"); // Log data Firebase

      if (snapshot.value != null) {
        for (var child in snapshot.children) {
          Map<String, dynamic> data =
              Map<String, dynamic>.from(child.value as Map);
          RoomService service = RoomService(
            id: child.key!,
            name: data["name"],
            price: data["price"],
          );
          _roomServices.add(service);
          services.add(service);
        }
      } else {
        debugPrint("Snapshot is null");
      }

      debugPrint("Services loaded: ${services.length}");
      notifyListeners(); // Panggil notifyListeners agar UI ter-update
      return services;
    } catch (e) {
      debugPrint("Failed to get Services: $e");
      return [];
    }
  }

  static Future<RoomService?> getById(String roomTypeId) async {
    DatabaseReference roomServiceRef = FirebaseDatabase.instance
        .ref()
        .child("room_services")
        .child(roomTypeId);

    DatabaseEvent event = await roomServiceRef.once();
    DataSnapshot snapshot = event.snapshot;

    if (snapshot.exists) {
      var roomServiceData = snapshot.value as Map<dynamic, dynamic>;
      return RoomService(
          id: roomServiceData["id"],
          name: roomServiceData["name"],
          price: roomServiceData["price"]);
    } else {
      return null;
    }
  }

  Future<void> fetchServiceByUid(String uid) async {
    // Set isLoading to true before fetching data
    _isLoading = true;
    notifyListeners();

    try {
      DatabaseEvent event =
          await _firebaseInstance.child("room_services").child(uid).once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        var serviceData = snapshot.value as Map<dynamic, dynamic>;
        _currentService = RoomService(
          id: uid,
          name: serviceData["name"] ?? "",
          price: serviceData["price"] ?? "",
        );
      } else {
        _currentService = null;
        print("No Service found for uid: $uid");
      }
      // Set isLoading to false after data is fetched successfully
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint("Failed to fetch Service: $e");
      _currentService = null;
      _error = "Failed to fetch Service: $e";
      // Set isLoading to false after fetching data fails
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteService(String serviceId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firebaseInstance.child("room_services").child(serviceId).remove();

      // Hapus dari list lokal
      _roomServices.removeWhere((service) => service.id == serviceId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = "Gagal menghapus layanan: $e";
      _isLoading = false;
      notifyListeners();
      throw Exception(_error);
    }
  }

  Future<void> updateService(String id, RoomService service) async {
    try {
      _isLoading = true;
      notifyListeners();

      Map<String, dynamic> data = {
        "name": service.name,
        "price": service.price,
      };

      await _firebaseInstance.child("room_services").child(id).update(data);

      // Update list lokal
      final index = _roomServices.indexWhere((s) => s.id == id);
      if (index != -1) {
        _roomServices[index] = service;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = "Gagal mengupdate layanan: $e";
      _isLoading = false;
      notifyListeners();
      throw Exception(_error);
    }
  }
}
