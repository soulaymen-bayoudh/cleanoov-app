import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import 'admin_dashboard_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final profile = await AuthService.signIn(_emailCtrl.text, _passCtrl.text);
      if (!profile.isAdmin) {
        await AuthService.signOut();
        setState(() => _loading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(children: [
                Icon(Icons.block, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text('Accès non autorisé — compte non administrateur'),
              ]),
              backgroundColor: AppColors.danger,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
        return;
      }
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
        );
      }
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(Icons.lock_outline, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text(_friendlyError(e.toString()))),
            ]),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  String _friendlyError(String raw) {
    if (raw.contains('user-not-found') ||
        raw.contains('wrong-password') ||
        raw.contains('invalid-credential')) {
      return 'Email ou mot de passe incorrect';
    }
    if (raw.contains('network')) return 'Vérifiez votre connexion internet';
    if (raw.contains('YOUR_') || raw.contains('not been initialized')) {
      return 'Firebase non configuré — lancez: flutterfire configure';
    }
    return 'Erreur de connexion';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0E1A), Color(0xFF111827)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  // Logo
                  Image.asset(
                    'assets/images/logo_dark.png',
                    height: 60,
                    errorBuilder: (ctx, e, t) => const Text(
                      'CLEANOOV',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.amber.withAlpha(30),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.amber.withAlpha(80)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.admin_panel_settings, color: Colors.amber, size: 14),
                        SizedBox(width: 6),
                        Text(
                          'Espace Administration',
                          style: TextStyle(
                              color: Colors.amber,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Formulaire
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111827),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withAlpha(15)),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Connexion Admin',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Accès réservé à l\'administrateur Cleanoov',
                            style: TextStyle(color: Colors.white38, fontSize: 12),
                          ),
                          const SizedBox(height: 24),

                          // Email
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Email administrateur',
                              labelStyle: const TextStyle(color: Colors.white38),
                              prefixIcon: const Icon(Icons.email_outlined,
                                  color: Colors.amber, size: 20),
                              filled: true,
                              fillColor: Colors.white.withAlpha(10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: Colors.white.withAlpha(20)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: Colors.white.withAlpha(20)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Colors.amber, width: 1.5),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: AppColors.danger),
                              ),
                              errorStyle:
                                  const TextStyle(color: AppColors.danger, fontSize: 11),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Champ requis';
                              if (!v.contains('@')) return 'Email invalide';
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Mot de passe
                          TextFormField(
                            controller: _passCtrl,
                            obscureText: _obscure,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Mot de passe',
                              labelStyle: const TextStyle(color: Colors.white38),
                              prefixIcon: const Icon(Icons.lock_outline,
                                  color: Colors.amber, size: 20),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.white38,
                                  size: 18,
                                ),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                              filled: true,
                              fillColor: Colors.white.withAlpha(10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: Colors.white.withAlpha(20)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: Colors.white.withAlpha(20)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Colors.amber, width: 1.5),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: AppColors.danger),
                              ),
                              errorStyle:
                                  const TextStyle(color: AppColors.danger, fontSize: 11),
                            ),
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Champ requis' : null,
                          ),
                          const SizedBox(height: 24),

                          // Bouton connexion
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: _loading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber.shade700,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              icon: _loading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2))
                                  : const Icon(Icons.admin_panel_settings,
                                      size: 18),
                              label: Text(_loading
                                  ? 'Connexion...'
                                  : 'Accéder au tableau de bord'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back,
                        size: 14, color: Colors.white38),
                    label: const Text('Retour',
                        style: TextStyle(color: Colors.white38, fontSize: 12)),
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
