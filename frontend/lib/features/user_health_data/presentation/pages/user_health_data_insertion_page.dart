import 'package:flutter/material.dart';
import 'package:frontend/features/user_health_data/presentation/widgets/user_health_data_form.dart';
import 'package:frontend/widgets/custom_app_bar.dart';
import 'package:frontend/core/constants/app_colors.dart';

class UserHealthDataPage extends StatelessWidget {
  const UserHealthDataPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: const SafeArea(
          child: Column(
            children: [
              CustomAppBar(title: 'Enter Health Data'),
              SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Center(
                    child: FractionallySizedBox(
                      widthFactor: 0.9,
                      child: UserHealthDataForm(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}