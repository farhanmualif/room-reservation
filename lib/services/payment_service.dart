import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:midtrans_sdk/midtrans_sdk.dart';
import 'package:zenith_coffee_shop/models/order.dart';
import 'package:http/http.dart' as http;
import 'package:zenith_coffee_shop/screens/home_screen.dart';
import 'package:zenith_coffee_shop/themes/app_color.dart';
import 'package:zenith_coffee_shop/providers/reservation_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:http/io_client.dart';
import 'dart:async';

class PaymentService {
  // static const String merchantServerUrl =
  //     'https://b792-180-246-194-161.ngrok-free.app';
  static const String merchantServerUrl =
      'https://room-reservation.caprover.togetherwith.my.id';
  static const String clientKey = 'SB-Mid-client-tu6MIBX3dJ-Tv4GO';
  MidtransSDK? _midtrans;

  Future<void> initMidtrans() async {
    if (_midtrans != null) return;

    try {
      _midtrans = await MidtransSDK.init(
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

      _midtrans?.setUIKitCustomSetting(
        skipCustomerDetailsPages: true,
      );
    } catch (e) {
      debugPrint('Error initializing Midtrans: $e');
      rethrow;
    }
  }

  Future<void> startPayment(BuildContext context, Order order) async {
    try {
      // 1. Inisialisasi Midtrans jika belum
      await initMidtrans();
      if (_midtrans == null) {
        throw Exception('Midtrans tidak dapat diinisialisasi');
      }

      // 2. Validasi koneksi internet
      if (!await checkInternetConnection()) {
        throw Exception('Tidak ada koneksi internet');
      }

      // 3. Validasi koneksi ke server
      if (!await validateConnection()) {
        throw Exception('Tidak dapat terhubung ke server pembayaran');
      }

      // 4. Set callback untuk hasil transaksi
      _midtrans!.setTransactionFinishedCallback((result) async {
        await _handleTransactionResult(context, result, order);
      });

      // 5. Dapatkan token transaksi
      String token = await getSnapToken(order);
      if (token.isEmpty) throw Exception('Token transaksi tidak valid');

      // 6. Mulai proses pembayaran
      debugPrint("Starting payment with token: $token");
      _midtrans!.startPaymentUiFlow(token: token);
    } catch (e) {
      debugPrint('Error in startPayment: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memulai pembayaran: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleTransactionResult(
      BuildContext context, TransactionResult result, Order order) async {
    debugPrint("Transaction Result: ${result.toJson()}");

    final reservationProvider =
        Provider.of<ReservationProvider>(context, listen: false);

    try {
      if (result.isTransactionCanceled) {
        _handleTransactionCanceled(context, reservationProvider);
        return;
      }

      await _processSuccessfulTransaction(
          context, result, order, reservationProvider);
    } catch (e) {
      debugPrint('Error handling transaction result: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleTransactionCanceled(
      BuildContext context, ReservationProvider reservationProvider) {
    reservationProvider.currentOrder = null;

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaksi dibatalkan'),
          backgroundColor: Colors.orange,
        ),
      );
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false);
    }
  }

  Future<void> _processSuccessfulTransaction(
      BuildContext context,
      TransactionResult result,
      Order order,
      ReservationProvider reservationProvider) async {
    order.paid = true;
    order.statusPayment = "pending";
    order.transactionId = result.transactionId;

    await reservationProvider.saveReservation(order);

    if (context.mounted) {
      Navigator.of(context).pushNamed("/payment_pending", arguments: order.id);
    }
  }

  // Update fungsi checkInternetConnection
  Future<bool> checkInternetConnection() async {
    try {
      final List<InternetAddress> result = await InternetAddress.lookup(
          'midtrans-backend-jm40bvxhj-farhan-mualifs-projects.vercel.app');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        debugPrint("Koneksi internet OK");
        return true;
      }
      return false;
    } on SocketException catch (e) {
      debugPrint("Error koneksi: $e");
      return false;
    }
  }

  Future<String> getSnapToken(Order order) async {
    if (!await checkInternetConnection()) {
      throw Exception('Tidak ada koneksi internet');
    }

    const apiUrl = '$merchantServerUrl/api';
    debugPrint("Mencoba koneksi ke: $apiUrl");

    try {
      final client = HttpClient()
        ..badCertificateCallback =
            ((X509Certificate cert, String host, int port) => true);
      final ioClient = IOClient(client);

      final response = await ioClient
          .post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
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
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Request timeout setelah 30 detik');
        },
      );

      debugPrint("Response status: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['token'];
      } else {
        throw Exception(
            'Gagal mendapatkan Snap token. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Error detail: $e");
      if (e.toString().contains("No address associated")) {
        throw Exception(
            'Gagal terhubung ke server. Mohon periksa koneksi internet Anda atau coba beberapa saat lagi.');
      }
      throw Exception('Gagal melakukan request: $e');
    }
  }

  Future<Map<String, dynamic>> checkPaymentStatus(String orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$merchantServerUrl/api/status/$orderId/'),
      );

      debugPrint("Status Response: ${response.body}");
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return jsonDecode(response.body);
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Tambahkan method untuk validasi koneksi
  Future<bool> validateConnection() async {
    try {
      final client = HttpClient()
        ..badCertificateCallback =
            ((X509Certificate cert, String host, int port) => true);
      final ioClient = IOClient(client);

      final response = await ioClient.get(
        Uri.parse(merchantServerUrl),
      );

      debugPrint("Connection test response: ${response.statusCode}");
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Connection error: $e");
      return false;
    }
  }
}
