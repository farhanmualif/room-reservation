import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zenith_coffee_shop/models/booking_room.dart';
import 'package:zenith_coffee_shop/models/extra_service.dart';
import 'package:zenith_coffee_shop/models/order.dart';
import 'package:zenith_coffee_shop/models/reservation.dart';
import 'package:zenith_coffee_shop/models/room.dart';
import 'package:zenith_coffee_shop/models/room_service.dart';
import 'package:zenith_coffee_shop/models/room_type_class.dart';

class ReservationProvider extends ChangeNotifier {
  final DatabaseReference _dbRef =
      FirebaseDatabase.instance.ref().child('reservations');
  final Set<DateTime> _bookedDates = {};
  final Map<DateTime, Set<TimeOfDay>> _bookedTimes = {};

  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  double _totalPayment = 0;
  double get totalPayment => _totalPayment;
  List<BookingRoom> _bookingHistory = [];

  DateTime? get selectedDate => _selectedDate;
  TimeOfDay? get startTime => _startTime;
  TimeOfDay? get endTime => _endTime;
  List<BookingRoom> get bookingHistory => _bookingHistory;
  final List<Reservation> _reservations = [];
  List<Reservation> get reservations => _reservations;
  Order? _currentOrder;
  Order? get currentOrder => _currentOrder;

  set currentOrder(Order? order) {
    _currentOrder = order;
    notifyListeners();
  }

  void setTotalPayment(double totalPayment) {
    _totalPayment = totalPayment;
    notifyListeners();
  }

  void setbookingHistory(double totalPayment) {
    _bookingHistory = bookingHistory;
    notifyListeners();
  }

  void setDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setStartTime(TimeOfDay time) {
    _startTime = time;
    notifyListeners();
  }

  void setEndTime(TimeOfDay time) {
    _endTime = time;
    notifyListeners();
  }

  void addBooking(DateTime date, TimeOfDay startTime, TimeOfDay endTime) {
    _bookedDates.add(date);
    if (!_bookedTimes.containsKey(date)) {
      _bookedTimes[date] = {};
    }
    for (var hour = startTime.hour; hour < endTime.hour; hour++) {
      _bookedTimes[date]!.add(TimeOfDay(hour: hour, minute: 0));
    }
    notifyListeners();
  }

  bool isDateAvailable(DateTime date) {
    return !_bookedDates.contains(date);
  }

  bool isTimeAvailable(DateTime date, TimeOfDay time) {
    return !(_bookedTimes[date]?.contains(time) ?? false);
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> saveReservation(Order order) async {
    try {
      String startTimeString = _formatTimeOfDay(order.startTime);
      String endTimeString = _formatTimeOfDay(order.endTime);
      String dateString = _formatDate(order.date);

      await _dbRef.push().set({
        'id': order.id,
        'room_id': order.roomId,
        'orderer_name': order.ordererName,
        'account_id': order.accountId,
        'orderer_email': order.ordererEmail,
        'orderer_phone': order.ordererPhone,
        'total_price': order.totalPrice.toInt(),
        'extra_pervices': order.extraServices,
        'status_order': order.statusOrder,
        'status_payment': order.statusPayment,
        'paid': order.paid,
        'payment_method': order.paymentMethod,
        'date': dateString,
        'start_time': startTimeString,
        'end_time': endTimeString,
      });

      notifyListeners();
    } catch (e) {
      print('Error saving reservation: $e');
      rethrow;
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<List<Map<String, dynamic>>> getReservationsForRoom(
      String roomId) async {
    try {
      final event = await _dbRef.orderByChild('room_id').equalTo(roomId).once();
      final dataSnapshot = event.snapshot;

      if (dataSnapshot.value != null) {
        final Map<dynamic, dynamic> reservations =
            dataSnapshot.value as Map<dynamic, dynamic>;
        return reservations.entries.map((entry) {
          final reservation = entry.value as Map<dynamic, dynamic>;
          return {
            'id': entry.key,
            'date': reservation['date'],
            'start_time': reservation['start_time'],
            'end_time': reservation['end_time'],
          };
        }).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching reservations: $e');
      rethrow;
    }
  }

  Future<bool> isTimeSlotAvailable(String roomId, DateTime date,
      TimeOfDay startTime, TimeOfDay endTime) async {
    try {
      final reservations = await getReservationsForRoom(roomId);
      final String dateString = DateFormat('yyyy-MM-dd').format(date);

      for (var reservation in reservations) {
        if (reservation['date'] == dateString) {
          final reservationStart = _parseTimeString(reservation['start_time']);
          final reservationEnd = _parseTimeString(reservation['end_time']);

          if (_isOverlapping(
              startTime, endTime, reservationStart, reservationEnd)) {
            return false;
          }
        }
      }
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getAllReservations() async {
    try {
      final DatabaseReference dbRef = FirebaseDatabase.instance.ref();
      _reservations.clear();

      // Fetch reservations
      DataSnapshot reservationsSnapshot =
          await dbRef.child('reservations').get();

      if (reservationsSnapshot.value != null) {
        Map<dynamic, dynamic> reservationsData =
            reservationsSnapshot.value as Map<dynamic, dynamic>;

        for (var entry in reservationsData.entries) {
          Reservation reservation = Reservation.fromMap(
              entry.key, Map<String, dynamic>.from(entry.value));

          // Fetch related room data
          DataSnapshot snapshot =
              await dbRef.child('rooms').child(reservation.roomId).get();

          print("room id ${reservation.roomId}");

          if (snapshot.value != null) {
            reservation.room = Room.fromJson(snapshot.key!,
                Map<String, dynamic>.from(snapshot.value as Map));

            // Fetch room service data
            DataSnapshot serviceSnapshot = await dbRef
                .child('room_services')
                .child(reservation.room!.serviceId!)
                .get();

            if (serviceSnapshot.value != null) {
              reservation.roomService = RoomService.fromJson(
                  serviceSnapshot.key!,
                  Map<String, dynamic>.from(serviceSnapshot.value as Map));
            }

            // Fetch room type class data
            DataSnapshot typeSnapshot = await dbRef
                .child('room_types_class')
                .child(reservation.room!.roomTypeId!)
                .get();
            if (typeSnapshot.value != null) {
              reservation.roomTypeClass = RoomTypeClass.fromJson(
                  typeSnapshot.key!,
                  Map<String, dynamic>.from(typeSnapshot.value as Map));
            }
          }

          _reservations.add(reservation);
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint("Failed to fetch reservations: $e");
    }
  }

  TimeOfDay _parseTimeString(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  bool _isOverlapping(
      TimeOfDay start1, TimeOfDay end1, TimeOfDay start2, TimeOfDay end2) {
    final start1Minutes = start1.hour * 60 + start1.minute;
    final end1Minutes = end1.hour * 60 + end1.minute;
    final start2Minutes = start2.hour * 60 + start2.minute;
    final end2Minutes = end2.hour * 60 + end2.minute;

    return start1Minutes < end2Minutes && start2Minutes < end1Minutes;
  }

  void calculateTotal(Room? room, List<ExtraService> extraServices) {
    if (room == null || startTime == null || endTime == null) {
      setTotalPayment(0);
      return;
    }

    // Konversi waktu ke menit
    int startMinutes = (startTime!.hour * 60) + startTime!.minute;
    int endMinutes = (endTime!.hour * 60) + endTime!.minute;
    int durationInMinutes = endMinutes - startMinutes;

    if (durationInMinutes <= 0) {
      durationInMinutes +=
          24 * 60; // Tambahkan 24 jam jika melewati tengah malam
    }

    // Hitung biaya per menit
    double pricePerMinute = room.pricePerHour / 60;
    int roomCost = (pricePerMinute * durationInMinutes).round();

    // Tambahkan biaya extra services
    int extraServicesCost =
        extraServices.fold(0, (sum, service) => sum + service.price);

    _totalPayment = (roomCost + extraServicesCost).toDouble();
    notifyListeners();
  }

  Future<void> updateReservationStatus(
      String orderId, Map<String, dynamic> updates) async {
    try {
      final snapshot = await _dbRef.orderByChild('id').equalTo(orderId).once();
      final data = snapshot.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        String key = data.keys.first;
        await _dbRef.child(key).update(updates);
        notifyListeners();
      }
    } catch (e) {
      print('Error updating reservation status: $e');
      rethrow;
    }
  }
}
