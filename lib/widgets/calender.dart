import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:zenith_coffee_shop/providers/reservation_provider.dart';
import 'package:zenith_coffee_shop/themes/app_color.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  late Map<DateTime, dynamic> selectedEvents;
  CalendarFormat format = CalendarFormat.month;

  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();

  final TextEditingController _eventController = TextEditingController();

  @override
  void initState() {
    selectedEvents = {};
    super.initState();
  }

  List<String> _getEventsfromDay(DateTime date) {
    return selectedEvents[date] ?? [];
  }

  @override
  void dispose() {
    _eventController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppColors.primary,
        title: const Text(
          "Pilih Tanggal Pemesanan",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Consumer<ReservationProvider>(
        builder: (context, reservationProvider, child) {
          return Column(
            children: [
              TableCalendar(
                focusedDay: selectedDay,
                firstDay: DateTime(2000),
                lastDay: DateTime(2050),
                calendarFormat: format,
                onFormatChanged: (CalendarFormat format) {
                  setState(() {
                    format = format;
                  });
                },
                startingDayOfWeek: StartingDayOfWeek.sunday,
                daysOfWeekVisible: true,

                //Day Changed
                onDaySelected: (DateTime selectDay, DateTime focusDay) {
                  setState(() {
                    selectedDay = selectDay;
                    focusedDay = focusDay;
                  });
                  if (_eventController.text.isEmpty) {
                  } else {
                    if (selectedEvents[selectedDay] != null) {
                      selectedEvents[selectedDay].add(
                        _eventController.text,
                      );
                      reservationProvider.setDate(selectDay);
                    } else {
                      selectedEvents[selectedDay] = [_eventController.text];
                    }
                  }

                  return;
                },
                selectedDayPredicate: (DateTime date) {
                  return isSameDay(selectedDay, date);
                },

                eventLoader: _getEventsfromDay,

                //To style the Calendar

                calendarStyle: CalendarStyle(
                  isTodayHighlighted: true,
                  selectedDecoration: BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  selectedTextStyle: const TextStyle(color: Colors.white),
                  todayDecoration: BoxDecoration(
                    color: AppColors.gray,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  defaultTextStyle: const TextStyle(color: Colors.white),
                  defaultDecoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  weekendDecoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                headerStyle: HeaderStyle(
                  leftChevronIcon: const Icon(
                    size: 15,
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                  ),
                  rightChevronIcon: const Icon(
                    size: 15,
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                  ),
                  titleTextStyle: const TextStyle(color: Colors.white),
                  formatButtonVisible: true,
                  titleCentered: true,
                  formatButtonShowsNext: false,
                  formatButtonDecoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  formatButtonTextStyle: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              ..._getEventsfromDay(selectedDay).map(
                (String event) => ListTile(
                  title: Text(
                    event,
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: selectedEvents[selectedDay] != null
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.pop(context);
                _eventController.clear();
                setState(() {});
                print(focusedDay);
              },
              label: const Text("Lanjut"), 
            )
          : null,
    );
  }
}
