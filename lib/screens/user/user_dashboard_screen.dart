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

class UserDashboardScreen extends StatelessWidget {
  final DashboardData data;
  const UserDashboardScreen({super.key, required this.data});

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
                  'My Dashboard',
                  style: TextStyle(
                    fontSize: isDesktop ? 28 : 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(1, 1),
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
                            AnalyticsScreen(data: data, isAdmin: false),
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
                      Icons.person_outline,
                      color: Colors.white,
                      size: isDesktop ? 20 : 16,
                    ),
                  ),
                ),
              ],
              backgroundColor: Colors.blue[700],
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 40 : 20,
                vertical: 20,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildWelcomeHeader(
                    context,
                    authProvider.user?.name ?? 'User',
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
            SliverPadding(
              padding: EdgeInsets.only(
                top: 16,
                left: isDesktop ? 40 : 20,
                right: isDesktop ? 40 : 20,
              ),
              sliver: SliverToBoxAdapter(
                child: _buildSectionHeader(
                  context,
                  'My Favorite Products',
                  Icons.favorite_rounded,
                  isDesktop,
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 40 : 20),
              sliver: SliverToBoxAdapter(
                child: _buildFavoriteProductsList(context, data),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.only(
                top: 24,
                left: isDesktop ? 40 : 20,
                right: isDesktop ? 40 : 20,
              ),
              sliver: SliverToBoxAdapter(
                child: _buildSectionHeader(
                  context,
                  'My Recent Transactions',
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
                  'Here\'s what you\'ve been doing with your account',
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
    DashboardData data,
    NumberFormat formatter,
    bool isDesktop,
  ) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final summary = data.summary;
    final totalSpent = summary.totalSpent ?? 0;
    final totalTransactions = summary.totalTransactions;

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
                    title: 'Total Spent',
                    value: formatter.format(totalSpent),
                    icon: Icons.shopping_cart_checkout_rounded,
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
                    title: 'My Transactions',
                    value: totalTransactions.toString(),
                    icon: Icons.receipt_long_rounded,
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
        MinimalStatCard(
          title: 'Average Order',
          value: formatter.format(
            totalTransactions == 0 ? 0 : (totalSpent / totalTransactions),
          ),
          icon: Icons.shopping_basket_rounded,
          color: Colors.blueAccent[400]!,
          // ======================================================================
          // PERBAIKAN UTAMA: Mengganti Colors.blueAccent[50] yang tidak ada
          // menjadi Colors.blue[50] yang valid.
          // ======================================================================
          backgroundColor: isDarkMode
              ? Colors.blueAccent[700]!.withOpacity(0.3)
              : Colors.blue[50]!, // DIUBAH DARI Colors.blueAccent[50]!
        ),
      ],
    );
  }

  Widget _buildFavoriteProductsList(BuildContext context, DashboardData data) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    if (data.products.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.symmetric(vertical: 40),
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
            Icon(
              Icons.favorite_border_rounded,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'No Favorite Products Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Your most purchased items will appear here',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    }

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
          ...data.products.map((product) {
            final favoriteProduct = product as FavoriteProduct;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: isDarkMode ? Colors.grey[700] : Colors.grey[100],
                    ),
                    child:
                        favoriteProduct.imageUrl != null &&
                            favoriteProduct.imageUrl!.isNotEmpty
                        ? Image.network(
                            favoriteProduct.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.image_not_supported_outlined,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.3,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.shopping_bag_outlined,
                            color: theme.colorScheme.onSurface.withOpacity(0.3),
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          favoriteProduct.name,
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
                          'Purchased ${favoriteProduct.totalBought} times',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.pink[600]!, Colors.pink[400]!],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${favoriteProduct.totalBought}x',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 14,
                      ),
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
}
