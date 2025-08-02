import 'package:flutter/material.dart';
import 'package:zhaiyana/main.dart';

class FieldDetailScreen extends StatefulWidget {
  final int fieldId; // ID поля, которое нужно отобразить

  const FieldDetailScreen({super.key, required this.fieldId});

  @override
  State<FieldDetailScreen> createState() => _FieldDetailScreenState();
}

class _FieldDetailScreenState extends State<FieldDetailScreen> {
  Map<String, dynamic>? _fieldData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFieldDetails();
  }

  // Загружаем данные для конкретного поля по его ID
  Future<void> _fetchFieldDetails() async {
    try {
      final response = await supabase
          .from('fields')
          .select()
          .eq('id', widget.fieldId)
          .single();
      setState(() {
        _fieldData = response;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки данных: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Название в аппбаре появится после загрузки
        title: Text(_fieldData?['name'] ?? 'Загрузка...'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _fieldData == null
              ? const Center(child: Text('Не удалось загрузить данные о поле.'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Image.network(
                        _fieldData!['photo_url'],
                        height: 250,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                           return Container(
                            height: 250,
                            color: Colors.grey[800],
                            child: const Center(
                              child: Icon(Icons.sports_hockey, size: 60),
                            ),
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _fieldData!['name'],
                              style: const TextStyle(
                                  fontSize: 26, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _fieldData!['address'],
                              style: const TextStyle(fontSize: 18, color: Colors.white70),
                            ),
                            const SizedBox(height: 24),
                             Text(
                              '${_fieldData!['price_per_hour']} KZT/час',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Начать процесс бронирования
                          },
                          child: const Text('Арендовать'),
                        ),
                      )
                    ],
                  ),
                ),
    );
  }
}