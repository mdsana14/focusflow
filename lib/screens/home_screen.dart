import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_screen.dart';
import 'welcome_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<Map<String, dynamic>> tasks = [];
  List<String> categories = ['General', 'Work', 'Study', 'Personal'];

  final TextEditingController _taskController = TextEditingController();

  bool isDark = false;
  DateTime selectedDate = DateTime.now();
  int streak = 1;
  String lastCompletedDay = '';

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('tasks');
    if (saved != null) {
      try {
        tasks = List<Map<String, dynamic>>.from(jsonDecode(saved));
      } catch (_) {
        tasks = [];
      }
    }
    categories = prefs.getStringList('categories') ?? categories;
    isDark = prefs.getBool('isDark') ?? false;
    lastCompletedDay = prefs.getString('lastDay') ?? '';
    streak = prefs.getInt('streak') ?? 1;

    final today = DateTime.now();
    if (lastCompletedDay.isNotEmpty) {
      try {
        final parsed = DateTime.parse(lastCompletedDay);
        final diff = today.difference(parsed).inDays;
        if (diff > 1) streak = 1;
      } catch (_) {}
    }

    setState(() {});
  }

  Future<void> _saveAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tasks', jsonEncode(tasks));
    await prefs.setStringList('categories', categories);
    await prefs.setBool('isDark', isDark);
    await prefs.setInt('streak', streak);
    await prefs.setString('lastDay', lastCompletedDay);
  }

  void _addTask({required String title, required String category, String priority = 'Medium'}) {
    final task = {
      'title': title,
      'category': category,
      'priority': priority,
      'completed': false,
      'date': selectedDate.toIso8601String(),
    };
    tasks.insert(0, task);
    _taskController.clear();
    _saveAll();
    setState(() {});
  }

  void _deleteTask(int idx) {
    tasks.removeAt(idx);
    _saveAll();
    setState(() {});
  }

  void _toggleComplete(int idx) async {
    tasks[idx]['completed'] = !(tasks[idx]['completed'] as bool);
    if (tasks[idx]['completed'] == true) {
      final todayDay = DateTime.now().toIso8601String().split('T')[0];
      if (lastCompletedDay != todayDay) {
        streak += 1;
        lastCompletedDay = todayDay;
      }
    }
    await _saveAll();
    setState(() {});
  }

  void _showAddDialog() {
    String selectedCat = categories.isNotEmpty ? categories[0] : 'General';
    String selectedPriority = 'Medium';
    final ctl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: ctl, decoration: const InputDecoration(hintText: 'Task')),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedCat,
                items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => selectedCat = v ?? selectedCat,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedPriority,
                items: ['High', 'Medium', 'Low'].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                onChanged: (v) => selectedPriority = v ?? selectedPriority,
                decoration: const InputDecoration(labelText: 'Priority'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final text = ctl.text.trim();
                if (text.isNotEmpty) {
                  _addTask(title: text, category: selectedCat, priority: selectedPriority);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  void _navigateToWelcome() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const WelcomeScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  Widget _statCard(String label, int value, Color color) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('$value', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasksToday = tasks.where((t) {
      final d = DateTime.parse(t['date']);
      return d.year == selectedDate.year && d.month == selectedDate.month && d.day == selectedDate.day;
    }).toList();
    final completed = tasks.where((t) => t['completed'] == true).length;
    final pending = tasks.length - completed;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: isDark
          ? ThemeData.dark(useMaterial3: true)
          : ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('FocusFlow'),
          actions: [
            IconButton(icon: const Icon(Icons.home), tooltip: "Back to Welcome", onPressed: _navigateToWelcome),
            IconButton(
              icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
              onPressed: () {
                setState(() {
                  isDark = !isDark;
                  _saveAll();
                });
              },
            ),
            IconButton(icon: const Icon(Icons.calendar_month), onPressed: _pickDate),
            IconButton(
              icon: const Icon(Icons.bar_chart),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DashboardScreen(tasks: tasks, streak: streak)),
                );
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Date & streak chip
              Row(
                children: [
                  const Icon(Icons.calendar_today),
                  const SizedBox(width: 8),
                  Text('${selectedDate.day}-${selectedDate.month}-${selectedDate.year}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Chip(
                    label: Text('🔥 Streak: $streak', style: const TextStyle(color: Colors.orange)),
                    backgroundColor: Colors.orange.withOpacity(0.15),
                  )
                ],
              ),
              const SizedBox(height: 16),

              // Stats row
              Row(
                children: [
                  _statCard('Today', tasksToday.length, Colors.blue),
                  const SizedBox(width: 12),
                  _statCard('Completed', completed, Colors.green),
                  const SizedBox(width: 12),
                  _statCard('Pending', pending, Colors.red),
                ],
              ),
              const SizedBox(height: 12),

              // Task list
              Expanded(
                child: tasks.isEmpty
                    ? const Center(child: Text('No tasks yet — add one!', style: TextStyle(fontSize: 16)))
                    : ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, i) {
                          final t = tasks[i];
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey[800] : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ListTile(
                              leading: Checkbox(value: t['completed'], onChanged: (_) => _toggleComplete(i)),
                              title: Text(t['title']),
                              subtitle: Text('${t['category']} • ${DateTime.parse(t['date']).toLocal().toString().split(' ')[0]}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(icon: const Icon(Icons.edit), onPressed: _showAddDialog),
                                  IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteTask(i)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddDialog,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}


