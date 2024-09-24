import 'package:flutter/material.dart';
import 'package:zenith_coffee_shop/main.dart';
import 'package:zenith_coffee_shop/themes/app_color.dart';

class PaymentDone extends StatefulWidget {
  const PaymentDone({super.key});

  @override
  State<PaymentDone> createState() => _PaymentDoneState();
}

class _PaymentDoneState extends State<PaymentDone> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.check_circle,
              size: 100,
              color: AppColors.secondary,
            ),
            const SizedBox(height: 20),
            const Text(
              'Terima Kasih!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
            const Text(
              'Pembayaran berhasil di lakukan.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => const MyApp(),
                ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              child: const Text(
                'Kembali ke home',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}
