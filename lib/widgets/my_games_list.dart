import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zhaiyana/main.dart';

class MyGamesList extends StatefulWidget {
  const MyGamesList({super.key});

  @override
  State<MyGamesList> createState() => _MyGamesListState();
}

class _MyGamesListState extends State<MyGamesList> {
  late final Future<List<Map<String, dynamic>>> _myGamesFuture;

  @override
  void initState() {
    super.initState();
    _myGamesFuture = _fetchMyGames();
  }

  Future<List<Map<String, dynamic>>> _fetchMyGames() async {
    final userId = supabase.auth.currentUser!.id;

    // 1. Получаем игры, где я - участник
    // Используем inner join, чтобы сразу получить данные о бронировании
    final participantGamesResponse = await supabase
        .from('game_participants')
        .select('bookings!inner(*, fields(*), profiles:user_id(*))')
        .eq('user_id', userId);

    // Извлекаем именно данные бронирований из ответа
    final List<Map<String, dynamic>> joinedGames =
        (participantGamesResponse as List)
            .map((e) => e['bookings'] as Map<String, dynamic>)
            .toList();

    // 2. Получаем игры, где я - капитан
    final captainGamesResponse = await supabase
        .from('bookings')
        .select('*, fields(*), profiles:user_id(*)')
        .eq('user_id', userId);
    
    final List<Map<String, dynamic>> captainGames = (captainGamesResponse as List).cast<Map<String, dynamic>>();

    // 3. Объединяем списки и убираем дубликаты
    final allGames = {...joinedGames, ...captainGames}.toList();
    
    // 4. Фильтруем прошедшие игры и сортируем
    allGames.retainWhere((game) => DateTime.parse(game['booking_start_time']).isAfter(DateTime.now()));
    allGames.sort((a, b) => DateTime.parse(a['booking_start_time']).compareTo(DateTime.parse(b['booking_start_time'])));

    return allGames;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _myGamesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Ошибка: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('У вас нет предстоящих игр.'));
        }

        final games = snapshot.data!;

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _myGamesFuture = _fetchMyGames();
            });
          },
          child: ListView.builder(
            itemCount: games.length,
            itemBuilder: (context, index) {
              final game = games[index];
              final field = game['fields'];
              final profile = game['profiles'];
              final bookingTime = DateTime.parse(game['booking_start_time']);

              final formattedDate = DateFormat('d MMMM, EEEE', 'ru').format(bookingTime);
              final formattedTime = DateFormat('HH:mm').format(bookingTime);
              final captainName = profile?['full_name'] ?? 'Неизвестный капитан';
              final isCaptain = game['user_id'] == supabase.auth.currentUser!.id;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Статус: Капитан или Участник
                      Text(
                        isCaptain ? 'ВЫ КАПИТАН' : 'ВЫ УЧАСТНИК',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isCaptain ? Theme.of(context).primaryColor : Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${field['name']}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '$formattedDate в $formattedTime',
                        style: const TextStyle(fontSize: 16),
                      ),
                       const SizedBox(height: 8),
                      Text('Капитан: $captainName'),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}