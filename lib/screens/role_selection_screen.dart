import 'package:flutter/material.dart';
import 'package:zhaiyana/screens/athlete_registration_screen.dart'; // Импортируем экран регистрации

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Выберите вашу роль',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 50),
              // Кнопка Спортсмен
              ElevatedButton(
                style: Theme.of(context).elevatedButtonTheme.style,
                onPressed: () {
                  // === НАША НОВАЯ ЛОГИКА ПЕРЕХОДА ===
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AthleteRegistrationScreen()),
                  );
                  // ===================================
                },
                child: const Column(
                  children: [
                    Text('Спортсмен'),
                    SizedBox(height: 4),
                    Text(
                      'Организовать и играть',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Кнопка Заведение
              ElevatedButton(
                // Используем другой стиль для разнообразия
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1E1E1E), // Тёмный текст
                ),
                onPressed: () {
                  // TODO: Добавить навигацию на экран регистрации заведения
                  print('Выбрана роль: Заведение');
                },
                child: const Column(
                  children: [
                    Text('Заведение'),
                    SizedBox(height: 4),
                    Text(
                      'Сдавать поля в аренду',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}