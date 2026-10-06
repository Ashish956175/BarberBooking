import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/shop_provider.dart';
import 'providers/appointment_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/my_bookings_screen.dart';
import 'screens/barber_dashboard_screen.dart';
import 'screens/barber_shop_screen.dart';
import 'screens/barber_services_screen.dart';
import 'screens/profile_edit_screen.dart';
import 'utils/constants.dart';
import 'screens/customer_home_screen.dart';
import 'screens/customer_main_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/shop_detail_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/support_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ShopProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
      ],
      child: MaterialApp(
        title: 'Barber Booking App',
        debugShowCheckedModeBanner: false, // Remove debug banner
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppColors.background,
          primaryColor: AppColors.primary,
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            secondary: AppColors.secondary,
            surface: AppColors.surface,
            background: AppColors.background,
            onPrimary: AppColors.onPrimary,
            onSurface: AppColors.onSurface,
          ),
          textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
            displayLarge: GoogleFonts.playfairDisplay(color: AppColors.primary, fontWeight: FontWeight.bold),
            displayMedium: GoogleFonts.playfairDisplay(color: AppColors.onBackground, fontWeight: FontWeight.bold),
            headlineLarge: GoogleFonts.playfairDisplay(color: AppColors.onBackground, fontWeight: FontWeight.bold),
            // Body text remains Outfit from the base outfitTextTheme
          ).apply(
             bodyColor: AppColors.onBackground,
             displayColor: AppColors.onBackground,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent, // Glass effect requires transparent/translucent
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(color: AppColors.primary, fontSize: 22, fontFamily: 'Playfair Display', fontWeight: FontWeight.bold),
            iconTheme: IconThemeData(color: AppColors.primary),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData( // Default to Liquid Gold style where possible
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black, // Royal contrast
              textStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(vertical: 18),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            labelStyle: const TextStyle(color: AppColors.secondary),
          ),
        ),
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const CustomerMainScreen(),
          '/barber-dashboard': (context) => const BarberDashboardScreen(),
          '/my-bookings': (context) => const MyBookingsScreen(),
          '/barber-shop': (context) => const BarberShopScreen(),
          '/profile-edit': (context) => const ProfileEditScreen(),
          '/admin-dashboard': (context) => const AdminDashboardScreen(),
          '/notifications': (context) => const NotificationsScreen(),
        '/support': (context) => const SupportScreen(),
      },
      ),
    );
  }
}
