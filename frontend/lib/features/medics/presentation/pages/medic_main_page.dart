import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/features/auth/presentation/screens/home_screen.dart';
import 'package:frontend/widgets/custom_app_bar.dart';
import 'package:frontend/widgets/action_card.dart';
import 'package:frontend/widgets/rounded_button.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'medic_patients_page.dart';

class MedicMainPage extends StatefulWidget {
  const MedicMainPage({Key? key}) : super(key: key);

  @override
  State<MedicMainPage> createState() => _MedicMainPageState();
}

class _MedicMainPageState extends State<MedicMainPage> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _checkingAuth = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
        return;
      }
      setState(() => _checkingAuth = false);
    });
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
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
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingAuth) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: CustomAppBar(title: 'Welcome!'),
      ),
      backgroundColor: AppColors.primaryRed,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // First row: My Patients & My Services
                  Row(
                    children: [
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: ActionCard(
                            icon: Icons.people,
                            label: 'My Patients',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const MedicPatientsPage()),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: ActionCard(
                            icon: Icons.medical_services,
                            label: 'My Services',
                            onTap: () => Navigator.pushNamed(context, '/medical-services'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Second row: My Appointments & My Availability
                  Row(
                    children: [
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: ActionCard(
                            icon: Icons.calendar_today,
                            label: 'My Appointments',
                            onTap: () => Navigator.pushNamed(context, '/medic-appointments'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: ActionCard(
                            icon: Icons.access_time,
                            label: 'My Availability',
                            onTap: () => Navigator.pushNamed(context, '/medic-availability'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: RoundedButton(
              text: 'Log Out',
              onPressed: _handleLogout,
            ),
          ),
        ],
      ),
    );
  }
}