import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:zhaiyana/main.dart';
import 'package:zhaiyana/screens/game_setup_screen.dart'; // Импортируем новый экран

class BookingScreen extends StatefulWidget {
  final int fieldId;
  final String fieldName;

  const BookingScreen(
      {super.key, required this.fieldId, required this.fieldName});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  int? _selectedTimeSlot;
  
  List<int> _bookedHours = [];
  bool _isFetchingSlots = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchBookedSlots(_selectedDay!);
  }

  Future<void> _fetchBookedSlots(DateTime day) async {
    setState(() {
      _isFetchingSlots = true;
      _bookedHours.clear();
    });

    try {
      final startOfDay = DateTime(day.year, day.month, day.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await supabase
          .from('bookings')
          .select('booking_start_time')
          .eq('field_id', widget.fieldId)
          .gte('booking_start_time', startOfDay.toIso8601String())
          .lt('booking_start_time', endOfDay.toIso8601String());

      final List<int> booked = [];
      for (var booking in response) {
        final startTime = DateTime.parse(booking['booking_start_time']);
        booked.add(startTime.hour);
      }

      setState(() {
        _bookedHours = booked;
      });
    } catch (error) {
      print('Ошибка загрузки слотов: $error');
    } finally {
      setState(() {
        _isFetchingSlots = false;
      });
    }
  }

  // Эта функция теперь не создает бронь, а переходит на следующий экран
  void _proceedToGameSetup() {
    if (_selectedDay == null || _selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Пожалуйста, выберите дату и время.'),
        backgroundColor: Colors.red,
      ));
      return;
    }
    
    final bookingTime = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
      _selectedTimeSlot!,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameSetupScreen(
          fieldId: widget.fieldId,
          bookingTime: bookingTime,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Бронирование: ${widget.fieldName}'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TableCalendar(
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(const Duration(days: 30)),
                focusedDay: _focusedDay,
                calendarFormat: CalendarFormat.month,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    _selectedTimeSlot = null;
                  });
                  _fetchBookedSlots(selectedDay);
                },
                 calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Выберите время:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              
              _isFetchingSlots 
              ? const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator()))
              : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 2.0,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemCount: 14,
                itemBuilder: (context, index) {
                  final hour = index + 9;
                  final isSelected = _selectedTimeSlot == hour;
                  final isBooked = _bookedHours.contains(hour);

                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected
                          ? Theme.of(context).primaryColor
                          : isBooked ? Colors.grey[800] : const Color(0xFF2A2A2A),
                      foregroundColor: isBooked ? Colors.grey[600] : Colors.white,
                    ),
                    onPressed: isBooked ? null : () {
                      setState(() {
                        _selectedTimeSlot = hour;
                      });
                    },
                    child: Text('$hour:00'),
                  );
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _proceedToGameSetup, // Вызываем новую функцию
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Далее'), // Текст на кнопке изменился
              ),
            ],
          ),
        ),
      ),
    );
  }
}