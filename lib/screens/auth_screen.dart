import 'package:flutter/material.dart';
import 'package:zhaiyana/main.dart'; // Импортируем наш supabase клиент
import 'package:zhaiyana/screens/athlete_registration_screen.dart'; // Импортируем экран регистрации
import 'dart:async'; // Для работы с асинхронностью

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoginMode = true;
  bool _isLoading = false; // Состояние для индикатора загрузки
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Основная функция для входа/регистрации
  Future<void> _submitAuthForm() async {
    // Скрываем клавиатуру
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return; // Если форма не валидна, выходим
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      if (_isLoginMode) {
        // --- ЛОГИКА ВХОДА ---
        await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );
      } else {
        // --- ЛОГИКА РЕГИСТРАЦИИ ---
        final response = await supabase.auth.signUp(
          email: email,
          password: password,
        );
        // После успешной регистрации сразу переходим к созданию профиля
        if (response.user != null && mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (context) => const AthleteRegistrationScreen()),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error.toString()),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _isLoginMode ? 'Вход' : 'Регистрация',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || !value.contains('@')) {
                        return 'Пожалуйста, введите корректный email.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Пароль'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'Пароль должен быть не менее 6 символов.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitAuthForm,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 3),
                          )
                        : Text(_isLoginMode ? 'Войти' : 'Создать аккаунт'),
                  ),
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            setState(() {
                              _isLoginMode = !_isLoginMode;
                            });
                          },
                    child: Text(
                      _isLoginMode
                          ? 'У меня еще нет аккаунта'
                          : 'У меня уже есть аккаунт',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}