// File: order_room_form.dart
// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:zenith_coffee_shop/helper/generate_time.dart';
import 'package:zenith_coffee_shop/helper/idr_format_currency.dart';
import 'package:zenith_coffee_shop/models/order.dart';
import 'package:zenith_coffee_shop/providers/auth_provider.dart';
import 'package:zenith_coffee_shop/providers/extra_services_provider.dart';
import 'package:zenith_coffee_shop/providers/profiles_provider.dart';
import 'package:zenith_coffee_shop/providers/reservation_provider.dart';
import 'package:zenith_coffee_shop/providers/room_provider.dart';
import 'package:zenith_coffee_shop/services/payment_service.dart';
import 'package:zenith_coffee_shop/themes/app_color.dart';

class OrderRoomForm extends StatefulWidget {
  const OrderRoomForm({super.key});

  @override
  State<OrderRoomForm> createState() => _OrderRoomFormState();
}

class _OrderRoomFormState extends State<OrderRoomForm> {
  late ExtraServicesProvider _extraServicesProvider;

  @override
  void initState() {
    super.initState();
    _extraServicesProvider = ExtraServicesProvider();
    _extraServicesProvider.getAllExtraService();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _extraServicesProvider,
      child: _OrderRoomFormContent(),
    );
  }
}

class _OrderRoomFormContent extends StatelessWidget {
  final _orderersNameController = TextEditingController();
  final _priceServiceController = TextEditingController();
  final _totalPaymentController = TextEditingController();
  String _paymentMethod = "COD";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Material(
        color: Colors.black,
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        const Text(
                          'Form Pemesanan Ruangan',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ],
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 40),
                            _buildTextField(_orderersNameController, 'Nama'),
                            const SizedBox(height: 16),
                            _buildDropdownRoomTypeField(),
                            const SizedBox(height: 16),
                            _buildDropdownServiceField(),
                            const SizedBox(height: 16),
                            _buildPriceTextField(),
                            const SizedBox(height: 16),
                            _buildExtraServices(),
                            const SizedBox(height: 16),
                            _buildDateField(context),
                            const SizedBox(height: 16),
                            _buildTimeField(context, true),
                            const SizedBox(height: 16),
                            _buildTimeField(context, false),
                            const SizedBox(height: 16),
                            _buildTotalPaymentTextField(),
                            const SizedBox(height: 24),
                            _buildDropdownPaymentMethodField(),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondary),
                              onPressed: () => _handleReservation(context),
                              child: const Text(
                                'Pesan',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleReservation(BuildContext context) async {
    final reservationProvider = context.read<ReservationProvider>();
    final roomProvider = context.read<RoomProvider>();
    final profileProvider = context.read<ProfilesProvider>();
    final extraService = context.read<ExtraServicesProvider>();
    final authProvider = context.read<AuthProvider>();
    PaymentService paymentService = PaymentService();

    // Validasi input
    if (_orderersNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama Tidak boleh kosong'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_paymentMethod.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Metode Pembayaran Tidak boleh kosong')),
      );
      return;
    }

    if (reservationProvider.selectedDate == null ||
        reservationProvider.startTime == null ||
        reservationProvider.endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanggal dan Waktu tidak boleh kosong'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    try {
      bool isAvailable = await reservationProvider.isTimeSlotAvailable(
        roomProvider.selectedDetailRoom!.room.id!,
        reservationProvider.selectedDate!,
        reservationProvider.startTime!,
        reservationProvider.endTime!,
      );

      if (!isAvailable) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Slot waktu ini tidak tersedia'),
              backgroundColor: Colors.redAccent,
            ),
          );
          return;
        }
      }

      int totalPrice = roomProvider.selectedDetailRoom!.roomService.price +
          extraService.extraServicesSelected
              .fold(0, (sum, service) => sum + service.price);

      Order order = Order(
        id: "RSO-${generateNow()}",
        roomId: roomProvider.selectedDetailRoom!.room.id!,
        accountId: authProvider.userId!,
        ordererName: _orderersNameController.text,
        ordererEmail: profileProvider.currentProfile!.email,
        ordererPhone: profileProvider.currentProfile!.phoneNumber,
        totalPrice: totalPrice.toDouble(),
        extraServices: extraService.extraServicesSelected
            .map((service) => service.id)
            .toList(),
        status: 'ordered',
        paymentMethod: _paymentMethod,
        startTime: reservationProvider.startTime!,
        endTime: reservationProvider.endTime!,
        date: reservationProvider.selectedDate!,
      );

      if (_paymentMethod == "COD") {
        order.paid = false;
        await reservationProvider.saveReservation(order);
        if (context.mounted) {
          Navigator.of(context).pushNamed("/payment_done");
        }
      } else {
        // Mulai proses pembayaran Midtrans
        if (context.mounted) {
          await paymentService.startPayment(context, order);
        }
        // Catatan: saveReservation dipanggil di dalam startPayment jika pembayaran berhasil
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  Widget _buildTextField(TextEditingController controller, String hintText) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildPriceTextField() {
    return Consumer<RoomProvider>(
      builder: (context, roomProvider, child) {
        _priceServiceController.text =
            "${roomProvider.selectedDetailRoom!.roomService.price}";
        return TextField(
          readOnly: true,
          controller: _priceServiceController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixText: "Rp. ",
            hintText: currencyFormatter
                .format(roomProvider.selectedDetailRoom!.roomService.price),
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        );
      },
    );
  }

  Widget _buildTotalPaymentTextField() {
    return Consumer2<RoomProvider, ReservationProvider>(
      builder: (context, roomProvider, reservationProvider, child) {
        return TextField(
          readOnly: true,
          controller: _totalPaymentController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixText: "Rp. ",
            hintText: reservationProvider.totalPayment != null
                ? "${reservationProvider.totalPayment}"
                : roomProvider.selectedDetailRoom != null
                    ? "${roomProvider.selectedDetailRoom!.room.price}"
                    : "",
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        );
      },
    );
  }

  Widget _buildDropdownRoomTypeField() {
    return Consumer<RoomProvider>(
      builder: (context, roomProvider, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              hintText: "Tipe Ruangan",
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            style: const TextStyle(color: Colors.white),
            dropdownColor: Colors.grey[800],
            value: roomProvider.selectedDetailRoom!.roomType.name,
            items: [
              DropdownMenuItem<String>(
                value: roomProvider.selectedDetailRoom!.roomType.name,
                child: Text(
                  roomProvider.selectedDetailRoom!.roomType.name,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
            onChanged: null, // This makes the dropdown disabled
            disabledHint: Text(
              roomProvider.selectedDetailRoom!.roomType.name,
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDropdownServiceField() {
    return Consumer<RoomProvider>(
      builder: (context, roomProvider, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              hintText: "Service",
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            style: const TextStyle(color: Colors.white),
            dropdownColor: Colors.grey[800],
            value: roomProvider.selectedDetailRoom!.roomService.name,
            items: [
              DropdownMenuItem<String>(
                value: roomProvider.selectedDetailRoom!.roomService.name,
                child: Text(
                  roomProvider.selectedDetailRoom!.roomService.name,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
            onChanged: null, // This makes the dropdown disabled
            disabledHint: Text(
              roomProvider.selectedDetailRoom!.roomService.name,
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDropdownPaymentMethodField() {
    return Consumer2<RoomProvider, ReservationProvider>(
      builder: (context, roomProvider, reservationProvider, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<String>(
            value: "COD",
            validator: (value) =>
                value == null ? "Metode Pembayaran Tidak Boleh Kosong" : null,
            decoration: InputDecoration(
              hintText: "Payment Method",
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            style: const TextStyle(color: Colors.white),
            dropdownColor: Colors.grey[800],
            items: const [
              DropdownMenuItem<String>(
                value: "Tranfer Bank",
                child: Text(
                  "Tranfer Bank/E-Wallet",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              DropdownMenuItem<String>(
                value: "COD",
                child: Text(
                  "COD",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
            onChanged: (value) {
              _paymentMethod = value!;
            },
            disabledHint: Text(
              roomProvider.selectedDetailRoom!.roomService.name,
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateField(BuildContext context) {
    return Consumer<ReservationProvider>(
      builder: (context, reservationProvider, child) {
        return TextField(
          style:
              TextStyle(color: Colors.white, backgroundColor: AppColors.gray),
          cursorColor: Colors.white,
          decoration: InputDecoration(
            suffixIcon: const Icon(
              Icons.calendar_month_outlined,
              color: Colors.white,
            ),
            hintText: "Tanggal",
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          readOnly: true,
          controller: TextEditingController(
            text: reservationProvider.selectedDate != null
                ? DateFormat('yyyy-MM-dd')
                    .format(reservationProvider.selectedDate!)
                : '',
          ),
          onTap: () async {
            // Navigator.of(context).push(MaterialPageRoute(
            //   builder: (context) => const Calendar(),
            // ));
            final DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              selectableDayPredicate: (DateTime day) {
                return reservationProvider.isDateAvailable(day);
              },
            );
            if (pickedDate != null) {
              reservationProvider.setDate(pickedDate);
            }
          },
        );
      },
    );
  }

  Widget _buildTimeField(BuildContext context, bool isStartTime) {
    return Consumer<ReservationProvider>(
      builder: (context, reservationProvider, child) {
        return TextField(
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            suffixIcon: const Icon(
              Icons.timer_outlined,
              color: Colors.white,
            ),
            hintText: isStartTime ? "Dari Jam" : "Sampai Jam",
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          readOnly: true,
          controller: TextEditingController(
            text: (isStartTime
                        ? reservationProvider.startTime
                        : reservationProvider.endTime)
                    ?.format(context) ??
                '',
          ),
          onTap: () async {
            if (reservationProvider.selectedDate == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Pilih tanggal terlebih dahulu'),
                    backgroundColor: Colors.redAccent),
              );
              return;
            }

            try {
              final TimeOfDay? pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
                builder: (BuildContext context, Widget? child) {
                  return MediaQuery(
                    data: MediaQuery.of(context)
                        .copyWith(alwaysUse24HourFormat: true),
                    child: child!,
                  );
                },
              );

              if (pickedTime != null) {
                if (reservationProvider.isTimeAvailable(
                    reservationProvider.selectedDate!, pickedTime)) {
                  if (isStartTime) {
                    reservationProvider.setStartTime(pickedTime);
                  } else {
                    reservationProvider.setEndTime(pickedTime);
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Ruang diwaktu tersebut tidak tersedia'),
                          backgroundColor: Colors.redAccent),
                    );
                  }
                }
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Waktu tidak boleh kosong'),
                        backgroundColor: Colors.redAccent),
                  );
                }
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.redAccent),
                );
              }
            }
          },
        );
      },
    );
  }

  Widget _buildExtraServices() {
    return Consumer3<ExtraServicesProvider, ReservationProvider, RoomProvider>(
      builder:
          (context, extraService, reservationProvider, roomProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Extra Layanan',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
            ...extraService.extraServices.map((service) {
              return CheckboxListTile(
                fillColor: WidgetStateProperty.resolveWith((states) =>
                    states.contains(WidgetState.selected)
                        ? Colors.orange
                        : AppColors.gray),
                title: Text(service.name,
                    style: const TextStyle(color: Colors.white)),
                value: service.isSelected,
                onChanged: (bool? value) {
                  if (value ?? false) {
                    extraService.selectExtraServices(service);
                  } else {
                    extraService.removeExtraService(service.id);
                  }
                  double totalPrice =
                      roomProvider.selectedDetailRoom!.room.price!.toDouble();
                  for (var selectedService
                      in extraService.extraServicesSelected) {
                    totalPrice += selectedService.price.toDouble();
                  }
                  reservationProvider.setTotalPayment(totalPrice);
                },
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: Colors.orange,
                checkColor: Colors.black,
                secondary: Text(currencyFormatter.format(service.price),
                    style: TextStyle(color: Colors.white.withOpacity(0.7))),
              );
            }),
          ],
        );
      },
    );
  }
}
