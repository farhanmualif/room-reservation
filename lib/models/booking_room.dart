class BookingRoom {
  final String id;
  final String roomId;
  final String ordererName;
  final String accountId;
  final String ordererEmail;
  final String ordererPhone;
  final double totalPrice;
  final String extraServices;
  final String status;
  final bool paid;
  final String paymentMethod;
  final String date;
  final String startTime;
  final String endTime;

  BookingRoom({
    required this.id,
    required this.roomId,
    required this.ordererName,
    required this.accountId,
    required this.ordererEmail,
    required this.ordererPhone,
    required this.totalPrice,
    required this.extraServices,
    required this.status,
    required this.paid,
    required this.paymentMethod,
    required this.date,
    required this.startTime,
    required this.endTime,
  });
}