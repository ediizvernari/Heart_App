import 'package:flutter/material.dart';
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
          labelStyle: const TextStyle(color: Colors.black87),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 51), // 20% white
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(
              color: Colors.black54,
              width: 1.5,
            ),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat.yMMMMd().format(selectedDate),
              style: const TextStyle(color: Colors.black87),
            ),
            const Icon(
              Icons.calendar_today,
              size: 20,
              color: AppColors.primaryRed,
            ),
          ],
        ),
      ),
    );
  }
}