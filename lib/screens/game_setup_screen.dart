import 'package:flutter/material.dart';
import 'package:zhaiyana/main.dart';
import 'package:zhaiyana/screens/home_screen.dart';

class GameSetupScreen extends StatefulWidget {
  final int fieldId;
  final DateTime bookingTime;

  const GameSetupScreen(
      {super.key, required this.fieldId, required this.bookingTime});

  @override
  State<GameSetupScreen> createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends State<GameSetupScreen> {
  final _descriptionController = TextEditingController();
  final _playersController = TextEditingController(text: '10'); // Значение по умолчанию
  bool _isPublic = false;
  String? _selectedSkillLevel = 'Любители';
  bool _isLoading = false;

  final List<String> _skillLevels = ['Любители', 'Продвинутые', 'Профи'];

  Future<void> _createGame() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = supabase.auth.currentUser!.id;

      await supabase.from('bookings').insert({
        'field_id': widget.fieldId,
        'user_id': userId,
        'booking_start_time': widget.bookingTime.toIso8601String(),
        'status': 'confirmed',
        'is_public': _isPublic,
        'required_players': int.parse(_playersController.text),
        'skill_level': _selectedSkillLevel,
        'description': _descriptionController.text,
      });

       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Игра успешно создана!'),
          backgroundColor: Colors.green,
        ));
        // Переходим на главный экран, очищая все предыдущие
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
           (route) => false,
        );
      }

    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Ошибка создания игры: $error'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if(mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

 @override
  void dispose() {
    _descriptionController.dispose();
    _playersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройка игры'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Переключатель "Публичная игра"
            SwitchListTile.adaptive(
              title: const Text('Публичная игра?', style: TextStyle(fontSize: 18)),
              subtitle: const Text('Другие смогут присоединиться'),
              value: _isPublic,
              onChanged: (bool value) {
                setState(() {
                  _isPublic = value;
                });
              },
              activeColor: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 20),
            // Уровень мастерства
            DropdownButtonFormField<String>(
              value: _selectedSkillLevel,
              items: _skillLevels.map((String level) {
                return DropdownMenuItem<String>(
                  value: level,
                  child: Text(level),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedSkillLevel = newValue;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Уровень мастерства',
              ),
            ),
            const SizedBox(height: 20),
            // Количество игроков
            TextFormField(
              controller: _playersController,
              decoration: const InputDecoration(labelText: 'Количество игроков'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            // Описание
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Описание игры (необязательно)',
                alignLabelWithHint: true,
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _createGame,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white,) : const Text('Создать игру'),
            )
          ],
        ),
      ),
    );
  }
}