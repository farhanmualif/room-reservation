import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:zenith_coffee_shop/models/room.dart';
import 'package:zenith_coffee_shop/models/room_service.dart';
import 'package:zenith_coffee_shop/models/room_type_class.dart';
import 'package:zenith_coffee_shop/providers/room_services_provider.dart';
import 'package:zenith_coffee_shop/providers/room_type_class_provider.dart';

class RoomProvider with ChangeNotifier {
  List<Room> _rooms = [];
  Room? _selectedRoom;
  bool _isLoading = false;
  String? _error;

  List<Room> get rooms => _rooms;
  Room? get selectedRoom => _selectedRoom;
  bool get isLoading => _isLoading;
  String? get error => _error;

  DetailRoom? _selectedDetailRoom;
  DetailRoom? get selectedDetailRoom => _selectedDetailRoom;

  void selectDetailRoom(DetailRoom detailRoom) {
    _selectedDetailRoom = detailRoom;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  Future<void> create(Room room) async {
    try {
      Map<String, dynamic> data = {
        "id": room.id,
        "name": room.name,
        "image": room.image,
        "description": room.description,
        "room_type_id": room.roomTypeId,
        "service_id": room.serviceId,
        "price": room.price,
        "isAvailable": true,
      };
      await _dbRef.child("rooms").push().set(data);
    } catch (e) {
      debugPrint("Failed to create Service: $e");
    }
  }

  Future<void> update(Room room) async {
    try {
      // Ambil referensi ke node yang ingin diupdate
      final roomRef = _dbRef.child("rooms").child(room.id!);

      // Update data baru ke node
      await roomRef.set({
        "name": room.name,
        "image": room.image,
        "description": room.description,
        "room_type_id": room.roomTypeId,
        "service_id": room.serviceId,
        "price": room.price,
        "isAvailable": true,
      });
    } catch (e) {
      debugPrint("Failed to update Room: $e");
    }
  }

  Future<List<Room>> fetchRooms() async {
    try {
      _rooms.clear();

      List<Room> rooms = [];
      DataSnapshot snapshot = await _dbRef.child("rooms").get();

      if (snapshot.value != null) {
        (snapshot.value as Map).forEach((key, value) {
          Map<String, dynamic> data = Map<String, dynamic>.from(value);

          Room room = Room(
            id: key,
            name: data["name"],
            price: data["price"],
            description: data["description"],
            image: data["image"],
            isAvailable: data["isAvailable"],
            roomTypeId: data["room_type_id"],
            serviceId: data["service_id"],
          );
          _rooms.add(room);
        });
      } else {
        debugPrint("Snapshot is null");
      }

      notifyListeners();
      return rooms;
    } catch (e) {
      debugPrint("Failed to get Rooms: $e");
      return [];
    }
  }

  Future<DetailRoom?> getRoomDetail(String roomId) async {
    Room? room = await getRoomByUid(roomId);
    if (room == null) return null;

    RoomTypeClass? roomType =
        await RoomTypeClassProvider.getById(room.roomTypeId!);
    if (roomType == null) return null;

    RoomService? roomService =
        await RoomServicesProvider.getById(room.serviceId!);
    if (roomService == null) return null;

    DetailRoom detailRoom =
        DetailRoom(room: room, roomType: roomType, roomService: roomService);

    return detailRoom;
  }

  Future<Room?> getRoomByUid(String roomId) async {
    DatabaseReference getRooms = _dbRef.child("rooms").child(roomId);

    DatabaseEvent event = await getRooms.once();
    DataSnapshot snapshot = event.snapshot;

    if (snapshot.exists) {
      var roomData = snapshot.value as Map<dynamic, dynamic>;
      // return Room.fromJson(roomData[], json)
      return Room(
        id: roomId,
        name: roomData["name"],
        description: roomData["description"],
        image: roomData["image"],
        isAvailable: roomData["isAvailable"],
        price: roomData["price"],
        roomTypeId: roomData["room_type_id"],
        serviceId: roomData["service_id"],
      );
    } else {
      return null;
    }
  }

  Future<List<Room>> getRoomsByRoomTypeId(String roomTypeId) async {
    DatabaseReference roomsRef = _dbRef.child("rooms");
    DatabaseEvent event =
        await roomsRef.orderByChild("room_type_id").equalTo(roomTypeId).once();
    DataSnapshot snapshot = event.snapshot;

    if (snapshot.exists) {
      Map<dynamic, dynamic> roomsData = snapshot.value as Map<dynamic, dynamic>;
      List<Room> rooms = [];

      roomsData.forEach((key, value) {
        rooms.add(
          Room(
            id: key,
            name: value["name"],
            description: value["description"],
            image: value["image"],
            isAvailable: value["isAvailable"],
            price: value["price"],
            roomTypeId: value["room_type_id"],
            serviceId: value["service_id"],
          ),
        );
      });

      _rooms = rooms;

      return rooms;
    } else {
      return [];
    }
  }

  Future<void> deleteRoom(String id) async {
    _setLoading(true);
    try {
      _dbRef.child("rooms").child(id).remove();
      _rooms.removeWhere((service) => service.id == id);
      _setError(null);
    } catch (e) {
      _setError("Failed to delete Service: $e");
    } finally {
      _setLoading(false);
    }
  }

  void selectRoom(Room room) {
    _selectedRoom = room;
    notifyListeners();
  }
}

class DetailRoom {
  Room room;
  RoomTypeClass roomType;
  RoomService roomService;
  DetailRoom({
    required this.room,
    required this.roomType,
    required this.roomService,
  });
}
