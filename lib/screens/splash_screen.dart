import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:transaksi/providers/auth_provider.dart';
import 'package:transaksi/screens/auth/login_screen.dart';
import 'package:transaksi/screens/main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigasi setelah frame pertama selesai di-build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  void _checkAuth() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // Navigasi berdasarkan status otentikasi
    if (authProvider.isAuthenticated) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const MainScreen()));
    } else {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tampilan sederhana selama pengecekan
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
