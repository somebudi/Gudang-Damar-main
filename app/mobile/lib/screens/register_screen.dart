import 'package:flutter/material.dart';

import '../services/api_exception.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_scaffold.dart';
import 'riwayat_aktivitas_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name    = TextEditingController();
  final _email   = TextEditingController();
  final _pass    = TextEditingController();
  final _confirm = TextEditingController();

  bool _hidePass      = true;
  bool _hideConfirm   = true;
  bool _loading       = false;
  bool _loadingGoogle = false;
  String? _serverError;
  Map<String, List<String>>? _fieldErrors;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  // ─── Register email/password ──────────────────────────────────────────────
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading     = true;
      _serverError = null;
      _fieldErrors = null;
    });

    try {
      await AuthService.instance.register(
        name: _name.text.trim(),
        email: _email.text.trim(),
        password: _pass.text,
        passwordConfirmation: _confirm.text,
      );

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const RiwayatAktivitasScreen()),
      );
    } on ApiException catch (e) {
      setState(() {
        _serverError = e.isValidation ? null : e.message;
        _fieldErrors = e.validationErrors;
      });
    } catch (e) {
      setState(() => _serverError = 'Terjadi kesalahan: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ─── Google Sign-In ───────────────────────────────────────────────────────
  Future<void> _signInWithGoogle() async {
    setState(() {
      _loadingGoogle = true;
      _serverError   = null;
    });

    try {
      await AuthService.instance.loginWithGoogle();

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const RiwayatAktivitasScreen()),
      );
    } on ApiException catch (e) {
      setState(() => _serverError = e.message);
    } catch (e) {
      setState(() => _serverError = 'Google Sign-In gagal: $e');
    } finally {
      if (mounted) setState(() => _loadingGoogle = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      cardChild: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_serverError != null) ...[
              ErrorBanner(message: _serverError!),
              const SizedBox(height: 12),
            ],

            // Nama
            LabeledField(
              label: 'Nama',
              errorText: _fieldErrors?['name']?.first,
              child: TextFormField(
                controller: _name,
                decoration: authInputDecoration('Full name'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
              ),
            ),
            const SizedBox(height: 12),

            // Email
            LabeledField(
              label: 'Alamat Email',
              errorText: _fieldErrors?['email']?.first,
              child: TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: authInputDecoration('email@contoh.com'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
                  if (!v.contains('@')) return 'Format email tidak valid';
                  return null;
                },
              ),
            ),
            const SizedBox(height: 12),

            // Sandi
            LabeledField(
              label: 'Sandi',
              errorText: _fieldErrors?['password']?.first,
              child: TextFormField(
                controller: _pass,
                obscureText: _hidePass,
                decoration: authInputDecoration('Sandi').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _hidePass ? Icons.visibility_off : Icons.visibility,
                      size: 18,
                      color: Colors.white70,
                    ),
                    onPressed: () => setState(() => _hidePass = !_hidePass),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Sandi wajib diisi';
                  if (v.length < 8) return 'Minimal 8 karakter';
                  return null;
                },
              ),
            ),
            const SizedBox(height: 12),

            // Konfirmasi Sandi
            LabeledField(
              label: 'Konfirmasi Sandi',
              child: TextFormField(
                controller: _confirm,
                obscureText: _hideConfirm,
                decoration: authInputDecoration('Konfirmasi sandi').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _hideConfirm ? Icons.visibility_off : Icons.visibility,
                      size: 18,
                      color: Colors.white70,
                    ),
                    onPressed: () =>
                        setState(() => _hideConfirm = !_hideConfirm),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Konfirmasi wajib diisi';
                  if (v != _pass.text) return 'Tidak cocok dengan sandi';
                  return null;
                },
              ),
            ),
            const SizedBox(height: 20),

            // Tombol Buat Akun
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Buat Akun',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // Divider
            Row(
              children: [
                const Expanded(child: Divider(color: Colors.white60)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'atau dengan cara lain',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.8),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const Expanded(child: Divider(color: Colors.white60)),
              ],
            ),
            const SizedBox(height: 12),

            // Tombol Google
            SizedBox(
              height: 44,
              child: OutlinedButton.icon(
                onPressed: _loadingGoogle ? null : _signInWithGoogle,
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: AppColors.inputBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: _loadingGoogle
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.red,
                        ),
                      )
                    : const Icon(
                        Icons.g_mobiledata,
                        size: 28,
                        color: Colors.red,
                      ),
                label: const Text(
                  'Sign in with Google',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Link login
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Udah punya akun ya? ',
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Log in',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}



