import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:zenith_coffee_shop/models/room_type_class.dart';

class RoomTypeClassProvider with ChangeNotifier {
  static final DatabaseReference _firebaseInstance =
      FirebaseDatabase.instance.ref();

  final List<RoomTypeClass> _roomType = [];
  List<RoomTypeClass> get types => _roomType;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;
  RoomTypeClass? _currentTypes;
  RoomTypeClass? get currentTypes => _currentTypes;

  Future<void> create(RoomTypeClass type) async {
    try {
      Map<String, dynamic> data = {
        "id": type.id,
        "name": type.name,
      };
      await _firebaseInstance.child("room_types_class").push().set(data);
    } catch (e) {
      debugPrint("Failed to create Types: $e");
    }
  }

  static Future<void> update(String key, RoomTypeClass type) async {
    try {
      Map<String, dynamic> data = {
        "id": type.id,
        "name": type.name,
      };
      await _firebaseInstance.child("room_types_class").child(key).update(data);
    } catch (e) {
      debugPrint("Failed to update Types: $e");
    }
  }

  Future<List<RoomTypeClass>> getAllTypes() async {
    try {
      _roomType.clear();

      List<RoomTypeClass> types = [];
      DataSnapshot snapshot =
          await _firebaseInstance.child("room_types_class").get();

      if (snapshot.value != null) {
        for (var child in snapshot.children) {
          Map<String, dynamic> data =
              Map<String, dynamic>.from(child.value as Map);
          RoomTypeClass type = RoomTypeClass(
            id: child.key!,
            name: data["name"],
          );
          _roomType.add(type);
          types.add(type);
        }
      } else {
        debugPrint("Snapshot is null");
      }

      debugPrint("Tyepes loaded: ${types.length}");
      notifyListeners(); // Panggil notifyListeners agar UI ter-update
      return types;
    } catch (e) {
      debugPrint("Failed to get Types: $e");
      return [];
    }
  }

  Future<void> fetchTypesByUid(String uid) async {
    // Set isLoading to true before fetching data
    _isLoading = true;
    notifyListeners();

    try {
      DatabaseEvent event =
          await _firebaseInstance.child("room_types_class").child(uid).once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        var type = snapshot.value as Map<dynamic, dynamic>;
        _currentTypes = RoomTypeClass(
          id: uid,
          name: type["name"] ?? "",
        );
      } else {
        _currentTypes = null;
        print("No Types found for uid: $uid");
      }
      // Set isLoading to false after data is fetched successfully
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint("Failed to fetch Types: $e");
      _currentTypes = null;
      _error = "Failed to fetch Types: $e";
      // Set isLoading to false after fetching data fails
      _isLoading = false;
      notifyListeners();
    }
  }

  static Future<RoomTypeClass?> getById(String roomTypeId) async {
    DatabaseReference roomTypeRef = FirebaseDatabase.instance
        .ref()
        .child("room_types_class")
        .child(roomTypeId);

    DatabaseEvent event = await roomTypeRef.once();
    DataSnapshot snapshot = event.snapshot;

    if (snapshot.exists) {
      var roomTypeData = snapshot.value as Map<dynamic, dynamic>;
      return RoomTypeClass(
        id: roomTypeData["id"],
        name: roomTypeData["name"],
      );
    } else {
      return null;
    }
  }

  Future<RoomTypeClass?> getByid(String roomTypeId) async {
    DatabaseReference roomTypeRef = FirebaseDatabase.instance
        .ref()
        .child("room_types_class")
        .child(roomTypeId);

    DatabaseEvent event = await roomTypeRef.once();
    DataSnapshot snapshot = event.snapshot;

    if (snapshot.exists) {
      var roomData = snapshot.value as Map<dynamic, dynamic>;
      // return Room.fromJson(roomData[], json)
      return RoomTypeClass(
        id: roomTypeId,
        name: roomData["name"],
      );
    } else {
      return null;
    }
  }

  Future<void> deleteType(String id) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firebaseInstance.child("room_types_class").child(id).remove();
      
      // Hapus dari list lokal
      _roomType.removeWhere((type) => type.id == id);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = "Gagal menghapus tipe ruangan: $e";
      _isLoading = false;
      notifyListeners();
      throw Exception(_error);
    }
  }
}
