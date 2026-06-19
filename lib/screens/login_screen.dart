import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'signup_screen.dart';
import 'admin/admin_login_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  bool _resetSent = false;

  late AnimationController _logoCtrl;
  late AnimationController _panelCtrl;
  late AnimationController _particleCtrl;
  late AnimationController _formCtrl;

  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _panelRay;
  late Animation<double> _formSlide;
  late Animation<double> _formFade;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _panelCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))
      ..repeat();
    _particleCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 4))
      ..repeat();
    _formCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));

    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _logoCtrl, curve: const Interval(0.0, 0.5)));
    _panelRay = Tween<double>(begin: 0.0, end: 1.0).animate(_panelCtrl);
    _formSlide = Tween<double>(begin: 60.0, end: 0.0).animate(
        CurvedAnimation(parent: _formCtrl, curve: Curves.easeOutCubic));
    _formFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _formCtrl, curve: Curves.easeOut));

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _logoCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) _formCtrl.forward();
    });
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _panelCtrl.dispose();
    _particleCtrl.dispose();
    _formCtrl.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final profile = await AuthService.signIn(
        _emailController.text,
        _passwordController.text,
      );
      if (mounted) {
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
    } on Exception catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(Icons.lock_outline, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Expanded(child: Text(_friendlyError(e.toString()))),
            ]),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  Future<void> _resetPassword() async {
    // Pré-remplir avec l'email déjà saisi
    final emailCtrl = TextEditingController(
        text: _emailController.text.trim());
    final formKey = GlobalKey<FormState>();
    bool sending = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF111827),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Row(children: [
            Icon(Icons.lock_reset, color: AppColors.cleanoovGreen),
            SizedBox(width: 10),
            Text('Mot de passe oublié',
                style: TextStyle(color: Colors.white, fontSize: 16)),
          ]),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Entrez votre email pour recevoir un lien de réinitialisation.',
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Adresse email',
                    labelStyle:
                        const TextStyle(color: Colors.white38),
                    prefixIcon: const Icon(Icons.email_outlined,
                        color: AppColors.cleanoovGreen, size: 18),
                    filled: true,
                    fillColor: Colors.white.withAlpha(10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: Colors.white.withAlpha(20))),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: Colors.white.withAlpha(20))),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: AppColors.cleanoovGreen,
                            width: 1.5)),
                    errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: AppColors.danger)),
                    errorStyle: const TextStyle(
                        color: AppColors.danger, fontSize: 11),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Champ requis';
                    }
                    if (!v.contains('@') || !v.contains('.')) {
                      return 'Email invalide';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler',
                  style: TextStyle(color: Colors.white38)),
            ),
            ElevatedButton(
              onPressed: sending
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialogState(() => sending = true);
                      try {
                        await AuthService.resetPassword(
                            emailCtrl.text.trim());
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (mounted) {
                          setState(() => _resetSent = true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(children: [
                                const Icon(Icons.check_circle,
                                    color: Colors.white, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: Text(
                                        'Email envoyé à ${emailCtrl.text.trim()}')),
                              ]),
                              backgroundColor:
                                  AppColors.cleanoovGreen,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(10)),
                            ),
                          );
                        }
                      } catch (e) {
                        setDialogState(() => sending = false);
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(
                              content: Text(
                                  _friendlyError(e.toString())),
                              backgroundColor: AppColors.danger,
                            ),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cleanoovGreen,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: sending
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Envoyer'),
            ),
          ],
        ),
      ),
    );
    emailCtrl.dispose();
  }

  String _friendlyError(String raw) {
    if (raw.contains('user-not-found') ||
        raw.contains('wrong-password') ||
        raw.contains('invalid-credential')) {
      return 'Email ou mot de passe incorrect';
    }
    if (raw.contains('network')) return 'Vérifiez votre connexion internet';
    if (raw.contains('too-many-requests')) {
      return 'Trop de tentatives. Réessayez plus tard';
    }
    if (raw.contains('YOUR_') || raw.contains('not been initialized')) {
      return 'Firebase non configuré — lancez: flutterfire configure';
    }
    return 'Erreur de connexion. Vérifiez vos identifiants';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fond dégradé Cleanoov
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0A0E1A),
                  Color(0xFF0D1A0F),
                  Color(0xFF0A1612),
                ],
              ),
            ),
          ),

          // Animation panneaux solaires
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _panelCtrl,
              builder: (ctx, child) =>
                  CustomPaint(painter: _SolarFieldPainter(_panelRay.value)),
            ),
          ),

          // Particules lumineuses
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _particleCtrl,
              builder: (ctx, child) =>
                  CustomPaint(painter: _ParticlePainter(_particleCtrl.value)),
            ),
          ),

          // Contenu
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    ScaleTransition(
                      scale: _logoScale,
                      child: FadeTransition(
                          opacity: _logoFade, child: _buildLogo()),
                    ),
                    const SizedBox(height: 40),
                    AnimatedBuilder(
                      animation: _formCtrl,
                      builder: (ctx, child) => Transform.translate(
                        offset: Offset(0, _formSlide.value),
                        child: Opacity(
                            opacity: _formFade.value, child: child),
                      ),
                      child: _buildForm(),
                    ),
                    const SizedBox(height: 28),
                    FadeTransition(
                      opacity: _formFade,
                      child: Column(
                        children: [
                          Text(
                            'cleanoov.com',
                            style: TextStyle(
                              color: AppColors.cleanoovGreen.withAlpha(180),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Cleaner Panels, Brighter Future',
                            style: TextStyle(
                                color: Colors.white.withAlpha(80),
                                fontSize: 11,
                                letterSpacing: 0.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Image.asset(
          'assets/images/logo_dark.png',
          height: 70,
          errorBuilder: (ctx, e, t) => RichText(
            text: const TextSpan(children: [
              TextSpan(
                text: 'CLE',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2),
              ),
              TextSpan(
                text: 'ANOOV',
                style: TextStyle(
                    color: AppColors.cleanoovGreen,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(
                color: AppColors.cleanoovGreen.withAlpha(120), width: 1),
            borderRadius: BorderRadius.circular(20),
            color: AppColors.cleanoovGreen.withAlpha(25),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                    color: AppColors.cleanoovGreen, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              const Text(
                'Innovation Solaire Tunisienne',
                style: TextStyle(
                    color: AppColors.cleanoovGreenLight,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(20), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(28),
          color: const Color(0xFF111827),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête formulaire
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.cleanoovGreen.withAlpha(30),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppColors.cleanoovGreen.withAlpha(60)),
                      ),
                      child: const Icon(Icons.engineering_outlined,
                          color: AppColors.cleanoovGreen, size: 20),
                    ),
                    const SizedBox(width: 14),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Espace Technicien',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'Connectez-vous pour vos missions',
                          style: TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                Divider(color: Colors.white.withAlpha(15), height: 1),
                const SizedBox(height: 24),

                // Email
                _darkField(
                  controller: _emailController,
                  label: 'Adresse email',
                  icon: Icons.email_outlined,
                  keyboard: TextInputType.emailAddress,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'\s'))
                  ],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Champ requis';
                    if (!v.contains('@') || !v.contains('.')) {
                      return 'Email invalide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Mot de passe
                _darkField(
                  controller: _passwordController,
                  label: 'Mot de passe',
                  icon: Icons.lock_outline,
                  obscure: _obscure,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.white38,
                      size: 18,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Champ requis' : null,
                ),

                // Mot de passe oublié
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _resetPassword,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      _resetSent
                          ? 'Email envoyé ✓'
                          : 'Mot de passe oublié ?',
                      style: TextStyle(
                        color: _resetSent
                            ? AppColors.cleanoovGreen
                            : Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Bouton connexion technicien
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _login,
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
                                color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.solar_power, size: 18),
                              SizedBox(width: 10),
                              Text(
                                'Accéder à mes missions',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    letterSpacing: 0.3),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 14),

                // Séparateur
                Row(children: [
                  Expanded(child: Divider(color: Colors.white.withAlpha(20))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('ou',
                        style: TextStyle(
                            color: Colors.white.withAlpha(60), fontSize: 12)),
                  ),
                  Expanded(child: Divider(color: Colors.white.withAlpha(20))),
                ]),
                const SizedBox(height: 12),

                // Bouton créer un compte
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignupScreen()),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.cleanoovGreen,
                      side: BorderSide(
                          color: AppColors.cleanoovGreen.withAlpha(120)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.person_add_outlined, size: 16),
                    label: const Text('Créer un compte',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 10),

                // Bouton espace admin
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AdminLoginScreen()),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white38,
                      side: BorderSide(color: Colors.white.withAlpha(20)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.admin_panel_settings_outlined,
                        size: 14),
                    label: const Text('Espace Admin',
                        style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _darkField({
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

// ── Painter — Champ de panneaux solaires animé ─────────────────────────────
class _SolarFieldPainter extends CustomPainter {
  final double progress;
  _SolarFieldPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    const cols = 6;
    const rows = 10;
    final cellW = size.width / cols;
    final cellH = size.height / rows;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final pulse =
            math.sin(progress * math.pi * 2 + (r + c) * 0.4);
        final alpha = (0.4 + pulse * 0.3).clamp(0.1, 1.0);

        final fillPaint = Paint()
          ..color = const Color(0xFF22A353)
              .withAlpha((18 * alpha).round())
          ..style = PaintingStyle.fill;
        final borderPaint = Paint()
          ..color = const Color(0xFF22A353)
              .withAlpha((35 * alpha).round())
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8;

        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
              c * cellW + 3, r * cellH + 3, cellW - 6, cellH - 6),
          const Radius.circular(3),
        );
        canvas.drawRRect(rect, fillPaint);
        canvas.drawRRect(rect, borderPaint);

        // Lignes internes panneau
        final left = c * cellW + 3;
        final top = r * cellH + 3;
        final w = cellW - 6;
        final h = cellH - 6;
        final linePaint = Paint()
          ..color = const Color(0xFF22A353)
              .withAlpha((20 * alpha).round())
          ..strokeWidth = 0.5;
        canvas.drawLine(
            Offset(left, top + h / 3), Offset(left + w, top + h / 3), linePaint);
        canvas.drawLine(
            Offset(left, top + 2 * h / 3), Offset(left + w, top + 2 * h / 3), linePaint);
        canvas.drawLine(
            Offset(left + w / 2, top), Offset(left + w / 2, top + h), linePaint);
      }
    }

    // Rayon solaire
    final rayPaint = Paint()
      ..color = const Color(0xFF22A353).withAlpha(15)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final cx = size.width * 0.8;
    final cy = size.height * 0.15;
    for (int i = 0; i < 8; i++) {
      final angle = progress * math.pi * 2 + i * math.pi / 4;
      canvas.drawLine(
        Offset(cx + math.cos(angle) * 20, cy + math.sin(angle) * 20),
        Offset(cx + math.cos(angle) * 40, cy + math.sin(angle) * 40),
        rayPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_SolarFieldPainter old) => old.progress != progress;
}

// ── Painter — Particules flottantes ────────────────────────────────────────
class _ParticlePainter extends CustomPainter {
  final double t;
  _ParticlePainter(this.t);

  static final List<List<double>> _particles =
      List.generate(18, (i) {
    final rng = math.Random(i * 13 + 7);
    return [
      rng.nextDouble(),
      rng.nextDouble(),
      rng.nextDouble() * 0.6 + 0.3,
      rng.nextDouble() * 0.5 + 0.2,
    ];
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final p in _particles) {
      final x = p[0] * size.width;
      final y = ((p[1] + t * p[2]) % 1.0) * size.height;
      final radius = p[3] * 3 + 1;
      final alpha =
          (math.sin(t * math.pi * 2 + p[0] * 6) * 0.4 + 0.5).clamp(0.0, 1.0);
      paint.color =
          const Color(0xFF22A353).withAlpha((alpha * 180).round());
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.t != t;
}
