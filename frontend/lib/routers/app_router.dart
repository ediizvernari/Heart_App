import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/user_controller.dart';
import '../controllers/medical_service_controller.dart';
import '../controllers/free_slot_controller.dart';
import '../controllers/user_appointments_controller.dart';
import '../controllers/medic_appointments_controller.dart';
import '../controllers/user_appointment_suggestion_controller.dart';
import '../controllers/medic_availability_controller.dart';

import 'package:frontend/views/screens/user_main_page.dart';
import 'package:frontend/views/screens/medic_main_page.dart';
import '../views/screens/medical_services_page.dart';
import '../views/screens/user_appointments_page.dart';
import '../views/screens/medic_appointments_page.dart';
import '../views/screens/user_appointment_suggestions_page.dart';
import '../views/screens/medic_availability_page.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/medical-services': (context) => ChangeNotifierProvider<MedicalServiceController>(
        create: (_) {
          final ctl = MedicalServiceController();
          ctl.loadAllMedicalServiceData();
          return ctl;
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
            create: (_) {
              final ctl = UserAppointmentsController();
              ctl.loadMyAppointments();
              return ctl;
            },
          ),
          ChangeNotifierProvider<FreeSlotController>(
            create: (_) => FreeSlotController(),
          ),
          ChangeNotifierProvider<MedicalServiceController>(
            create: (_) {
              final ctl = MedicalServiceController();
              ctl.loadAllMedicalServiceData();
              return ctl;
            },
          ),
        ],
        child: const UserAppointmentsPage(),
      ),

  '/medic-appointments': (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider<MedicAppointmentsController>(
            create: (_) {
              final ctl = MedicAppointmentsController();
              ctl.loadMedicAppointments();
              return ctl;
            },
          ),
          ChangeNotifierProvider<MedicalServiceController>(
            create: (_) {
              final ctl = MedicalServiceController();
              ctl.loadAllMedicalServiceData();
              return ctl;
            },
          ),
        ],
        child: const MedicAppointmentsPage(),
      ),

  '/user-suggestions': (context) => ChangeNotifierProvider<UserAppointmentSuggestionController>(
        create: (_) {
          final ctl = UserAppointmentSuggestionController();
          ctl.loadMySuggestions();
          return ctl;
        },
        child: const UserSuggestionsPage(),
      ),

  '/medic-availability': (context) => ChangeNotifierProvider<MedicAvailabilityController>(
        create: (_) {
          final ctl = MedicAvailabilityController();
          ctl.loadMyAvailabilities();
          return ctl;
        },
        child: const MedicAvailabilityPage(),
      ),

    '/user_home': (ctx) => const UserMainPage(),
    '/medic_home': (ctx) => const MedicMainPage(),
};
