import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../utils/validators/session_validator.dart';
import '../../../user_health_data/presentation/pages/client_personal_data_insertion_page.dart';
import '../../../auth/presentation/screens/home_screen.dart';
import 'package:frontend/handlers/client_cvd_prediction_button_handler.dart';
import 'package:frontend/handlers/available_medics_button_handler.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

//TODO: Change this to include a controller for better state management
class UserMainPage extends StatefulWidget {
  const UserMainPage({Key? key}) : super(key: key);

  @override
  State<UserMainPage> createState() => _UserMainPageState();
}

class _UserMainPageState extends State<UserMainPage> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? _token;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await SessionValidator.verifyToken(context);
      final storedToken = await _storage.read(key: 'auth_token');
      setState(() => _token = storedToken);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;
    final crossAxisCount = isWide ? 3 : 2;

    final menu = [
      {
        'icon': Icons.calendar_today,
        'label': 'Appointments',
        'onTap': (BuildContext ctx) => Navigator.pushNamed(ctx, '/user-appointments'),
      },
      {
        'icon': Icons.event_note,
        'label': 'Suggestions',
        'onTap': (BuildContext ctx) => Navigator.pushNamed(ctx, '/user-suggestions'),
      },
      {
        'icon': Icons.health_and_safety,
        'label': 'Predict Risk of CVD',
        'onTap': (BuildContext ctx) {
          if (_token == null) return;
          handleCvdPredictionButtonTap(ctx);
        },
      },
      {
        'icon': Icons.insert_chart,
        'label': 'Data Insertion',
        'onTap': (BuildContext ctx) => Navigator.push(
          ctx,
          MaterialPageRoute(builder: (_) => const ClientPersonalDataInsertionPage()),
        ),
      },
      {
        'icon': Icons.medical_services,
        'label': 'Find a Medic',
        'onTap': (BuildContext ctx) => AvailableMedicsButtonHandler.navigateToFindMedicPage(ctx),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Welcome, Client',
          style: AppTextStyles.welcomeHeader,
        ),
        backgroundColor: AppColors.primaryRed,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: menu.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.1,
          ),
          itemBuilder: (ctx, i) {
            final item = menu[i];
            return GestureDetector(
              onTap: () => (item['onTap'] as void Function(BuildContext))(ctx),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                color: AppColors.cardBackground,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      size: 48,
                      color: AppColors.iconColor,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item['label'] as String,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.buttonText,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              foregroundColor: AppColors.cardBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => _handleLogout(context),
            child: const Text(
              'Logout',
              style: AppTextStyles.buttonText,
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout', style: AppTextStyles.dialogTitle),
        content: const Text('Are you sure you want to logout?', style: AppTextStyles.dialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: AppTextStyles.dialogButton),
          ),
          TextButton(
            onPressed: () async {
              await _storage.delete(key: 'auth_token');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            },
            child: const Text('Logout', style: AppTextStyles.dialogButton),
          ),
        ],
      ),
    );
  }
}
