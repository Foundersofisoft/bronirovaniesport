import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zhaiyana/main.dart';

class PublicGamesList extends StatefulWidget {
  const PublicGamesList({super.key});

  @override
  State<PublicGamesList> createState() => _PublicGamesListState();
}

class _PublicGamesListState extends State<PublicGamesList> {
  // Используем Future, чтобы не перезагружать список при каждом обновлении виджета
  late final Future<List<Map<String, dynamic>>> _gamesFuture;

  @override
  void initState() {
    super.initState();
    _gamesFuture = _fetchPublicGames();
  }

  // Обновляем запрос, чтобы он считал количество участников
  Future<List<Map<String, dynamic>>> _fetchPublicGames() async {
    final response = await supabase
        .from('bookings')
        .select('*, fields(*), profiles:user_id(*), game_participants(count)') // Считаем участников
        .eq('is_public', true)
        .gt('booking_start_time', DateTime.now().toIso8601String())
        .order('booking_start_time', ascending: true);
    
    return (response as List).cast<Map<String, dynamic>>();
  }

  // Функция присоединения к игре
  Future<void> _joinGame(int bookingId) async {
    try {
      final userId = supabase.auth.currentUser!.id;

      // Проверяем, не присоединился ли пользователь уже к этой игре
      final existingParticipant = await supabase
          .from('game_participants')
          .select()
          .eq('booking_id', bookingId)
          .eq('user_id', userId);

      if (existingParticipant.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Вы уже присоединились к этой игре.'),
            backgroundColor: Colors.orange,
          ));
        }
        return;
      }

      // Если не присоединялся, добавляем его
      await supabase.from('game_participants').insert({
        'booking_id': bookingId,
        'user_id': userId,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Вы успешно присоединились к игре!'),
          backgroundColor: Colors.green,
        ));
        // Обновляем список игр, чтобы увидеть изменения
        setState(() {
          _gamesFuture = _fetchPublicGames();
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Ошибка: $error'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = supabase.auth.currentUser!.id;

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _gamesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Ошибка: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Нет доступных публичных игр.'));
        }

        final games = snapshot.data!;

        return ListView.builder(
          itemCount: games.length,
          itemBuilder: (context, index) {
            final game = games[index];
            final field = game['fields'];
            final profile = game['profiles'];
            final bookingTime = DateTime.parse(game['booking_start_time']);
            
            final participants = game['game_participants'];
            final participantCount = participants[0]['count']; // Получаем посчитанное значение
            final requiredPlayers = game['required_players'];
            final isFull = participantCount >= requiredPlayers;
            final isCaptain = game['user_id'] == currentUserId;

            final formattedDate = DateFormat('d MMMM, EEEE', 'ru').format(bookingTime);
            final formattedTime = DateFormat('HH:mm').format(bookingTime);
            
            final captainName = profile?['full_name'] ?? 'Неизвестный капитан';

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${field['name']} - ${field['address']}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text('$formattedDate в $formattedTime', style: TextStyle(fontSize: 16, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),),
                    const SizedBox(height: 8),
                    Text('Уровень: ${game['skill_level']}'),
                    const SizedBox(height: 8),
                    Text('Капитан: $captainName'),
                    const SizedBox(height: 8),
                    Text('Игроки: $participantCount / $requiredPlayers', style: const TextStyle(fontWeight: FontWeight.bold),),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      // Блокируем кнопку, если игра заполнена или пользователь - капитан
                      onPressed: isFull || isCaptain ? null : () => _joinGame(game['id']),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isFull ? Colors.grey[800] : Theme.of(context).primaryColor
                      ),
                      child: Text(isCaptain ? 'Вы капитан' : (isFull ? 'Мест нет' : 'Присоединиться')),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}