// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  final List<Map<String, dynamic>> tasks;
  final int streak;

  const DashboardScreen({super.key, this.tasks = const [], this.streak = 0});

  @override
  Widget build(BuildContext context) {
    final total = tasks.length;
    final completed = tasks.where((t) => t['completed'] == true).length;
    final pending = total - completed;

    final Map<String, int> categories = {};
    for (var t in tasks) {
      categories[t['category']] = (categories[t['category']] ?? 0) + 1;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _statCard('Total Tasks', total, Colors.blue),
            const SizedBox(height: 12),
            _statCard('Completed', completed, Colors.green),
            const SizedBox(height: 12),
            _statCard('Pending', pending, Colors.red),
            const SizedBox(height: 18),
            Row(
              children: [
                const Text('Daily Streak',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('$streak days',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            const Text('Category Breakdown',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: categories.entries
                    .map(
                      (e) => ListTile(
                        title: Text(e.key),
                        trailing: Text(e.value.toString()),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String title, int value, Color color) {
  return Expanded(
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeIn,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(value.toString(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    ),
  );
}
}

