import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:transaksi/providers/auth_provider.dart';
import 'package:transaksi/providers/cart_provider.dart';
import 'package:transaksi/providers/dashboard_provider.dart';
import 'package:transaksi/providers/product_provider.dart';
import 'package:transaksi/providers/transaction_provider.dart';
import 'package:transaksi/providers/user_provider.dart';
import 'package:transaksi/screens/splash_screen.dart';
import 'package:transaksi/screens/auth/login_screen.dart';

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
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'Flutter',
        theme: ThemeData(
          fontFamily: 'Poppins',
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
        routes: {'/login': (context) => const LoginScreen()},
      ),
    );
  }
}
