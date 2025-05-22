import 'package:flutter/material.dart';
import 'package:frontend/features/appointments/appointments_suggestions/data/repositories/appointment_suggestion_repository_impl.dart';
import 'package:frontend/features/appointments/core_appointments/data/repositories/appointments_repository_impl.dart';
import 'package:frontend/features/appointments/medic_availabilities/data/repositories/medic_availability_repository_impl.dart';
import 'package:frontend/features/appointments/scheduling/data/repositories/schedule_repository_impl.dart';
import 'package:frontend/features/medical_service/data/repositories/medical_service_repository_impl.dart';
import 'package:provider/provider.dart';

import '../controllers/user_controller.dart';
import '../features/medical_service/presentation/controllers/medical_service_controller.dart';
import '../features/appointments/scheduling/presentation/medic_schedule_controller.dart';
import '../features/appointments/core_appointments/presentation/controllers/user_appointments_controller.dart';
import '../features/appointments/core_appointments/presentation/controllers/medic_appointments_controller.dart';
import '../features/appointments/appointments_suggestions/presentation/controllers/user_appointment_suggestion_controller.dart';
import '../features/appointments/medic_availabilities/presentation/controllers/medic_availability_controller.dart';

import 'package:frontend/views/screens/user_main_page.dart';
import 'package:frontend/views/screens/medic_main_page.dart';
import '../features/medical_service/presentation/pages/medical_services_page.dart';
import '../features/appointments/core_appointments/presentation/screens/user_appointments_page.dart';
import '../features/appointments/core_appointments/presentation/screens/medic_appointments_page.dart';
import '../features/appointments/appointments_suggestions/presentation/screens/user_appointment_suggestions_page.dart';
import '../features/appointments/medic_availabilities/presentation/screens/medic_availability_page.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/medical-services': (context) => ChangeNotifierProvider<MedicalServiceController>(
        create: (_) {
          final medicalServiceController = MedicalServiceController(MedicalServiceRepositoryImpl());
          medicalServiceController.getAllMedicalServiceData();
          return medicalServiceController;
        },
        child: const MedicalServicesPage(),
      ),

  '/user-appointments': (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider<UserController>(
            create: (_) {
              final ctl = UserController();
              ctl.checkHasMedic();
              ctl.fetchAssignedMedic();
              return ctl;
            },
          ),
          ChangeNotifierProvider<UserAppointmentsController>(
            create: (_) => UserAppointmentsController(AppointmentsRepositoryImpl()),
            child: const UserAppointmentsPage(),
          ),
          ChangeNotifierProvider<MedicScheduleController>(
            create: (_) => MedicScheduleController(ScheduleRepositoryImpl()),
          ),
          ChangeNotifierProvider<MedicalServiceController>(
            create: (_) {
              final medicalServiceController = MedicalServiceController(MedicalServiceRepositoryImpl());
              medicalServiceController.getAllMedicalServiceData();
              return medicalServiceController;
            },
          ),
        ],
        child: const UserAppointmentsPage(),
      ),

  '/medic-appointments': (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider<MedicAppointmentsController>(
            create: (_) {
              final ctl = MedicAppointmentsController(AppointmentsRepositoryImpl());
              ctl.getMedicAppointments();
              return ctl;
            },
          ),
          ChangeNotifierProvider<MedicalServiceController>(
            create: (_) {
              final medicalServiceController = MedicalServiceController(MedicalServiceRepositoryImpl());
              medicalServiceController.getAllMedicalServiceData();
              return medicalServiceController;
            },
          ),
        ],
        child: const MedicAppointmentsPage(),
      ),

  '/user-suggestions': (ctx) => MultiProvider(
      providers: [
        ChangeNotifierProvider<MedicalServiceController>(
          create: (_) {
            final repo = MedicalServiceRepositoryImpl();
            final ctl  = MedicalServiceController(repo);
            ctl.getAllMedicalServiceData();
            return ctl;
          },
        ),
        ChangeNotifierProvider<UserAppointmentSuggestionController>(
          create: (_) {
            final ctl = UserAppointmentSuggestionController(
              AppointmentSuggestionRepositoryImpl()
            )..getMyAppointmentSuggestions();
            return ctl;
          },
        ),
      ],
      child: const UserSuggestionsPage(),
    ),
  '/medic-availability': (context) => ChangeNotifierProvider<MedicAvailabilityController>(
        create: (_) {
          final ctl = MedicAvailabilityController(MedicAvailabilityRepositoryImpl());
          ctl.getMyAvailabilities();
          return ctl;
        },
        child: const MedicAvailabilityPage(),
      ),

    '/user_home': (ctx) => const UserMainPage(),
    '/medic_home': (ctx) => const MedicMainPage(),
};
