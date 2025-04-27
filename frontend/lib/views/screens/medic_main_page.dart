import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/views/screens/auth/home_screen.dart';
import 'package:frontend/utils/validators/session_validator.dart';

class MedicMainPage extends StatefulWidget {
  const MedicMainPage({super.key});

  @override
  State<MedicMainPage> createState() => _MedicMainPageState();
}

class _MedicMainPageState extends State<MedicMainPage> {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  String? token;
  bool _loadingToken = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await SessionValidator.verifyToken(context);
      final storedToken = await storage.read(key: 'auth_token');
      setState(() {
        token = storedToken;
        _loadingToken = false;
      });
    });
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
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
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // show a loader until token check is done
    if (_loadingToken) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medic Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Hello, Medic!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
