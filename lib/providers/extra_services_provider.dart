// File: extra_services_provider.dart
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:zenith_coffee_shop/models/extra_service.dart';

class ExtraServicesProvider with ChangeNotifier {
  final List<ExtraService> _extraServices = [];

  static final DatabaseReference _firebaseInstance =
      FirebaseDatabase.instance.ref();

  List<ExtraService> get extraServices => _extraServices;

  final List<ExtraService> _extraServicesSelected = [];
  List<ExtraService> get extraServicesSelected => _extraServicesSelected;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _error;
  String? get error => _error;

  ExtraService? _currentExtraService;
  ExtraService? get currentService => _currentExtraService;

  void selectExtraServices(ExtraService extraService) {
    extraService.isSelected = true;
    if (!_extraServicesSelected.contains(extraService)) {
      _extraServicesSelected.add(extraService);
      notifyListeners();
    }
  }

  void removeExtraService(String id) {
    final service = _extraServices.firstWhere((service) => service.id == id);
    service.isSelected = false;
    _extraServicesSelected.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  Future<void> create(ExtraService extraService) async {
    try {
      Map<String, dynamic> data = {
        "id": extraService.id,
        "name": extraService.name,
        "price": extraService.price
      };
      await _firebaseInstance.child("extra_services").push().set(data);
    } catch (e) {
      debugPrint("Failed to create Service: $e");
    }
  }

  static Future<void> update(String key, ExtraService extraService) async {
    try {
      Map<String, dynamic> data = {
        "id": extraService.id,
        "name": extraService.name,
        "price": extraService.price,
      };
      await _firebaseInstance.child("extra_services").child(key).update(data);
    } catch (e) {
      debugPrint("Failed to update Service: $e");
    }
  }

  Future<List<ExtraService>> getAllExtraService() async {
    try {
      _extraServices.clear();

      List<ExtraService> rooms = [];
      DataSnapshot snapshot =
          await _firebaseInstance.child("extra_services").get();

      if (snapshot.value != null) {
        (snapshot.value as Map).forEach((key, value) {
          Map<String, dynamic> data = Map<String, dynamic>.from(value);

          _extraServices.add(ExtraService(
            id: key,
            name: data["name"],
            price: data["price"],
          ));
        });
      } else {
        debugPrint("Snapshot is null");
      }

      debugPrint("extra services loaded: ${rooms.length}");
      notifyListeners();
      return rooms;
    } catch (e) {
      debugPrint("Failed to get Rooms: $e");
      return [];
    }
  }

  Future<void> fetchExtraServiceByUid(String uid) async {
    _isLoading = true;
    notifyListeners();

    try {
      DatabaseEvent event =
          await _firebaseInstance.child("extra_services").child(uid).once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        var extraService = snapshot.value as Map<dynamic, dynamic>;
        _currentExtraService = ExtraService(
            id: extraService["id"] ?? "",
            name: extraService["name"] ?? "",
            price: extraService["price"] ?? "",
            isSelected: extraService["isSelected"] ?? "");
      } else {
        _currentExtraService = null;
        print("No Service found for uid: $uid");
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint("Failed to fetch Service: $e");
      _currentExtraService = null;
      _error = "Failed to fetch Service: $e";
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteExtraService(String id) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firebaseInstance.child("extra_services").child(id).remove();

      // Hapus dari list lokal
      _extraServices.removeWhere((service) => service.id == id);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = "Gagal menghapus layanan: $e";
      _isLoading = false;
      notifyListeners();
      throw Exception(_error);
    }
  }

  Future<void> updateExtraService(String id, ExtraService service) async {
    try {
      _isLoading = true;
      notifyListeners();

      Map<String, dynamic> data = {
        "name": service.name,
        "price": service.price,
      };

      await _firebaseInstance.child("extra_services").child(id).update(data);

      // Update list lokal
      final index = _extraServices.indexWhere((s) => s.id == id);
      if (index != -1) {
        _extraServices[index] = service;
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

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }
}
