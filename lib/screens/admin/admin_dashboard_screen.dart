import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:transaksi/data/models/dashboard_model.dart';
import 'package:transaksi/providers/auth_provider.dart';
import 'package:transaksi/providers/dashboard_provider.dart';
import 'package:transaksi/screens/dashboard/analytics_screen.dart';
import 'package:transaksi/screens/dashboard/widgets/gradient_stat_card.dart';
import 'package:transaksi/screens/dashboard/widgets/minimal_stat_card.dart';
import 'package:transaksi/screens/dashboard/widgets/recent_transaction_list.dart';

class AdminDashboardScreen extends StatelessWidget {
  final DashboardData data;
  const AdminDashboardScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bool isDesktop = MediaQuery.of(context).size.width >= 1024;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: () async {
          await Provider.of<DashboardProvider>(
            context,
            listen: false,
          ).fetchDashboardData(authProvider.token!, authProvider.user!.role);
        },
        child: CustomScrollView(
          slivers: [
            // Modern App Bar Section
            SliverAppBar(
              expandedHeight: 180,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsets.only(
                  left: isDesktop ? 40 : 20,
                  bottom: 16,
                ),
                title: Text(
                  'Dashboard Overview',
                  style: TextStyle(
                    fontSize: isDesktop ? 28 : 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.blue[700]!, Colors.blue[500]!],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Opacity(
                      opacity: 0.1,
                      child: Icon(
                        Icons.dashboard_rounded,
                        size: 180,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.bar_chart_rounded,
                    color: Colors.white,
                    size: isDesktop ? 28 : 24,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AnalyticsScreen(data: data, isAdmin: true),
                      ),
                    );
                  },
                  tooltip: 'View Analytics',
                ),
                Padding(
                  padding: EdgeInsets.only(right: isDesktop ? 40 : 20),
                  child: CircleAvatar(
                    radius: isDesktop ? 20 : 16,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: isDesktop ? 20 : 16,
                    ),
                  ),
                ),
              ],
              backgroundColor: Colors.blue[700],
            ),

            // Welcome & Summary Cards Section
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 40 : 20,
                vertical: 20,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildWelcomeHeader(
                    context,
                    authProvider.user?.name ?? 'Admin',
                    isDesktop,
                  ),
                  const SizedBox(height: 24),
                  _buildSummarySection(
                    context,
                    data,
                    currencyFormatter,
                    isDesktop,
                  ),
                ]),
              ),
            ),

            // Top Products Section
            SliverPadding(
              padding: EdgeInsets.only(
                top: 16,
                left: isDesktop ? 40 : 20,
                right: isDesktop ? 40 : 20,
              ),
              sliver: SliverToBoxAdapter(
                child: _buildSectionHeader(
                  context,
                  'Top Selling Products',
                  Icons.star_rounded,
                  isDesktop,
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 40 : 20),
              sliver: SliverToBoxAdapter(
                child: _buildTopProductsList(context, data, currencyFormatter),
              ),
            ),

            // Recent Transactions Section
            SliverPadding(
              padding: EdgeInsets.only(
                top: 24,
                left: isDesktop ? 40 : 20,
                right: isDesktop ? 40 : 20,
              ),
              sliver: SliverToBoxAdapter(
                child: _buildSectionHeader(
                  context,
                  'Recent Transactions',
                  Icons.receipt_long_rounded,
                  isDesktop,
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.only(
                bottom: 40,
                left: isDesktop ? 40 : 20,
                right: isDesktop ? 40 : 20,
              ),
              sliver: SliverToBoxAdapter(
                child: RecentTransactionList(
                  transactions: data.recentTransactions,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(
    BuildContext context,
    String userName,
    bool isDesktop,
  ) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.blue.withOpacity(0.1), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.waving_hand_rounded,
              color: Colors.blue[700],
              size: isDesktop ? 32 : 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, $userName!',
                  style: TextStyle(
                    fontSize: isDesktop ? 22 : 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Here\'s what\'s happening with your store today',
                  style: TextStyle(
                    fontSize: isDesktop ? 16 : 14,
                    color: theme.colorScheme.onBackground.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
    bool isDesktop,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[600]!, Colors.blue[400]!],
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: isDesktop ? 24 : 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: isDesktop ? 20 : 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onBackground,
          ),
        ),
      ],
    );
  }

  Widget _buildSummarySection(
    BuildContext context,
    DashboardData? data,
    NumberFormat formatter,
    bool isDesktop,
  ) {
    if (data == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = isDesktop
                ? (constraints.maxWidth - 20) / 2
                : constraints.maxWidth;

            return Wrap(
              spacing: 20,
              runSpacing: 20,
              children: [
                SizedBox(
                  width: cardWidth,
                  child: GradientStatCard(
                    title: 'Total Revenue',
                    value: formatter.format(data.summary.totalRevenue),
                    icon: Icons.monetization_on_rounded,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.blue[700]!, Colors.blue[400]!],
                    ),
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: GradientStatCard(
                    title: 'Total Transactions',
                    value: data.summary.totalTransactions.toString(),
                    icon: Icons.swap_horiz_rounded,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.indigo[600]!, Colors.blue[400]!],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        GridView.count(
          crossAxisCount: isDesktop
              ? 3
              : (MediaQuery.of(context).size.width < 380 ? 1 : 2),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: (MediaQuery.of(context).size.width < 380)
              ? 2.8
              : (isDesktop ? 2.2 : 1.8),
          children: [
            MinimalStatCard(
              title: 'Active Users',
              value: data.summary.totalUsers.toString(),
              icon: Icons.people_alt_rounded,
              color: Colors.teal[900]!,
              backgroundColor: isDarkMode
                  ? Colors.teal[400]!.withOpacity(0.3)
                  : Colors.teal[50]!,
            ),
            MinimalStatCard(
              title: 'Total Products',
              value: data.summary.totalProducts.toString(),
              icon: Icons.inventory_2_rounded,
              color: Colors.indigo[600]!,
              backgroundColor: isDarkMode
                  ? Colors.indigo[900]!.withOpacity(0.3)
                  : Colors.indigo[50]!,
            ),
            MinimalStatCard(
              title: 'Avg. Order',
              value: formatter.format(
                data.summary.totalRevenue /
                    (data.summary.totalTransactions == 0
                        ? 1
                        : data.summary.totalTransactions),
              ),
              icon: Icons.shopping_basket_rounded,
              color: Colors.lightBlue[400]!, // Biru lebih muda
              backgroundColor: isDarkMode
                  ? Colors.lightBlue[100]!.withOpacity(0.3)
                  : Colors.lightBlue[50], // Paling soft dari semua
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTopProductsList(
    BuildContext context,
    DashboardData data,
    NumberFormat formatter,
  ) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.blue.withOpacity(0.1), width: 1),
      ),
      child: Column(
        children: [
          if (data.products.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24.0), // Increased padding
              child: Center(
                child: Text(
                  'No products data available',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            )
          else
            ...data.products.map((product) {
              final index = data.products.indexOf(product) + 1;
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: _getRankGradient(index),
                      ),
                      child: Center(
                        child: Text(
                          index.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: theme.colorScheme.onBackground,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            // DIUBAH: Menghitung harga dari totalRevenue dan totalSold
                            '${product.totalSold} sold • ${formatter.format(product.totalSold > 0 ? (product.totalRevenue / product.totalSold) : 0)} each',
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      formatter.format(product.totalRevenue),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[600],
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  LinearGradient _getRankGradient(int rank) {
    switch (rank) {
      case 1:
        return LinearGradient(colors: [Colors.amber[700]!, Colors.amber[500]!]);
      case 2:
        return LinearGradient(colors: [Colors.grey[600]!, Colors.grey[400]!]);
      case 3:
        return LinearGradient(colors: [Colors.brown[500]!, Colors.brown[300]!]);
      default:
        return LinearGradient(colors: [Colors.blue[600]!, Colors.blue[400]!]);
    }
  }
}
