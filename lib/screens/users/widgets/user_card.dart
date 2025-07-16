import 'package:flutter/material.dart';
import 'package:transaksi/data/models/user.dart';

// Widget untuk menampilkan kartu informasi pengguna dengan animasi
class UserCard extends StatefulWidget {
  final User user;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const UserCard({
    super.key,
    required this.user,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard>
    with SingleTickerProviderStateMixin {
  // Controller dan state untuk animasi dan interaksi
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller dan animasi
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubic,
      ),
    );
    _elevationAnimation = Tween<double>(begin: 4.0, end: 12.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    // Membersihkan controller untuk mencegah memory leak
    _animationController.dispose();
    super.dispose();
  }

  // Fungsi-fungsi untuk menangani interaksi sentuhan dan hover
  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _onHover(bool isHovered) {
    setState(() => _isHovered = isHovered);
    if (isHovered) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  // Metode utama untuk membangun UI kartu
  @override
  Widget build(BuildContext context) {
    // Menentukan warna berdasarkan role pengguna
    final MaterialColor primaryColor = widget.user.role == 'admin'
        ? Colors.blue
        : Colors.lightBlue;
    final Color secondaryColor = widget.user.role == 'admin'
        ? Colors.blue.shade100
        : Colors.lightBlue.shade100;

    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          onTap: widget.onEdit,
          child: AnimatedBuilder(
            animation: _elevationAnimation,
            builder: (context, child) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, Colors.grey.shade50],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.1),
                      blurRadius: _elevationAnimation.value,
                      offset: Offset(0, _elevationAnimation.value * 0.3),
                    ),
                  ],
                  border: Border.all(
                    color: _isPressed || _isHovered
                        ? primaryColor.withOpacity(0.3)
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        _buildEnhancedAvatar(
                          primaryColor,
                          widget.user.role == 'admin',
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildUserHeader(
                                primaryColor,
                                secondaryColor,
                                widget.user.role == 'admin',
                              ),
                              const SizedBox(height: 12),
                              _buildUserEmail(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        _buildActionButtons(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Widget untuk avatar pengguna
  Widget _buildEnhancedAvatar(MaterialColor primaryColor, bool isAdmin) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [primaryColor.shade400, primaryColor.shade600],
        ),
      ),
      child: Icon(
        isAdmin ? Icons.admin_panel_settings_rounded : Icons.person_rounded,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  // Widget untuk header (nama dan role)
  Widget _buildUserHeader(
    MaterialColor primaryColor,
    Color secondaryColor,
    bool isAdmin,
  ) {
    return Row(
      children: [
        // PERBAIKAN: Menggunakan Expanded agar teks nama tidak overflow
        Expanded(
          child: Text(
            widget.user.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: secondaryColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            widget.user.role.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: primaryColor.shade700,
            ),
          ),
        ),
      ],
    );
  }

  // Widget untuk email pengguna
  Widget _buildUserEmail() {
    return Row(
      children: [
        Icon(Icons.email_rounded, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            widget.user.email,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Widget untuk tombol aksi (edit dan delete)
  Widget _buildActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildActionButton(
          icon: Icons.edit_rounded,
          color: Colors.blue,
          onPressed: widget.onEdit,
        ),
        const SizedBox(width: 8),
        _buildActionButton(
          icon: Icons.delete_rounded,
          color: Colors.red,
          onPressed: widget.onDelete,
        ),
      ],
    );
  }

  // Widget helper untuk membuat tombol aksi
  Widget _buildActionButton({
    required IconData icon,
    required MaterialColor color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 40,
          height: 40,
          child: Icon(icon, color: color.shade600, size: 20),
        ),
      ),
    );
  }
}
