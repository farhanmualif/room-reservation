import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zenith_coffee_shop/models/reservation.dart';
import 'package:zenith_coffee_shop/providers/reservation_provider.dart';
import 'package:zenith_coffee_shop/themes/app_color.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  @override
  void initState() {
    var reservationProvider =
        Provider.of<ReservationProvider>(context, listen: false);
    reservationProvider.getAllReservations();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'Histori Pesanan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<ReservationProvider>(
        builder: (context, reservationProvider, child) {
          List<Reservation> reservation = reservationProvider.reservations;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: reservation.length,
            itemBuilder: (context, index) {
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
                      _buildInfoRow(
                        icon: Icons.person,
                        label: "Nama Pemesan",
                        value: reservation[index].ordererName,
                      ),
                      _buildDivider(),
                      _buildInfoRow(
                        icon: Icons.email,
                        label: "Email",
                        value: reservation[index].ordererEmail,
                      ),
                      _buildDivider(),
                      _buildInfoRow(
                        icon: Icons.phone,
                        label: "No. Handphone",
                        value: reservation[index].ordererPhone,
                      ),
                      _buildDivider(),
                      _buildInfoRow(
                        icon: Icons.meeting_room,
                        label: "Ruangan",
                        value: reservation[index].room!.name,
                      ),
                      _buildDivider(),
                      _buildInfoRow(
                        icon: Icons.class_,
                        label: "Kelas",
                        value: reservation[index].roomTypeClass?.name ?? '-',
                      ),
                      _buildDivider(),
                      _buildInfoRow(
                        icon: Icons.calendar_today,
                        label: "Tanggal",
                        value: reservation[index].date,
                      ),
                      _buildDivider(),
                      _buildInfoRow(
                        icon: Icons.access_time,
                        label: "Waktu",
                        value:
                            "${reservation[index].startTime} - ${reservation[index].endTime}",
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

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Divider(
        color: Colors.white.withOpacity(0.2),
        height: 1,
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white70,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
