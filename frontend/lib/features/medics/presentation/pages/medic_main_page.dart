import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../utils/validators/session_validator.dart';
import '../../../auth/presentation/screens/home_screen.dart';
import 'medic_patients_page.dart';

class MedicMainPage extends StatefulWidget {
  const MedicMainPage({super.key});

  @override
  State<MedicMainPage> createState() => _MedicMainPageState();
}

class _MedicMainPageState extends State<MedicMainPage> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _loadingToken = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await SessionValidator.verifyToken(context);
      setState(() => _loadingToken = false);
    });
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await _storage.delete(key: 'auth_token');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingToken) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.softGrey,
      appBar: AppBar(
        title: const Text('Medic Dashboard'),
        backgroundColor: AppColors.primaryRed,
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: _handleLogout)],
      ),
      drawer: Drawer(
        child: ListView(padding: EdgeInsets.zero, children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Text(
              'Menu',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('My Patients'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MedicPatientsPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.medical_services),
            title: const Text('My Services'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/medical-services');
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('My Appointments'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/medic-appointments');
            },
          ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('My Availability'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/medic-availability');
            },
          ),
        ]),
      ),
      body: const Center(
        child: Text('Hello, Medic!', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}