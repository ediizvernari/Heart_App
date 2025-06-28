import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/appointment_model.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';

typedef StatusCallback = void Function(String newStatus);

class AppointmentItem extends StatelessWidget {
  final Appointment appointment;
  final StatusCallback? onUpdateStatus;
  final bool isMedicView;

  const AppointmentItem({
    required this.appointment,
    this.onUpdateStatus,
    required this.isMedicView,
    Key? key,
  }) : super(key: key);

  String get _appointmentCreationDate {
    final created = appointment.createdAt;
    return DateFormat.yMMMd().add_jm().format(created);
  }

  @override
  Widget build(BuildContext context) {
    final status = appointment.appointmentStatus;
    final medicalServiceName = appointment.medicalServiceName;

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
                Chip(
                  backgroundColor: AppColors.primaryBlue.withAlpha(30),
                  label: Text(
                    status.toUpperCase(),
                    style: AppTextStyles.chipLabel,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Text('Created: $_appointmentCreationDate', style: AppTextStyles.caption),
            const SizedBox(height: 12),

            Text(
              'Pacient: ${appointment.patient.firstName} ${appointment.patient.lastName}',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 4),
            Text(
              'Medic: Dr. ${appointment.medic.firstName} ${appointment.medic.lastName}',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 12),

            Text('Country: ${appointment.medic.country}', style: AppTextStyles.body),
            const SizedBox(height: 2),
            Text('City: ${appointment.medic.city}', style: AppTextStyles.body),
            const SizedBox(height: 8),
            Text('Address: ${appointment.address}', style: AppTextStyles.body),
            const SizedBox(height: 12),
            Text('Medical Service: $medicalServiceName', style: AppTextStyles.body),
            const SizedBox(height: 4),
            Text('Price: ${appointment.medicalServicePrice} RON', style: AppTextStyles.body),
            const SizedBox(height: 8),

            if (isMedicView) ...[
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _StatusButton(
                    label: 'Confirm',
                    onPressed: () => onUpdateStatus?.call('confirmed'),
                  ),
                  const SizedBox(width: 8),
                  _StatusButton(
                    label: 'Complete',
                    onPressed: () => onUpdateStatus?.call('completed'),
                  ),
                  const SizedBox(width: 8),
                  _StatusButton(
                    label: 'Cancel',
                    onPressed: () => onUpdateStatus?.call('cancelled'),
                  ),
                ],
              ),
            ] else if (onUpdateStatus != null && (status == 'pending' || status == 'confirmed')) ...[
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _StatusButton(
                    label: 'Cancel',
                    onPressed: () => onUpdateStatus!.call('cancelled'),
                  ),
                ],
              ),
            ],
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
        backgroundColor: AppColors.primaryBlue.withAlpha(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      onPressed: onPressed,
      child: Text(label, style: AppTextStyles.chipLabel),
    );
  }
}