import 'package:flutter/material.dart';
import 'package:transaksi/config/app_style.dart';
import 'package:transaksi/data/models/dashboard_model.dart';
import 'package:transaksi/screens/dashboard/widgets/monthly_chart.dart';
import 'package:transaksi/screens/dashboard/widgets/status_bar_chart.dart';

class AnalyticsScreen extends StatelessWidget {
  final DashboardData data;
  final bool isAdmin;

  const AnalyticsScreen({super.key, required this.data, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: kBackgroundColor,
        elevation: 0,
        foregroundColor: kPrimaryTextColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        // Gunakan Widget yang sesuai berdasarkan role
        child: isAdmin ? _buildAdminAnalytics(data) : _buildUserAnalytics(data),
      ),
    );
  }

  // Konten Analytics khusus untuk Admin
  Widget _buildAdminAnalytics(DashboardData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Monthly Revenue',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: MonthlyChart(
            monthlyData: data.monthlyData,
            title: 'Monthly Revenue',
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Transactions by Status',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: StatusBarChart(statusData: data.transactionsByStatus),
        ),
      ],
    );
  }

  // Konten Analytics khusus untuk User
  Widget _buildUserAnalytics(DashboardData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My Monthly Spending',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: MonthlyChart(
            monthlyData: data.monthlyData,
            title: 'Spending Analysis',
          ),
        ),
      ],
    );
  }
}
