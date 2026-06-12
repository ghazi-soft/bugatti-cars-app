import 'package:flutter/material.dart';
import 'package:bugatti_cars/core/constants.dart';
import 'package:bugatti_cars/presentation/pages/admin/admin_add_edit_car.dart';
import 'package:bugatti_cars/presentation/pages/admin/admin_cars_management.dart';
import 'package:bugatti_cars/presentation/pages/admin/admin_dashboard.dart';
import 'package:bugatti_cars/presentation/pages/admin/admin_messages_management.dart';
import 'package:bugatti_cars/presentation/pages/admin/admin_order_details.dart';
import 'package:bugatti_cars/presentation/pages/admin/admin_orders_management.dart';
import 'package:bugatti_cars/presentation/pages/admin/admin_reports_statistics.dart';
import 'package:bugatti_cars/presentation/pages/admin/admin_users_management.dart';
import 'package:bugatti_cars/presentation/pages/auth/forgot_password_screen.dart';
import 'package:bugatti_cars/presentation/pages/auth/login_screen.dart';
import 'package:bugatti_cars/presentation/pages/auth/onboarding_screen.dart';
import 'package:bugatti_cars/presentation/pages/auth/register_screen.dart';
import 'package:bugatti_cars/presentation/pages/splash_screen.dart';
import 'package:bugatti_cars/presentation/pages/user/car_details_screen.dart';
import 'package:bugatti_cars/presentation/pages/user/cars_list_screen.dart';
import 'package:bugatti_cars/presentation/pages/user/chat_screen.dart';
import 'package:bugatti_cars/presentation/pages/user/contact_us_screen.dart';
import 'package:bugatti_cars/presentation/pages/user/favorites_screen.dart';
import 'package:bugatti_cars/presentation/pages/user/home_screen.dart';
import 'package:bugatti_cars/presentation/pages/user/notifications_screen.dart';
import 'package:bugatti_cars/presentation/pages/user/orders_screen.dart';
import 'package:bugatti_cars/presentation/pages/user/profile_screen.dart';
import 'package:bugatti_cars/presentation/pages/user/search_screen.dart';
import 'package:bugatti_cars/presentation/pages/user/settings_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case AppRoutes.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case AppRoutes.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case AppRoutes.cars:
        return MaterialPageRoute(builder: (_) => const CarsListScreen());
      case AppRoutes.carDetails:
        final args = settings.arguments as int?;
        return MaterialPageRoute(builder: (_) => CarDetailsScreen(carId: args ?? 0));
      case AppRoutes.search:
        return MaterialPageRoute(builder: (_) => const SearchScreen());
      case AppRoutes.favorites:
        return MaterialPageRoute(builder: (_) => const FavoritesScreen());
      case AppRoutes.orders:
        return MaterialPageRoute(builder: (_) => const OrdersScreen());
      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case AppRoutes.notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case AppRoutes.chat:
        final args = settings.arguments as int?;
        return MaterialPageRoute(builder: (_) => ChatScreen(orderId: args));
      case AppRoutes.contactUs:
        return MaterialPageRoute(builder: (_) => const ContactUsScreen());

      // Admin Routes
      case AppRoutes.adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboard());
      case AppRoutes.adminCars:
        return MaterialPageRoute(builder: (_) => const AdminCarsManagement());
      case AppRoutes.adminAddCar:
        return MaterialPageRoute(builder: (_) => const AdminAddEditCarScreen());
      case AppRoutes.adminEditCar:
        final args = settings.arguments as int?;
        return MaterialPageRoute(builder: (_) => AdminAddEditCarScreen(carId: args));
      case AppRoutes.adminOrders:
        return MaterialPageRoute(builder: (_) => const AdminOrdersManagement());
      case AppRoutes.adminOrderDetails:
        final args = settings.arguments as int?;
        return MaterialPageRoute(builder: (_) => AdminOrderDetailsScreen(orderId: args ?? 0));
      case AppRoutes.adminUsers:
        return MaterialPageRoute(builder: (_) => const AdminUsersManagement());
      case AppRoutes.adminMessages:
        return MaterialPageRoute(builder: (_) => const AdminMessagesManagement());
      case AppRoutes.adminReports:
        return MaterialPageRoute(builder: (_) => const AdminReportsStatistics());

      default:
        return MaterialPageRoute(builder: (_) => const Text("Error: Unknown route"));
    }
  }
}
