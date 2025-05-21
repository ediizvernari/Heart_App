import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/features/auth/presentation/screens/splash_redirect_screen.dart';
import 'package:provider/provider.dart';

import 'package:frontend/controllers/free_slot_controller.dart';
import 'package:frontend/controllers/medic_appointment_suggestion_controller.dart';
import 'package:frontend/controllers/medical_service_controller.dart';
import 'package:frontend/controllers/user_appointments_controller.dart';
import 'package:frontend/features/auth/data/auth_repository_impl.dart';
import 'package:frontend/features/auth/presentation/controllers/auth_controller.dart';
import 'package:frontend/utils/auth_store.dart';
import 'package:frontend/services/user_service.dart';
import 'package:frontend/routers/app_router.dart';

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
        Provider<UserService>(create: (_) => UserService()),
        ChangeNotifierProxyProvider<AuthStore, MedicalServiceController>(
          create: (_) => MedicalServiceController(),
          update: (_, authStore, controller) {
            controller!.authStore = authStore;
            return controller;
          },
        ),
        ChangeNotifierProvider<AuthController>(
          create: (_) => AuthController(AuthRepositoryImpl()),
        ),
        ChangeNotifierProvider(create: (_) => FreeSlotController()),
        ChangeNotifierProvider(create: (_) => UserAppointmentsController()),
        ChangeNotifierProvider(create: (_) => MedicAppointmentSuggestionController()),
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
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
