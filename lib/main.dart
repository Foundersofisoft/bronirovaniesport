import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zhaiyana/screens/home_screen.dart'; // Импортируем HomeScreen
import 'package:zhaiyana/screens/role_selection_screen.dart'; // Импортируем RoleSelectionScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL', // НЕ ЗАБУДЬ СВОИ ДАННЫЕ
    anonKey: 'YOUR_SUPABASE_ANON_KEY', // НЕ ЗАБУДЬ СВОИ ДАННЫЕ
  );

  runApp(const ZhaiyanaApp());
}

final supabase = Supabase.instance.client;

class ZhaiyanaApp extends StatelessWidget {
  const ZhaiyanaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zhaiyana',
      theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: const Color(0xFFFF5500),
          scaffoldBackgroundColor: const Color(0xFF1E1E1E),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            filled: true,
            fillColor: Color(0xFF2A2A2A),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5500),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF2A2A2A),
            elevation: 0,
          )),
      // Используем StreamBuilder для определения, какой экран показать
      home: StreamBuilder<AuthState>(
        stream: supabase.auth.onAuthStateChange,
        builder: (context, snapshot) {
          // Если пользователь вошел в систему (есть сессия)
          if (snapshot.hasData && snapshot.data!.session != null) {
            return const HomeScreen();
          }
          // Если пользователь не вошел, показываем экран выбора роли
          return const RoleSelectionScreen();
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}