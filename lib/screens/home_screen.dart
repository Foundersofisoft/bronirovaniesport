import 'package:flutter/material.dart';
import 'package:zhaiyana/main.dart';
import 'package:zhaiyana/widgets/fields_list.dart';
import 'package:zhaiyana/widgets/my_games_list.dart'; // Наш новый виджет для "Моих игр"
import 'package:zhaiyana/widgets/public_games_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Теперь у нас 3 вкладки
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zhaiyana'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await supabase.auth.signOut();
            },
            tooltip: 'Выйти',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const <Widget>[
            Tab(
              icon: Icon(Icons.stadium_outlined),
              text: 'Поля',
            ),
            Tab(
              icon: Icon(Icons.groups_outlined),
              text: 'Игры',
            ),
            // Новая вкладка
            Tab(
              icon: Icon(Icons.person_outline),
              text: 'Мои игры',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const <Widget>[
          FieldsList(),
          PublicGamesList(),
          MyGamesList(), // Наш новый виджет
        ],
      ),
    );
  }
}