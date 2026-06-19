import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nomCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _loading = false;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _nomCtrl.dispose();
    _telCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final profile = await AuthService.signUp(
        email: _emailCtrl.text,
        password: _passCtrl.text,
        nom: _nomCtrl.text,
        telephone: _telCtrl.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Text('Bienvenue ${profile.nom} !'),
            ]),
            backgroundColor: AppColors.cleanoovGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (ctx, anim, sec) => HomeScreen(
              technicienName: profile.nom,
              technicienTel: profile.telephone,
            ),
            transitionsBuilder: (ctx, anim, sec, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Expanded(child: Text(_friendlyError(e.toString()))),
            ]),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  String _friendlyError(String raw) {
    if (raw.contains('email-already-in-use')) {
      return 'Cet email est déjà utilisé';
    }
    if (raw.contains('weak-password')) return 'Mot de passe trop faible (6 caractères min)';
    if (raw.contains('invalid-email')) return 'Adresse email invalide';
    if (raw.contains('network')) return 'Vérifiez votre connexion internet';
    if (raw.contains('non configuré')) return 'Firebase non configuré — ajoutez vos clés';
    return 'Erreur lors de la création du compte';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0E1A), Color(0xFF0D1A0F), Color(0xFF0A1612)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 32),

                    // Logo
                    Image.asset(
                      'assets/images/logo_dark.png',
                      height: 55,
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
                    const SizedBox(height: 8),
                    Text(
                      'Créer votre compte technicien',
                      style: TextStyle(
                          color: Colors.white.withAlpha(150),
                          fontSize: 13,
                          letterSpacing: 0.3),
                    ),

                    const SizedBox(height: 32),

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
                            // En-tête
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.cleanoovGreen.withAlpha(30),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: AppColors.cleanoovGreen
                                            .withAlpha(60)),
                                  ),
                                  child: const Icon(
                                      Icons.person_add_outlined,
                                      color: AppColors.cleanoovGreen,
                                      size: 20),
                                ),
                                const SizedBox(width: 14),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Nouveau compte',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700)),
                                    Text('Remplissez vos informations',
                                        style: TextStyle(
                                            color: Colors.white54,
                                            fontSize: 11)),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),
                            Divider(color: Colors.white.withAlpha(15), height: 1),
                            const SizedBox(height: 24),

                            // Nom complet
                            _field(
                              controller: _nomCtrl,
                              label: 'Nom complet',
                              icon: Icons.person_outline,
                              caps: TextCapitalization.words,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Champ requis';
                                if (v.trim().length < 2) return 'Minimum 2 caractères';
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),

                            // Téléphone
                            _field(
                              controller: _telCtrl,
                              label: 'Numéro de téléphone',
                              icon: Icons.phone_outlined,
                              keyboard: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(8),
                              ],
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Champ requis';
                                if (v.trim().length != 8) return 'Exactement 8 chiffres';
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),

                            // Email
                            _field(
                              controller: _emailCtrl,
                              label: 'Adresse email',
                              icon: Icons.email_outlined,
                              keyboard: TextInputType.emailAddress,
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(RegExp(r'\s'))
                              ],
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Champ requis';
                                if (!v.contains('@') || !v.contains('.')) return 'Email invalide';
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),

                            // Mot de passe
                            _field(
                              controller: _passCtrl,
                              label: 'Mot de passe',
                              icon: Icons.lock_outline,
                              obscure: _obscurePass,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePass
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.white38,
                                  size: 18,
                                ),
                                onPressed: () =>
                                    setState(() => _obscurePass = !_obscurePass),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Champ requis';
                                if (v.length < 6) return 'Minimum 6 caractères';
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),

                            // Confirmer mot de passe
                            _field(
                              controller: _confirmPassCtrl,
                              label: 'Confirmer le mot de passe',
                              icon: Icons.lock_outline,
                              obscure: _obscureConfirm,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirm
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.white38,
                                  size: 18,
                                ),
                                onPressed: () => setState(
                                    () => _obscureConfirm = !_obscureConfirm),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Champ requis';
                                if (v != _passCtrl.text) {
                                  return 'Les mots de passe ne correspondent pas';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 28),

                            // Bouton créer
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _loading ? null : _signup,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.cleanoovGreen,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                                child: _loading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5),
                                      )
                                    : const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.how_to_reg, size: 18),
                                          SizedBox(width: 10),
                                          Text(
                                            'Créer mon compte',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Retour au login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Déjà un compte ?',
                            style: TextStyle(
                                color: Colors.white.withAlpha(100),
                                fontSize: 13)),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Se connecter',
                            style: TextStyle(
                              color: AppColors.cleanoovGreen,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    TextCapitalization caps = TextCapitalization.none,
    TextInputType keyboard = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      textCapitalization: caps,
      keyboardType: keyboard,
      inputFormatters: inputFormatters,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
        prefixIcon: Icon(icon, color: AppColors.cleanoovGreen, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withAlpha(10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white.withAlpha(20)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white.withAlpha(20)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: AppColors.cleanoovGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        errorStyle: const TextStyle(color: AppColors.danger, fontSize: 11),
      ),
      validator: validator,
    );
  }
}
