import 'package:flutter/material.dart';
import 'package:zenith_coffee_shop/screens/home_screen.dart';
import 'package:zenith_coffee_shop/screens/room_selection_screen.dart';
import 'package:zenith_coffee_shop/themes/app_color.dart';
import 'package:zenith_coffee_shop/services/payment_service.dart';
import 'package:zenith_coffee_shop/providers/reservation_provider.dart';
import 'package:provider/provider.dart';

class PaymentPendingScreen extends StatelessWidget {
  final String orderId;

  const PaymentPendingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.pending_outlined,
                size: 100,
                color: AppColors.secondary,
              ),
              const SizedBox(height: 24),
              const Text(
                'Pembayaran Dalam Proses',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Silakan cek status pembayaran dengan klik tombol dibawah',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                onPressed: () async {
                  try {
                    final reservationProvider =
                        Provider.of<ReservationProvider>(context,
                            listen: false);

                    final paymentService = PaymentService();
                    final status =
                        await paymentService.checkPaymentStatus(orderId);
                    debugPrint("Status: $status");

                    if (!context.mounted) return;

                    if (status['status'] == 'settlement' ||
                        status['status'] == 'capture') {
                      await reservationProvider.updateReservationStatus(
                        orderId,
                        {
                          'status_payment': 'success',
                          'paid': true,
                          'status_order': 'confirmed'
                        },
                      );
                      if (!context.mounted) return;
                      Navigator.of(context)
                          .pushReplacementNamed('/payment_done');
                    } else if (status['status'] == 'pending') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Pembayaran masih dalam proses')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Pembayaran belum selesai atau dibatalkan')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },
                child: const Text(
                  'Cek Status Pembayaran',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                onPressed: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const RoomSelectionPage()));
                },
                child: const Text(
                  'Kembali ke Beranda',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
