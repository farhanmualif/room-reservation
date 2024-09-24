import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zenith_coffee_shop/models/booking_room.dart';
import 'package:zenith_coffee_shop/models/order.dart';

class ReservationProvider extends ChangeNotifier {
  final DatabaseReference _dbRef =
      FirebaseDatabase.instance.ref().child('reservations');

  final Set<DateTime> _bookedDates = {};
  final Map<DateTime, Set<TimeOfDay>> _bookedTimes = {};

  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  double? _totalPayment;
  List<BookingRoom> _bookingHistory = [];

  // String? _paymentMethod;

  DateTime? get selectedDate => _selectedDate;
  TimeOfDay? get startTime => _startTime;
  TimeOfDay? get endTime => _endTime;
  double? get totalPayment => _totalPayment;
  List<BookingRoom> get bookingHistory => _bookingHistory;
  // String? get paymentMethod => _paymentMethod;

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
        'total_price': order.totalPrice,
        'extra_pervices': order.extraServices,
        'status': order.status,
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
      print('Error checking time slot availability: $e');
      rethrow;
    }
  }

  Future<List<BookingRoom>> getAll() async {
    try {
      // Kosongkan daftar layanan sebelum mengambil yang baru
      _bookingHistory.clear();

      List<BookingRoom> services = [];
      final event = await _dbRef.once();
      final snapshot = event.snapshot;

      debugPrint("Snapshot data: ${snapshot.value}"); // Log data Firebase

      if (snapshot.value != null) {
        for (var child in snapshot.children) {
          Map<String, dynamic> data =
              Map<String, dynamic>.from(child.value as Map);
          BookingRoom history = BookingRoom(
            id: child.key!,
            roomId: data['room_id'],
            ordererName: data['orderer_name'],
            accountId: data['account_id'],
            ordererEmail: data['orderer_email'],
            ordererPhone: data['orderer_phone'],
            totalPrice: data['total_price'],
            extraServices: data['extra_services'],
            status: data['status'],
            paid: data['paid'],
            paymentMethod: data['payment_method'],
            date: data['date'],
            startTime: data['start_time'],
            endTime: data['end_time'],
          );
          _bookingHistory.add(history);
          services.add(history);
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
}
