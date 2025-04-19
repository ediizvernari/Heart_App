import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/handlers/client_cvd_prediction_button_handler.dart';
import 'package:frontend/views/screens/client_personal_data_insertion_page.dart';
import 'package:frontend/views/screens/auth/home_screen.dart';
import 'package:frontend/utils/validators/sessio_validator.dart';

class ClientMainPage extends StatefulWidget {
  const ClientMainPage({super.key});

  @override
  State<ClientMainPage> createState() => _ClientMainPageState();
}

class _ClientMainPageState extends State<ClientMainPage> {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  String? token;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await SessionValidator.verifyToken(context);
      final storedToken = await storage.read(key: 'auth_token');
      setState(() {
        token = storedToken;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
          itemCount: _menuItems(context).length,
          itemBuilder: (context, index) {
            final item = _menuItems(context)[index];
            return _buildGridItem(context, item);
          },
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SizedBox(
          width: double.infinity,
          height: 60,
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
                MaterialPageRoute(builder: (context) => const HomeScreen()),
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

  List<Map<String, dynamic>> _menuItems(BuildContext context) => [
        {
          'icon': Icons.calendar_today,
          'label': 'Appointments',
          'onTap': (context) => Navigator.pushNamed(context, '/appointments'),
        },
        {
          'icon': Icons.health_and_safety,
          'label': 'Predict Risk of CVD',
          'onTap': (context) => handleCVDPredictionButtonTap(context, token),
        },
        {
          'icon': Icons.insert_chart,
          'label': 'Data Insertion',
          'onTap': (context) => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ClientPersonalDataInsertionPage()),
              ),
        },
        {
          'icon': Icons.chat_bubble,
          'label': 'Chatbot',
          'onTap': (context) => Navigator.pushNamed(context, '/chatbot'),
        },
      ];
}
