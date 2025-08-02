import 'package:flutter/material.dart';
import 'package:zhaiyana/main.dart';
import 'package:zhaiyana/screens/home_screen.dart'; // Импортируем HomeScreen

class AthleteRegistrationScreen extends StatefulWidget {
  const AthleteRegistrationScreen({super.key});

  @override
  State<AthleteRegistrationScreen> createState() =>
      _AthleteRegistrationScreenState();
}

class _AthleteRegistrationScreenState
    extends State<AthleteRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _experienceController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedPosition;
  double _skillLevel = 5.0;
  bool _isLoading = false;

  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = supabase.auth.currentUser!.id; // Получаем ID текущего пользователя
      final fullName = _fullNameController.text;
      final position = _selectedPosition;
      final skillLevel = _skillLevel.toInt();
      final experience = int.tryParse(_experienceController.text) ?? 0;
      final description = _descriptionController.text;

      // Отправляем данные в таблицу 'profiles', включая user_id
      await supabase.from('profiles').insert({
        'user_id': userId, // === ВАЖНОЕ ИЗМЕНЕНИЕ ===
        'full_name': fullName,
        'position': position,
        'skill_level': skillLevel,
        'experience_years': experience,
        'description': description,
      });

      if (mounted) {
        // Переходим на главный экран и удаляем все предыдущие экраны из стека
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Ошибка: ${error.toString()}'),
          backgroundColor: Colors.red,
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
    _fullNameController.dispose();
    _experienceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // --- Весь остальной код (build, _buildTextField и т.д.) остается без изменений ---
  // --- Просто скопируй его из своей предыдущей версии файла ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Создание профиля спортсмена'),
        automaticallyImplyLeading: false, // Убираем кнопку "назад"
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('ФИО', style: TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 8),
                _buildTextField(
                  hintText: 'Введите ваше полное имя',
                  controller: _fullNameController,
                ),
                const SizedBox(height: 20),

                const Text('Позиция на поле', style: TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 8),
                _buildDropdownField(
                  hintText: 'Выберите позицию',
                  items: ['Нападение', 'Защита', 'Вратарь'],
                  value: _selectedPosition,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedPosition = newValue;
                    });
                  },
                ),
                const SizedBox(height: 20),

                const Text('Уровень мастерства (как в Faceit)', style: TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 8),
                _buildSkillSlider(),
                const SizedBox(height: 20),

                const Text('Опыт (лет)', style: TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 8),
                _buildTextField(
                  hintText: 'Сколько полных лет играете?',
                  keyboardType: TextInputType.number,
                  controller: _experienceController,
                ),
                const SizedBox(height: 20),

                const Text('Описание', style: TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 8),
                _buildTextField(
                  hintText: 'Расскажите о себе',
                  maxLines: 4,
                  controller: _descriptionController,
                ),
                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: _isLoading ? null : _submitProfile,
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white,) : const Text('Сохранить профиль'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

   Widget _buildTextField({
    required String hintText,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: (value) {
        if(value == null || value.isEmpty){
          return 'Поле не может быть пустым';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white38),
      ),
    );
  }

  Widget _buildDropdownField({
    required String hintText,
    required List<String> items,
    String? value,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: Text(hintText, style: const TextStyle(color: Colors.white38)),
      isExpanded: true,
      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFFF5500)),
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      validator: (value) => value == null ? 'Пожалуйста, выберите опцию' : null,
      onChanged: onChanged,
    );
  }

  Widget _buildSkillSlider() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Slider(
        value: _skillLevel,
        min: 1,
        max: 10,
        divisions: 9,
        label: _skillLevel.round().toString(),
        activeColor: const Color(0xFFFF5500),
        inactiveColor: Colors.white38,
        onChanged: (double value) {
          setState(() {
            _skillLevel = value;
          });
        },
      ),
    );
  }
}