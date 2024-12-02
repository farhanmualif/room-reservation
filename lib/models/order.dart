import 'package:flutter/material.dart';

class Order {
  final String id;
  String? transactionId;
  final String roomId;
  final String accountId;
  final String ordererName;
  final String ordererEmail;
  final String ordererPhone;
  String? statusOrder;
  String? statusPayment;
  bool? paid;
  final List<String> extraServices;
  final double totalPrice;
  final String paymentMethod;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  Order({
    required this.id,
    this.transactionId,
    required this.roomId,
    required this.accountId,
    required this.ordererEmail,
    required this.ordererPhone,
    required this.ordererName,
    required this.totalPrice,
    required this.extraServices,
    this.statusOrder,
    this.statusPayment,
    this.paid,
    required this.paymentMethod,
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  // method for change to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'room_id': roomId,
      'orderer_name': ordererName,
      'account_od': accountId,
      'orderer_email': ordererEmail,
      'orderer_phone': ordererPhone,
      'total_price': totalPrice,
      'extra_pervices': extraServices,
      'status_order': statusOrder,
      'status_payment': statusPayment,
      'paid': paid,
      'payment_method': paymentMethod,
      'date': date,
      'start_time': startTime,
      'end_time': endTime,
    };
  }

  // Method untuk membuat model dari JSON
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      transactionId: json['transaction_id'],
      roomId: json['room_id'],
      ordererName: json['orderer_name'],
      accountId: json['account_id'],
      ordererEmail: json['orderer_email'],
      ordererPhone: json['orderer_phone'],
      totalPrice: json['total_price'],
      extraServices: json['extra_services'],
      statusOrder: json['status_order'],
      statusPayment: json['status_payment'],
      paid: json['paid'],
      paymentMethod: json['payment_method'],
      date: json['date'],
      startTime: json['start_time'],
      endTime: json['end_time'],
    );
  }
}
