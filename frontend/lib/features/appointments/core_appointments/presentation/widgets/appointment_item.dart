import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/models/appointment_model.dart';
import '../../../../../controllers/medical_service_controller.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';

typedef StatusCallback = void Function(String newStatus);

class AppointmentItem extends StatelessWidget {
  final Appointment appointment;
  final StatusCallback? onUpdateStatus;

  const AppointmentItem({
    required this.appointment,
    this.onUpdateStatus,
    Key? key,
  }) : super(key: key);

  String get _formattedDate {
    final dt = appointment.appointmentStart;
    return DateFormat.yMMMd().add_jm().format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final isMedicView = onUpdateStatus != null;
    final bodyStyle = AppTextStyles.welcomeHeader.copyWith(fontSize: 16);
    final captionStyle = AppTextStyles.buttonText.copyWith(fontSize: 12);

    final services = context.read<MedicalServiceController>().services;
    final matching = services.where((s) => s.id == appointment.medicalServiceId).toList();
    final serviceName = matching.isNotEmpty ? matching.first.name : 'Unknown';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formattedDate, style: bodyStyle),
                Chip(
                  backgroundColor: AppColors.primaryRed.withAlpha(30),
                  label: Text(
                    appointment.appointmentStatus.toUpperCase(),
                    style: captionStyle.copyWith(color: AppColors.primaryRed),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Service: $serviceName', style: bodyStyle),
            const SizedBox(height: 4),
            Text('Address: ${appointment.address}', style: captionStyle),
            const SizedBox(height: 12),
            if (isMedicView)
              const Divider(),
            if (isMedicView)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _StatusButton(label: 'Confirm', onPressed: () => onUpdateStatus!('confirmed')),
                  const SizedBox(width: 8),
                  _StatusButton(label: 'Complete', onPressed: () => onUpdateStatus!('completed')),
                  const SizedBox(width: 8),
                  _StatusButton(label: 'Cancel', onPressed: () => onUpdateStatus!('cancelled')),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _StatusButton({
    required this.label,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: AppColors.primaryRed.withAlpha(30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: AppTextStyles.buttonText.copyWith(color: AppColors.primaryRed),
      ),
    );
  }
}
