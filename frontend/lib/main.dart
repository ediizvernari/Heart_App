import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/features/auth/presentation/screens/splash_redirect_screen.dart';
import 'package:provider/provider.dart';

import 'package:frontend/utils/auth_store.dart';
import 'package:frontend/routers/app_router.dart';
import 'package:frontend/features/users/presentation/controllers/user_controller.dart';
import 'package:frontend/features/user_health_data/presentation/controllers/user_health_data_controller.dart';
import 'package:frontend/features/medical_service/presentation/controllers/medical_service_controller.dart';
import 'package:frontend/features/auth/presentation/controllers/auth_controller.dart';
import 'package:frontend/features/appointments/scheduling/presentation/medic_schedule_controller.dart';
import 'package:frontend/features/location/presentation/controller/location_controller.dart';
import 'package:frontend/features/appointments/appointments_suggestions/presentation/controllers/medic_appointment_suggestion_controller.dart';
import 'package:frontend/features/cvd_prediction/presentation/controllers/cvd_prediction_controller.dart';

import 'package:frontend/features/users/data/repositories/user_repository_impl.dart';
import 'package:frontend/features/user_health_data/data/repositories/user_health_data_repository_impl.dart';
import 'package:frontend/features/medical_service/data/repositories/medical_service_repository_impl.dart';
import 'package:frontend/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:frontend/features/appointments/scheduling/data/repositories/schedule_repository_impl.dart';
import 'package:frontend/features/location/data/repositories/location_repository_impl.dart';
import 'package:frontend/features/appointments/appointments_suggestions/data/repositories/appointment_suggestion_repository_impl.dart';
import 'package:frontend/features/cvd_prediction/data/repositories/cvd_prediction_repository_impl.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = 
        (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(
    MultiProvider(
      providers: [

        Provider<AuthStore>(create: (_) => AuthStore()),
        ChangeNotifierProvider<UserController>(
          create: (_) {
            final ctl = UserController(UserRepositoryImpl());
            ctl.checkUserHasMedic();
            ctl.getMyAssignmentStatus();
            ctl.getMyAssignedMedic();
            return ctl;
          },
        ),

        ChangeNotifierProvider<UserHealthDataController>(
          create: (_) => UserHealthDataController(UserHealthDataRepositoryImpl()),
        ),
        ChangeNotifierProvider<MedicalServiceController>(
          create: (_) => MedicalServiceController(MedicalServiceRepositoryImpl()),
        ),
        ChangeNotifierProvider<AuthController>(
          create: (_) => AuthController(AuthRepositoryImpl()),
        ),
        ChangeNotifierProvider<MedicScheduleController>(
          create: (_) => MedicScheduleController(ScheduleRepositoryImpl()),
        ),
        ChangeNotifierProvider<LocationController>(
          create: (_) => LocationController(LocationRepositoryImpl()),
        ),
        ChangeNotifierProvider<MedicAppointmentSuggestionController>(
          create: (_) => MedicAppointmentSuggestionController(
            AppointmentSuggestionRepositoryImpl(),
          ),
        ),
        ChangeNotifierProvider<CvdPredictionController>(
          create: (_) => CvdPredictionController(
            UserHealthDataRepositoryImpl(),
            CvdPredictionRepositoryImpl(),
          ),
        ),

      ],
      child: const HealthApp(),
    ),
  );
}

class HealthApp extends StatelessWidget {
  const HealthApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryRed),
        useMaterial3: true,
      ),
      builder: (context, child) => Directionality(
        textDirection: TextDirection.ltr,
        child: child!,
      ),
      routes: appRoutes,
      home: const AutoCheck(),
    );
  }
}
