import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:zenith_coffee_shop/providers/extra_services_provider.dart';
import 'package:zenith_coffee_shop/providers/profiles_provider.dart';
import 'package:zenith_coffee_shop/providers/reservation_provider.dart';
import 'package:zenith_coffee_shop/providers/room_provider.dart';
import 'package:zenith_coffee_shop/providers/room_services_provider.dart';
import 'package:zenith_coffee_shop/providers/room_type_class_provider.dart';
import 'package:zenith_coffee_shop/screens/add_room_extra_services.dart';
import 'package:zenith_coffee_shop/screens/add_room_form.dart';
import 'package:zenith_coffee_shop/screens/add_room_services.dart';
import 'package:zenith_coffee_shop/screens/add_type_room_form.dart';
import 'package:zenith_coffee_shop/screens/extra_service_list_screen.dart';
import 'package:zenith_coffee_shop/screens/forgot_password_screen.dart';
import 'package:zenith_coffee_shop/screens/home_screen.dart';
import 'package:zenith_coffee_shop/screens/order_room_form.dart';
import 'package:zenith_coffee_shop/screens/payment_done.dart';
import 'package:zenith_coffee_shop/screens/payment_pending_screen.dart';
import 'package:zenith_coffee_shop/screens/room_detail_screen.dart';
import 'package:zenith_coffee_shop/screens/room_type_list_screen.dart';
import 'package:zenith_coffee_shop/screens/service_list_screen.dart';
import 'package:zenith_coffee_shop/screens/update_room_form.dart';
import 'package:zenith_coffee_shop/screens/user_order_history.dart';
import 'package:zenith_coffee_shop/themes/app_color.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/room_selection_screen.dart';
import 'screens/order_confirmation_page.dart';
import 'screens/profile_page.dart';
import 'screens/order_history.dart';

void main() async { 
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RoomProvider()),
        ChangeNotifierProvider(create: (_) => ExtraServicesProvider()),
        ChangeNotifierProvider(create: (_) => ProfilesProvider()),
        ChangeNotifierProvider(create: (_) => RoomTypeClassProvider()),
        ChangeNotifierProvider(create: (_) => RoomServicesProvider()),
        ChangeNotifierProvider(create: (_) => ReservationProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            theme: ThemeData(
              colorScheme: ColorScheme.light(primary: AppColors.secondary),
              datePickerTheme: DatePickerThemeData(
                backgroundColor: Colors.white,
                dividerColor: AppColors.secondary,
                headerBackgroundColor: AppColors.secondary,
                shadowColor: AppColors.secondary,
                dayStyle: TextStyle(color: AppColors.secondary),
                headerForegroundColor: Colors.white,
              ),
              bottomNavigationBarTheme: BottomNavigationBarThemeData(
                backgroundColor: AppColors.gray,

                // Set the default background color
                selectedItemColor: AppColors.secondary,
                unselectedItemColor: Colors.white,
              ),
              checkboxTheme: CheckboxThemeData(
                fillColor: WidgetStateProperty.resolveWith<Color?>(
                    (Set<WidgetState> states) {
                  if (states.contains(WidgetState.disabled)) {
                    return null;
                  }
                  if (states.contains(WidgetState.selected)) {
                    return AppColors.secondary;
                  }
                  return null;
                }),
              ),
              radioTheme: RadioThemeData(
                fillColor: WidgetStateProperty.resolveWith<Color?>(
                    (Set<WidgetState> states) {
                  if (states.contains(WidgetState.disabled)) {
                    return null;
                  }
                  if (states.contains(WidgetState.selected)) {
                    return AppColors.secondary;
                  }
                  return null;
                }),
              ),
              switchTheme: SwitchThemeData(
                thumbColor: WidgetStateProperty.resolveWith<Color?>(
                    (Set<WidgetState> states) {
                  if (states.contains(WidgetState.disabled)) {
                    return null;
                  }
                  if (states.contains(WidgetState.selected)) {
                    return AppColors.secondary;
                  }
                  return null;
                }),
                trackColor: WidgetStateProperty.resolveWith<Color?>(
                    (Set<WidgetState> states) {
                  if (states.contains(WidgetState.disabled)) {
                    return null;
                  }
                  if (states.contains(WidgetState.selected)) {
                    return AppColors.secondary;
                  }
                  return null;
                }),
              ),
            ),
            home: StreamBuilder<firebase_auth.User?>(
              stream: authProvider.authStateChanges,
              builder: (BuildContext context,
                  AsyncSnapshot<firebase_auth.User?> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasData) {
                  return const HomeScreen();
                } else {
                  return const LoginPage();
                }
              },
            ),
            routes: {
              '/sign_in': (context) => const LoginPage(),
              '/sign_up': (context) => const SignUpScreen(),
              '/forgot_password': (context) =>  ForgotPasswordScreen(),
              '/room_selection': (context) => const RoomSelectionPage(),
              '/detail_room': (context) => const RoomDetailScreen(),
              '/order_room_form': (context) => const OrderRoomForm(),
              '/add_room_form': (context) => const AddRoomForm(),
              '/update_room_form': (context) => const UpdateRoomForm(),
              '/add_room_service': (context) => const AddRoomServices(),
              '/add_room_extra_service': (context) =>
                  const AddRoomExtraServices(),
              '/add_type_room': (context) => const AddTypeRoomForm(),
              '/service_list': (context) => const ServiceListScreen(),
              '/extra_service_list': (context) =>
                  const ExtraServiceListScreen(),
              '/room_type_list': (context) => const RoomTypeListScreen(),
              '/order_confirmation': (context) => OrderConfirmationPage(),
              '/profile': (context) => const ProfilePage(),
              '/order_history': (context) => const OrderHistoryPage(),
              '/user_order_history': (context) => const UserOrderHistoryPage(),
              '/payment_done': (context) => const PaymentDone(),
              '/payment_pending': (context) => PaymentPendingScreen(
                    orderId:
                        ModalRoute.of(context)?.settings.arguments as String? ??
                            '',
                  ),
            },
          );
        },
      ),
    );
  }
}
