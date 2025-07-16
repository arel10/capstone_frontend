import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:transaksi/data/models/User.dart';
import 'package:transaksi/providers/auth_provider.dart';

class ProfileColors {
  static const Color primary = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1E40AF);
  static const Color primaryLight = Color(0xFF93C5FD);
  static const Color secondary = Color(0xFF60A5FA);
  static const Color background = Color(0xFFF6F8FA);
  static const Color backgroundDark = Color(0xFF1C2128);
  static const Color card = Colors.white;
  static const Color cardDark = Color(0xFF2D333B);
}

class ProfileScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const ProfileScreen({super.key, required this.onLogout});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.5, curve: Curves.easeInOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1, curve: Curves.easeOutBack),
      ),
    );

    // Start animations after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    if (user == null) {
      return Scaffold(
        backgroundColor: isDarkMode
            ? ProfileColors.backgroundDark
            : ProfileColors.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: isDarkMode
          ? ProfileColors.backgroundDark
          : ProfileColors.background,
      body: CustomScrollView(
        slivers: [
          _buildHeader(context, user),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      _buildInfoCard(context, user),
                      const SizedBox(height: 20),
                      _buildActionsCard(context),
                      const SizedBox(height: 20),
                      _buildLogoutButton(context),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, User user) {
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      stretch: true,
      backgroundColor: ProfileColors.primaryDark,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        centerTitle: true,
        titlePadding: const EdgeInsets.only(bottom: 16),
        title: AnimatedOpacity(
          opacity: 1,
          duration: const Duration(milliseconds: 500),
          child: Text(
            user.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              shadows: [Shadow(blurRadius: 2, color: Colors.black38)],
            ),
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Animated gradient background
            AnimatedContainer(
              duration: const Duration(seconds: 3),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ProfileColors.primaryDark,
                    ProfileColors.primaryLight,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            // Floating bubbles animation
            Positioned.fill(
              child: _BubblesAnimation(
                bubbleCount: 15,
                maxBubbleSize: 40,
                color: Colors.white.withOpacity(0.1),
              ),
            ),

            // Large decorative icon
            Positioned(
              bottom: -50,
              right: -50,
              child: AnimatedRotation(
                duration: const Duration(seconds: 30),
                turns: 1,
                child: Icon(
                  user.role == 'admin'
                      ? Icons.shield_rounded
                      : Icons.person_rounded,
                  size: 200,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Avatar with pulse animation
                  _PulseAnimation(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                        boxShadow: [
                          BoxShadow(
                            color: ProfileColors.primary.withOpacity(0.4),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.white,
                        child: Icon(
                          user.role == 'admin'
                              ? Icons.shield_rounded
                              : Icons.person_rounded,
                          size: 50,
                          color: ProfileColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 70),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, User user) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? ProfileColors.cardDark : ProfileColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Account Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.info_outline_rounded,
                color: ProfileColors.primary,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoTile(
            icon: Icons.alternate_email_rounded,
            title: 'Email Address',
            subtitle: user.email,
            iconColor: ProfileColors.primary,
          ),
          const Divider(height: 24, indent: 10, endIndent: 10),
          _buildInfoTile(
            icon: Icons.shield_outlined,
            title: 'Role',
            subtitle: user.role.toUpperCase(),
            iconColor: ProfileColors.secondary,
          ),
          const Divider(height: 24, indent: 10, endIndent: 10),
          _buildInfoTile(
            icon: Icons.calendar_today_rounded,
            title: 'Joined Since',
            subtitle: DateFormat('d MMMM yyyy').format(user.createdAt),
            iconColor: Colors.orange.shade600,
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCard(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? ProfileColors.cardDark : ProfileColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildActionTile(
            icon: Icons.edit_rounded,
            title: 'Edit Profile',
            onTap: () => _showFeatureNotAvailable(context),
            isFirst: true,
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          _buildActionTile(
            icon: Icons.lock_reset_rounded,
            title: 'Change Password',
            onTap: () => _showFeatureNotAvailable(context),
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          _buildActionTile(
            icon: Icons.notifications_rounded,
            title: 'Notifications',
            onTap: () => _showFeatureNotAvailable(context),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF4444).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.logout_rounded, color: Colors.white),
        label: const Text(
          'Logout',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: () {
          // Add a little scale animation when pressed
          _animationController.reset();
          _animationController.forward().then((_) => widget.onLogout());
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEF4444),
          padding: const EdgeInsets.symmetric(vertical: 16),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDarkMode
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(16) : Radius.zero,
          bottom: isLast ? const Radius.circular(16) : Radius.zero,
        ),
        highlightColor: ProfileColors.primary.withOpacity(0.1),
        splashColor: ProfileColors.primary.withOpacity(0.2),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: ProfileColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: ProfileColors.primary, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFeatureNotAvailable(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('This feature is not yet available.'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: ProfileColors.primary,
        elevation: 6,
      ),
    );
  }
}

// Custom bubble animation for the header background
class _BubblesAnimation extends StatefulWidget {
  final int bubbleCount;
  final double maxBubbleSize;
  final Color color;

  const _BubblesAnimation({
    required this.bubbleCount,
    required this.maxBubbleSize,
    required this.color,
  });

  @override
  _BubblesAnimationState createState() => _BubblesAnimationState();
}

class _BubblesAnimationState extends State<_BubblesAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Bubble> bubbles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();

    // Initialize bubbles
    bubbles = List.generate(widget.bubbleCount, (index) {
      return Bubble(
        size: Random().nextDouble() * widget.maxBubbleSize,
        x: Random().nextDouble(),
        y: Random().nextDouble(),
        speed: 0.5 + Random().nextDouble() * 0.5,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: BubblePainter(
            bubbles: bubbles,
            color: widget.color,
            progress: _controller.value,
          ),
        );
      },
    );
  }
}

class Bubble {
  double size;
  double x;
  double y;
  double speed;
  double initialY;

  Bubble({
    required this.size,
    required this.x,
    required this.y,
    required this.speed,
  }) : initialY = y;
}

class BubblePainter extends CustomPainter {
  final List<Bubble> bubbles;
  final Color color;
  final double progress;

  BubblePainter({
    required this.bubbles,
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    for (final bubble in bubbles) {
      final y = (bubble.initialY + progress * bubble.speed) % 1.0;
      final x = bubble.x;
      final radius = bubble.size / 2;

      canvas.drawCircle(Offset(x * size.width, y * size.height), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant BubblePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// Pulse animation for the avatar
class _PulseAnimation extends StatefulWidget {
  final Widget child;

  const _PulseAnimation({required this.child});

  @override
  _PulseAnimationState createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<_PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 0.98,
      end: 1.02,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: widget.child,
        );
      },
    );
  }
}
