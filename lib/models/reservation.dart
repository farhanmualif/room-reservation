class Reservation {
  String userId;
  String roomId;
  String date;
  String startTime;
  String endTime;
  String extraServicesId;
  String totalPrice;
  String createAdat;

  Reservation({
    required this.userId,
    required this.roomId,
    required this.createAdat,
    required this.date,
    required this.endTime,
    required this.extraServicesId,
    required this.startTime,
    required this.totalPrice,
  });
}
