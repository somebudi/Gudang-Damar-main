import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../screens/profile_screen.dart';

class UserProfileAvatarButton extends StatefulWidget {
  final double radius;
  final Color fallbackIconColor;
  
  const UserProfileAvatarButton({
    super.key, 
    this.radius = 14,
    this.fallbackIconColor = Colors.white,
  });

  @override
  State<UserProfileAvatarButton> createState() => _UserProfileAvatarButtonState();
}

class _UserProfileAvatarButtonState extends State<UserProfileAvatarButton> {
  String? _avatarUrl;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserAvatar();
  }

  Future<void> _loadUserAvatar() async {
    final user = await AuthService.instance.getUser();
    if (!mounted) return;
    
    final userName = user?['name'] ?? 'User Name';
    final fallbackUrl = 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(userName)}&background=66ace6&color=fff&size=200';
    
    setState(() {
      _avatarUrl = user?['profile_photo_url'] ?? fallbackUrl;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return IconButton(
        icon: Icon(Icons.account_circle_outlined, color: widget.fallbackIconColor, size: widget.radius * 2),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
        },
      );
    }
    
    return IconButton(
      icon: CircleAvatar(
        radius: widget.radius,
        backgroundImage: NetworkImage(_avatarUrl!),
        backgroundColor: const Color(0xFFDEE9FC), // surface-container-high
      ),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
      },
    );
  }
}
