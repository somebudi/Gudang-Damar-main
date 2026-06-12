import 'dart:ui';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await AuthService.instance.getUser();
    if (!mounted) return;
    setState(() {
      _user = user;
      _loading = false;
    });
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar?'),
        content: const Text('Yakin mau logout dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFBA1A1A)),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AuthService.instance.logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _editUsername() {
    final TextEditingController nameController = TextEditingController(text: _user?['name']);
    
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Stack(
          children: [
            // Backdrop blur
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  color: const Color(0xFF121C2A).withValues(alpha: 0.4), // on-surface with opacity
                ),
              ),
            ),
            // Modal Card
            Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 400),
                  margin: const EdgeInsets.symmetric(horizontal: 16), // margin-mobile
                  decoration: BoxDecoration(
                    color: Colors.white, // surface
                    borderRadius: BorderRadius.circular(12), // xl
                    boxShadow: const [
                      BoxShadow(color: Color(0x1A000000), offset: Offset(0, 4), blurRadius: 10),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Color(0xFFC0C7D1))), // outline-variant
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Ubah Nama Pengguna',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 20, // title-lg
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF121C2A), // on-surface
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Color(0xFF40474F)), // on-surface-variant
                              onPressed: () => Navigator.pop(context),
                              tooltip: 'Tutup',
                              style: IconButton.styleFrom(
                                hoverColor: const Color(0xFFE6EEFF), // surface-container
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Body
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 4, bottom: 4),
                              child: Text(
                                'Nama Pengguna',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12, // label-md
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF40474F), // on-surface-variant
                                ),
                              ),
                            ),
                            TextField(
                              controller: nameController,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16, // body-lg
                                color: Color(0xFF121C2A),
                              ),
                              decoration: InputDecoration(
                                hintText: 'Masukkan nama baru',
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFFC0C7D1)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFFC0C7D1)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFF66ACE6), width: 2), // primary-container
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Actions
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _user?['name'] = nameController.text;
                                  });
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Nama pengguna berhasil diubah')),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF66ACE6), // primary-container
                                  foregroundColor: const Color(0xFF003F63), // on-primary-container
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  elevation: 1,
                                ),
                                child: const Text(
                                  'Simpan Perubahan',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 16, // title-md
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF40474F), // on-surface-variant
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text(
                                  'Batal',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 16, // title-md
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween(begin: 0.95, end: 1.0).animate(
              CurvedAnimation(parent: anim1, curve: Curves.easeOut),
            ),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F9FF),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final userName = _user?['name'] ?? 'User Name';
    final userEmail = _user?['email'] ?? 'email@example.com';
    
    // Use Google/backend profile photo, or fallback to initials
    final String fallbackUrl = 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(userName)}&background=66ace6&color=fff&size=200';
    final avatarUrl = _user?['profile_photo_url'] ?? fallbackUrl;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FF), // surface
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF40474F)), // on-surface-variant
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Gudang Damar',
          style: TextStyle(
            color: Color(0xFF006398), // primary
            fontWeight: FontWeight.w700,
            fontSize: 24, // headline-md
            fontFamily: 'Inter',
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF66ACE6), // primary-container
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0x33006398)), // primary/20
                boxShadow: const [
                  BoxShadow(color: Color(0x1A000000), offset: Offset(0, 1), blurRadius: 2), // shadow-sm
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: Color(0xFF003F63), // on-primary-container
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color(0xFFC0C7D1).withValues(alpha: 0.5), // border-outline-variant/50
            height: 1.0,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0x3366ACE6), // primary-container/20
              Color(0xFFF8F9FF), // surface
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 600), // max-w-2xl equivalent
              padding: const EdgeInsets.all(40.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FF), // surface
                borderRadius: BorderRadius.circular(32), // rounded-[2rem]
                border: Border.all(color: const Color(0x6666ACE6)), // primary-container/40
                boxShadow: const [
                  BoxShadow(color: Color(0x1A000000), offset: Offset(0, 10), blurRadius: 15), // shadow-lg
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Avatar with Camera Icon
                  Container(
                    width: 192, // md:w-48
                    height: 192, // md:h-48
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF66ACE6), // primary-container
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFF8F9FF), width: 6), // border-surface
                      boxShadow: const [
                        BoxShadow(color: Color(0x1A006398), blurRadius: 0, spreadRadius: 4), // ring-4 ring-primary/10
                        BoxShadow(color: Color(0x1A000000), offset: Offset(0, 4), blurRadius: 6), // shadow-md
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipOval(
                            child: Image.network(
                              avatarUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.person, size: 80, color: Colors.white),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                // TODO: Handle change avatar
                              },
                              customBorder: const CircleBorder(),
                              child: Container(
                                padding: const EdgeInsets.all(10), // p-2.5
                                decoration: const BoxDecoration(
                                  color: Color(0xFF006398), // primary
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(color: Color(0x33000000), offset: Offset(0, 10), blurRadius: 15), // shadow-lg
                                  ],
                                ),
                                child: const Icon(Icons.photo_camera, size: 20, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // User Info
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: userName,
                      style: const TextStyle(
                        fontSize: 24, // text-[24px]
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF006398), // primary
                        fontFamily: 'Inter',
                      ),
                      children: [
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _editUsername,
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(Icons.edit, size: 24, color: Color(0xFF006398)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 8),

                  // Email Pill
                  Container(
                    margin: const EdgeInsets.only(bottom: 40),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), // px-4 py-1.5
                    decoration: BoxDecoration(
                      color: const Color(0x3366ACE6), // bg-primary-container/20
                      borderRadius: BorderRadius.circular(999), // rounded-full
                    ),
                    child: Text(
                      userEmail,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16, // text-title-lg (Wait, title-lg is 20px in tailwind, but let's use 16 to fit email better or 20)
                        fontWeight: FontWeight.w600,
                        color: Color(0xE640474F), // text-on-surface-variant/90
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),

                  // Logout Area
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _handleLogout,
                      icon: const Icon(Icons.logout, size: 24, color: Colors.white), // text-[24px] text-on-error
                      label: const Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 20, // text-title-lg
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                          color: Colors.white, // text-on-error
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFBA1A1A), // bg-error
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16), // py-4
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16), // rounded-2xl
                        ),
                        elevation: 4, // shadow-md
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
