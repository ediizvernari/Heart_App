import 'package:flutter/material.dart';
import 'package:frontend/features/medics/data/models/assigned_users.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class UserCard extends StatelessWidget {
  final AssignedUser user;
  final Widget? recordCard;
  final VoidCallback onSuggest;

  const UserCard({
    Key? key,
    required this.user,
    this.recordCard,
    required this.onSuggest,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${user.firstName} ${user.lastName}',
              style: AppTextStyles.header,
            ),
            const SizedBox(height: 8),

            if (recordCard != null)
              recordCard!
            else
              const Text(
                'No medical record available.',
                style: AppTextStyles.subheader,
              ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,

                ),
                onPressed: onSuggest,
                child: const Text('Suggest Appointment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
