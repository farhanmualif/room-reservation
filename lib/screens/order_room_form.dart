// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:zenith_coffee_shop/helper/generate_time.dart';
import 'package:zenith_coffee_shop/helper/idr_format_currency.dart';
import 'package:zenith_coffee_shop/models/order.dart';
import 'package:zenith_coffee_shop/models/room.dart';
import 'package:zenith_coffee_shop/providers/auth_provider.dart';
import 'package:zenith_coffee_shop/providers/extra_services_provider.dart';
import 'package:zenith_coffee_shop/providers/profiles_provider.dart';
import 'package:zenith_coffee_shop/providers/reservation_provider.dart';
import 'package:zenith_coffee_shop/providers/room_provider.dart';
import 'package:zenith_coffee_shop/providers/room_services_provider.dart';
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

class _OrderRoomFormContent extends StatefulWidget {
  @override
  State<_OrderRoomFormContent> createState() => _OrderRoomFormContentState();
}

class _OrderRoomFormContentState extends State<_OrderRoomFormContent> {
  final _orderersNameController = TextEditingController();
  final _priceServiceController = TextEditingController();
  final _totalPaymentController = TextEditingController();
  final _ordererPhoneControler = TextEditingController();
  String _paymentMethod = "COD";
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Material(
        color: Colors.black,
        child: Consumer2<AuthProvider, RoomProvider>(
          builder: (context, authProvider, roomProvider, child) {
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
                            Text(
                              'Data Pemesan',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.7)),
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(_orderersNameController, 'Nama'),
                            const SizedBox(height: 16),
                            _buildTextField(
                                _ordererPhoneControler, 'No Telfon'),
                            const SizedBox(height: 16),
                            Text(
                              'Pilih Ruangan',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.7)),
                            ),
                            const SizedBox(height: 16),
                            _buildDropdownRoomField(),
                            Text(
                              'Kelas Ruangan',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.7)),
                            ),
                            const SizedBox(height: 16),
                            _buildDropdownRoomTypeField(),
                            const SizedBox(height: 16),
                            Text(
                              'Layanan',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.7)),
                            ),
                            _buildDropdownServiceField(),
                            const SizedBox(height: 16),
                            _buildPriceTextField(),
                            const SizedBox(height: 16),
                            _buildExtraServices(),
                            const SizedBox(height: 16),
                            const Text(
                              "Tentuka Tanggal dan Waktu Pemensanan",
                              style: TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 16),
                            _buildDateField(context),
                            const SizedBox(height: 16),
                            _buildTimeField(context, true),
                            const SizedBox(height: 16),
                            _buildTimeField(context, false),
                            const SizedBox(height: 16),
                            const Text(
                              "Total Pembayaran",
                              style: TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 16),
                            _buildTotalPaymentTextField(),
                            const SizedBox(height: 24),
                            _buildDropdownPaymentMethodField(),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondary),
                              onPressed: _isLoading
                                  ? null
                                  : () => _handleReservation(context),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
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
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Validasi input dasar
      if (!_validateInputs(context)) {
        return;
      }

      final reservationProvider = context.read<ReservationProvider>();
      final roomProvider = context.read<RoomProvider>();
      final profileProvider = context.read<ProfilesProvider>();
      final extraService = context.read<ExtraServicesProvider>();
      final authProvider = context.read<AuthProvider>();

      // 2. Validasi ketersediaan waktu
      if (!await _validateTimeSlot(
          context, reservationProvider, roomProvider)) {
        return;
      }

      // 3. Buat objek Order
      Order order = _createOrder(
        authProvider,
        roomProvider,
        profileProvider,
        extraService,
        reservationProvider,
      );

      // 4. Proses berdasarkan metode pembayaran
      if (_paymentMethod == "COD") {
        if (!context.mounted) return;
        await _processCODPayment(order, reservationProvider, context);
      } else {
        if (!context.mounted) return;
        await _processOnlinePayment(order, context);
      }
    } catch (e) {
        if (!context.mounted) return;
      _handleError(context, e);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _validateInputs(BuildContext context) {
    if (_orderersNameController.text.isEmpty ||
        _ordererPhoneControler.text.isEmpty ||
        _paymentMethod.isEmpty) {
      String errorMessage = '';

      if (_orderersNameController.text.isEmpty) {
        errorMessage = 'Nama tidak boleh kosong';
      } else if (_ordererPhoneControler.text.isEmpty) {
        errorMessage = 'No Telepon tidak boleh kosong';
      } else if (_paymentMethod.isEmpty) {
        errorMessage = 'Metode pembayaran tidak boleh kosong';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.redAccent,
        ),
      );
      return false;
    }
    return true;
  }

  Future<bool> _validateTimeSlot(
    BuildContext context,
    ReservationProvider reservationProvider,
    RoomProvider roomProvider,
  ) async {
    if (reservationProvider.selectedDate == null ||
        reservationProvider.startTime == null ||
        reservationProvider.endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanggal dan waktu tidak boleh kosong'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return false;
    }

    bool isAvailable = await reservationProvider.isTimeSlotAvailable(
      roomProvider.selectedDetailRoom!.room.id!,
      reservationProvider.selectedDate!,
      reservationProvider.startTime!,
      reservationProvider.endTime!,
    );

    if (!isAvailable && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Slot waktu ini tidak tersedia'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return false;
    }

    return true;
  }

  Order _createOrder(
    AuthProvider authProvider,
    RoomProvider roomProvider,
    ProfilesProvider profileProvider,
    ExtraServicesProvider extraService,
    ReservationProvider reservationProvider,
  ) {
    return Order(
      id: "RSO-${generateNow()}",
      roomId: roomProvider.selectedDetailRoom!.room.id!,
      accountId: authProvider.userId!,
      ordererName: _orderersNameController.text,
      ordererEmail: profileProvider.currentProfile!.email,
      ordererPhone: _ordererPhoneControler.text,
      totalPrice: reservationProvider.totalPayment,
      extraServices: extraService.extraServicesSelected
          .map((service) => service.id)
          .toList(),
      statusOrder: 'ordered',
      statusPayment: 'pending',
      paymentMethod: _paymentMethod,
      startTime: reservationProvider.startTime!,
      endTime: reservationProvider.endTime!,
      date: reservationProvider.selectedDate!,
    );
  }

  Future<void> _processCODPayment(
    Order order,
    ReservationProvider reservationProvider,
    BuildContext context,
  ) async {
    order.paid = false;
    await reservationProvider.saveReservation(order);
    if (context.mounted) {
      Navigator.of(context).pushNamed("/payment_done");
    }
  }

  Future<void> _processOnlinePayment(Order order, BuildContext context) async {
    PaymentService paymentService = PaymentService();

    // Set current order sebelum memulai pembayaran
    final reservationProvider = context.read<ReservationProvider>();
    reservationProvider.currentOrder = order;

    // Mulai proses pembayaran Midtrans
    if (context.mounted) {
      await paymentService.startPayment(context, order);
    }
  }

  void _handleError(BuildContext context, dynamic error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $error'),
          backgroundColor: Colors.redAccent,
        ),
      );
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
            roomProvider.selectedDetailRoom?.roomService.price != null
                ? currencyFormatter
                    .format(roomProvider.selectedDetailRoom!.roomService.price)
                : "0";

        return TextField(
          readOnly: true,
          controller: _priceServiceController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
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
            hintText: reservationProvider.totalPayment != null
                ? currencyFormatter.format(reservationProvider.totalPayment!)
                : roomProvider.selectedDetailRoom != null
                    ? currencyFormatter
                        .format(roomProvider.selectedRoom!.pricePerHour)
                    : "0",
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
            value: roomProvider.selectedDetailRoom?.roomType.name,
            items: [
              DropdownMenuItem<String>(
                value: roomProvider.selectedDetailRoom?.roomType.name,
                child: Text(
                  roomProvider.selectedDetailRoom?.roomType.name ?? "",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
            onChanged: null, // This makes the dropdown disabled
            disabledHint: Text(
              roomProvider.selectedDetailRoom?.roomType.name ?? "",
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDropdownRoomField() {
    return Consumer<RoomProvider>(
      builder: (context, roomProvider, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<Room>(
            decoration: InputDecoration(
              hintText: "Pilih Ruangan",
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            style: const TextStyle(color: Colors.white),
            dropdownColor: Colors.grey[800],
            value: roomProvider.selectedRoom,
            items: [
              ...roomProvider.rooms.map((room) {
                return DropdownMenuItem<Room>(
                  value: room,
                  child: Text(
                    room.name ?? "",
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }),
            ],
            onChanged: (Room? room) async {
              DetailRoom? detailRoom =
                  await roomProvider.getRoomDetail(room!.id!);
              roomProvider.selectDetailRoom(detailRoom!);
            }, // This makes the dropdown disabled
          ),
        );
      },
    );
  }

  Widget _buildDropdownServiceField() {
    return Consumer2<RoomProvider, RoomServicesProvider>(
      builder: (context, roomProvider, roomServicesProvider, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: roomProvider.selectDetailRoom != null
              ? DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    hintText: "Service",
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                  style: const TextStyle(color: Colors.white),
                  dropdownColor: Colors.grey[800],
                  value: roomProvider.selectedDetailRoom?.roomService.name,
                  items: [
                    DropdownMenuItem<String>(
                      value: roomProvider.selectedDetailRoom?.roomService.name,
                      child: Text(
                        roomProvider.selectedDetailRoom?.roomService.name ?? "",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                  onChanged: null, // This makes the dropdown disabled
                  disabledHint: Text(
                    roomProvider.selectedDetailRoom?.roomService.name ?? "",
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                )
              : DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    hintText: "Service",
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                  style: const TextStyle(color: Colors.white),
                  dropdownColor: Colors.grey[800],
                  value: "",
                  items: [
                    ...roomServicesProvider.services.map((service) {
                      return DropdownMenuItem<String>(
                        value:
                            roomProvider.selectedDetailRoom?.roomService.name,
                        child: Text(
                          roomProvider.selectedDetailRoom?.roomService.name ??
                              "",
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }),
                  ],
                  onChanged: null, // This makes the dropdown disabled
                  disabledHint: Text(
                    roomProvider.selectedDetailRoom?.roomService.name ?? "",
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
              roomProvider.selectedDetailRoom?.roomService.name ?? "",
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
          style: const TextStyle(color: Colors.white),
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
    return Consumer3<ReservationProvider, RoomProvider, ExtraServicesProvider>(
      builder:
          (context, reservationProvider, roomProvider, extraService, child) {
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

                  reservationProvider.calculateTotal(roomProvider.selectedRoom,
                      extraService.extraServicesSelected);
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

                  reservationProvider.calculateTotal(roomProvider.selectedRoom,
                      extraService.extraServicesSelected);
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
