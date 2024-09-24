import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:midtrans_sdk/midtrans_sdk.dart';
import 'package:zenith_coffee_shop/models/order.dart';
import 'package:http/http.dart' as http;
import 'package:zenith_coffee_shop/themes/app_color.dart';
import 'package:zenith_coffee_shop/providers/reservation_provider.dart';
import 'package:provider/provider.dart';

class PaymentService {
  static const String merchantServerUrl =
      'https://5925-36-78-63-4.ngrok-free.app/payment/charge/';
  static const String clientKey = 'SB-Mid-client-tu6MIBX3dJ-Tv4GO';

  Future<void> startPayment(BuildContext context, Order order) async {
    try {
      MidtransSDK? midtrans = await MidtransSDK.init(
        config: MidtransConfig(
          clientKey: clientKey,
          merchantBaseUrl: merchantServerUrl,
          colorTheme: ColorTheme(
            colorPrimary: AppColors.secondary,
            colorSecondary: AppColors.primary,
            colorPrimaryDark: Colors.black,
          ),
        ),
      );

      midtrans.setUIKitCustomSetting(
        skipCustomerDetailsPages: true,
      );

      midtrans.setTransactionFinishedCallback((result) async {
        if (result.isTransactionCanceled != true) {
          // Jika pembayaran berhasil, simpan reservasi
          final reservationProvider =
              Provider.of<ReservationProvider>(context, listen: false);
          order.paid = true;

          await reservationProvider.saveReservation(order);
          if (context.mounted) {
            Navigator.of(context).pushNamed("/payment_done");
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pembayaran dibatalkan')),
          );
        }
      });

      String token = await getSnapToken(order);
      midtrans.startPaymentUiFlow(token: token);
    } catch (e) {
      print(e);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<String> getSnapToken(Order order) async {
    final response = await http.post(
      Uri.parse(merchantServerUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'order_id': order.id,
        'gross_amount': order.totalPrice,
        'items': [
          {
            'id': order.roomId,
            'price': order.totalPrice,
            'quantity': 1,
            'name': 'Room Reservation'
          },
        ],
        'customer_details': {
          'first_name': order.ordererName.split(' ').first,
          'last_name': order.ordererName.split(' ').last,
          'email': order.ordererEmail,
          'phone': order.ordererPhone
        }
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['token'];
    } else {
      throw Exception('Failed to get Snap token');
    }
  }
}
