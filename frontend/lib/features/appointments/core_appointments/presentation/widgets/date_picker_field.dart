import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_text_styles.dart';
import 'package:intl/intl.dart';
import 'package:frontend/core/constants/app_colors.dart';

class DatePickerField extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onTap;

  const DatePickerField({
    Key? key,
    required this.selectedDate,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Select Date',
          labelStyle: AppTextStyles.subtitle,
          filled: true,
          fillColor: AppColors.background,
          border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat.yMMMMd().format(selectedDate),
              style: AppTextStyles.body,
            ),
            const Icon(
              Icons.calendar_month,
              size: 20,
              color: AppColors.primaryBlue,
            ),
          ],
        ),
      ),
    );
  }
}