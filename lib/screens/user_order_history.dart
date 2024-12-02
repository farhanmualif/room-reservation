import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zenith_coffee_shop/models/reservation.dart';
import 'package:zenith_coffee_shop/providers/reservation_provider.dart';
import 'package:zenith_coffee_shop/providers/auth_provider.dart';
import 'package:zenith_coffee_shop/themes/app_color.dart';
import 'package:intl/intl.dart';

class UserOrderHistoryPage extends StatefulWidget {
  const UserOrderHistoryPage({super.key});

  @override
  State<UserOrderHistoryPage> createState() => _UserOrderHistoryPageState();
}

class _UserOrderHistoryPageState extends State<UserOrderHistoryPage> {
  @override
  void initState() {
    var reservationProvider =
        Provider.of<ReservationProvider>(context, listen: false);
    reservationProvider.getAllReservations();
    super.initState();
  }

  String _formatCurrency(double amount) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatCurrency.format(amount);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<AuthProvider>(context).currentUser;

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'Riwayat Pesanan Saya',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<ReservationProvider>(
        builder: (context, reservationProvider, child) {
          // Filter reservasi berdasarkan user yang sedang login
          List<Reservation> userReservations = reservationProvider.reservations
              .where((res) => res.accountId == currentUser?.uid)
              .toList();

          if (userReservations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 80,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada riwayat pesanan',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: userReservations.length,
            itemBuilder: (context, index) {
              final reservation = userReservations[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.white.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            reservation.room?.name ?? 'Ruangan',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(reservation.status),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              reservation.status,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        icon: Icons.calendar_today,
                        label: "Tanggal",
                        value: reservation.date,
                        orderId: reservation.id,
                      ),
                      _buildInfoRow(
                        icon: Icons.access_time,
                        label: "Waktu",
                        value:
                            "${reservation.startTime} - ${reservation.endTime}",
                        orderId: reservation.id,
                      ),
                      _buildInfoRow(
                        icon: Icons.class_,
                        label: "Kelas",
                        value: reservation.roomTypeClass?.name ?? '-',
                        orderId: reservation.id,
                      ),
                      _buildInfoRow(
                        icon: Icons.payment,
                        label: "Total Pembayaran",
                        value:
                            _formatCurrency(reservation.totalPrice.toDouble()),
                        orderId: reservation.id,
                      ),
                      _buildInfoRow(
                        icon: Icons.payment,
                        label: "Status Pembayaran",
                        value: reservation.statusPayment,
                        orderId: reservation.id,
                        valueColor:
                            reservation.statusPayment.toLowerCase() == 'paid'
                                ? Colors.green
                                : Colors.orange,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required String orderId,
    Color? valueColor,
  }) {
    return GestureDetector(
      onTap: () {
        if (label == "Status Pembayaran") {
          if (value.toLowerCase() == 'pending') {
            Navigator.pushNamed(
              context,
              '/payment_pending',
              arguments: orderId, // Kirim orderId sebagai argument
            );
          } else if (value.toLowerCase() == 'paid') {
            Navigator.pushNamed(context, '/payment_done');
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white70,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      color: valueColor ?? Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
