import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/appointments/appointments_suggestions/data/repositories/appointment_suggestion_repository_impl.dart';
import '../features/appointments/core_appointments/data/repositories/appointments_repository_impl.dart';
import '../features/appointments/medic_availabilities/data/repositories/medic_availability_repository_impl.dart';
import '../features/appointments/scheduling/data/repositories/schedule_repository_impl.dart';
import '../features/auth/presentation/screens/home_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/signup_medic_screen.dart';
import '../features/auth/presentation/screens/signup_user_screen.dart';
import '../features/cvd_prediction/data/repositories/cvd_prediction_repository_impl.dart';
import '../features/cvd_prediction/presentation/controllers/cvd_prediction_controller.dart';
import '../features/cvd_prediction/presentation/pages/client_cvd_prediction_results_page.dart';
import '../features/medical_services/data/repositories/medical_service_repository_impl.dart';
import '../features/medics/data/repositories/medic_repository_impl.dart';
import '../features/medics/presentation/controllers/medic_filtering_controller.dart';
import '../features/medics/presentation/pages/medic_patients_page.dart';
import '../features/user_health_data/data/repositories/user_health_data_repository_impl.dart';
import '../features/user_health_data/presentation/pages/user_health_data_insertion_page.dart';
import '../features/user_medical_records/data/repositories/user_medical_record_impl.dart';
import '../features/user_medical_records/presentation/controllers/user_medical_record_controller.dart';
import '../features/user_medical_records/presentation/pages/user_medical_records_page.dart';
import '../features/users/data/repositories/user_repository_impl.dart';
import '../features/location/presentation/pages/find_medic_page.dart';
import '../features/users/presentation/pages/medic_interactions_page.dart';


import '../features/users/presentation/controllers/user_controller.dart';
import '../features/medical_services/presentation/controllers/medical_service_controller.dart';

import '../features/appointments/scheduling/presentation/medic_schedule_controller.dart';
import '../features/appointments/core_appointments/presentation/controllers/user_appointments_controller.dart';
import '../features/appointments/core_appointments/presentation/controllers/medic_appointments_controller.dart';
import '../features/appointments/appointments_suggestions/presentation/controllers/user_appointment_suggestion_controller.dart';
import '../features/appointments/medic_availabilities/presentation/controllers/medic_availability_controller.dart';

import '../features/users/presentation/pages/user_main_page.dart';
import '../features/medics/presentation/pages/medic_main_page.dart';
import '../features/medical_services/presentation/pages/medical_services_page.dart';
import '../features/appointments/core_appointments/presentation/screens/user_appointments_page.dart';
import '../features/appointments/core_appointments/presentation/screens/medic_appointments_page.dart';
import '../features/appointments/appointments_suggestions/presentation/screens/user_appointment_suggestions_page.dart';
import '../features/appointments/medic_availabilities/presentation/screens/medic_availability_page.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/home': (ctx) => const HomeScreen(),

  '/user_home': (context) => const UserMainPage(),
  
  '/medic_home': (context) => const MedicMainPage(),

  '/signup_user': (context) => const SignupUserScreen(),

  '/signup_medic': (context) => const SignupMedicScreen(),

  '/login': (context) => const LoginScreen(),

  '/medic-interactions': (context) => const MedicInteractionsPage(),
  
  '/user-health-data-insertion': (context) => const UserHealthDataPage(),

  '/medic-patients': (context) => const MedicPatientsPage(),

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
            create: (_) =>
              UserController(UserRepositoryImpl())
                ..checkUserHasMedic()
                ..getMyAssignmentStatus()
                ..getMyAssignedMedic(),
            child: const UserMainPage(),
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

  '/user-suggestions': (context) => MultiProvider(
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
      child: const UserAppointmentSuggestionsPage(),
    ),

  '/medic-availability': (context) => ChangeNotifierProvider<MedicAvailabilityController>(
        create: (_) {
          final ctl = MedicAvailabilityController(MedicAvailabilityRepositoryImpl());
          ctl.getMyAvailabilities();
          return ctl;
        },
        child: const MedicAvailabilityPage(),
      ),
    
    '/find-medic': (context) => MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MedicFilteringController(MedicRepositoryImpl()),
        ),
      ],
      child: const FindMedicPage(),
      ),

    '/prediction': (context) => ChangeNotifierProvider<CvdPredictionController>(
        create: (_) {
          final ctrl  = CvdPredictionController(UserHealthDataRepositoryImpl(), CvdPredictionRepositoryImpl());
          ctrl.predictCvdProbability();  
          return ctrl;
        },
        child: const CvdPredictionResultsPage(),
      ),

      '/user_records': (_) => ChangeNotifierProvider(
        create: (_) => UserMedicalRecordController(UserMedicalRecordRepositoryImpl()),
        child: const UserMedicalRecordsPage(),
      ),
};
