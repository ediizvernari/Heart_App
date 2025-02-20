import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/screens/client_personal_data_insertion_page.dart';
import 'package:frontend/screens/home_page.dart';

class ClientMainPage extends StatelessWidget {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  const ClientMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      String? token = await storage.read(key: 'auth_token');
      if (token == null || token.isEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    });

    int crossAxisCount = MediaQuery.of(context).size.width > 600 ? 3 : 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome, Edi Izvernari'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: _menuItems.length,
          itemBuilder: (context, index) {
            final item = _menuItems[index];
            return _buildGridItem(context, item);
          },
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SizedBox(
          width: double.infinity,
          height: 60, // Increased button height
          child: ElevatedButton(
            onPressed: () => _handleLogout(context),
            child: const Text('Logout', style: TextStyle(fontSize: 18)),
          ),
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await storage.delete(key: 'auth_token');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () => item['onTap'](context),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        color: Colors.blueGrey[50],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item['icon'], size: 50, color: Colors.blueGrey[800]),
            const SizedBox(height: 10),
            Text(item['label'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

//TODO: Add functionality for each of the menu Items
final List<Map<String, dynamic>> _menuItems = [
  {
    'icon': Icons.calendar_today,
    'label': 'Appointments',
    'onTap': (context) => Navigator.pushNamed(context, '/appointments'),
  },
  {
    'icon': Icons.chat,
    'label': 'Doctor Chat',
    'onTap': (context) => Navigator.pushNamed(context, '/doctor_chat'),
  },
  {
    'icon': Icons.insert_chart,
    'label': 'Data Insertion',
    'onTap': (context) => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ClientPersonalDataInsertionPage())),
  },
  {
    'icon': Icons.chat_bubble,
    'label': 'Chatbot',
    'onTap': (context) => Navigator.pushNamed(context, '/chatbot'),
  },
];
