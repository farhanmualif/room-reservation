import 'package:zenith_coffee_shop/models/extra_service.dart';
import 'package:zenith_coffee_shop/models/room.dart';
import 'package:zenith_coffee_shop/models/room_service.dart';
import 'package:zenith_coffee_shop/models/room_type_class.dart';

class Reservation {
  final String id;
  final String accountId;
  final String date;
  final String endTime;
  final List<ExtraService> extraServices;
  final String ordererEmail;
  final String ordererName;
  final String ordererPhone;
  final bool paid;
  final String paymentMethod;
  final String roomId;
  final String startTime;
  final String status;
  final int totalPrice;

  Room? room;
  RoomService? roomService;
  RoomTypeClass? roomTypeClass;

  Reservation({
    required this.id,
    required this.accountId,
    required this.date,
    required this.endTime,
    required this.extraServices,
    required this.room,
    required this.roomService,
    required this.roomTypeClass,
    required this.ordererEmail,
    required this.ordererName,
    required this.ordererPhone,
    required this.paid,
    required this.paymentMethod,
    required this.roomId,
    required this.startTime,
    required this.status,
    required this.totalPrice,
  });

  factory Reservation.fromMap(String key, Map<String, dynamic> map) {
    return Reservation(
      id: key,
      accountId: map['account_id'] ?? '',
      date: map['date'] ?? '',
      endTime: map['end_time'] ?? '',
      extraServices: map['extra_services'] != null
          ? List<ExtraService>.from(
              map['extra_services'].map((e) => ExtraService.fromJson(e)))
          : [],
      room: map['room'] != null
          ? Room.fromJson(map['room']["id"], map['room'])
          : Room(), // assume Room has a fromMap constructor
      roomService: map['room_services'] != null
          ? RoomService.fromJson(
              map["room_services"]["id"], map['room_services'])
          : null, // assume RoomService has a fromMap constructor
      roomTypeClass: map['room_type_class'] != null
          ? RoomTypeClass.fromJson(
              map['room_type_class']["id"], map['room_types_class'])
          : null, // assume RoomTypeClass has a fromMap constructor
      ordererEmail: map['orderer_email'] ?? '',
      ordererName: map['orderer_name'] ?? '',
      ordererPhone: map['orderer_phone'] ?? '',
      paid: map['paid'] ?? false,
      paymentMethod: map['payment_method'] ?? '',
      roomId: map['room_id'] ?? '',
      startTime: map['start_time'] ?? '',
      status: map['status'] ?? '',
      totalPrice: map['total_price'] ?? 0,
    );
  }
}
