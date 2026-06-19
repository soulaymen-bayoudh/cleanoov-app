import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../models/intervention_model.dart';
import '../../widgets/section_header.dart';

class Step3Nettoyage extends StatefulWidget {
  final InterventionModel intervention;
  final void Function(InterventionModel) onNext;
  final VoidCallback onPrev;

  const Step3Nettoyage({
    super.key,
    required this.intervention,
    required this.onNext,
    required this.onPrev,
  });

  @override
  State<Step3Nettoyage> createState() => _Step3NettoyageState();
}

class _Step3NettoyageState extends State<Step3Nettoyage>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _produit;
  late final TextEditingController _duree;
  late String _methode;
  late AnimationController _selectCtrl;
  late Animation<double> _selectAnim;

  @override
  void initState() {
    super.initState();
    final m = widget.intervention;
    _produit = TextEditingController(text: m.produitUtilise);
    _duree = TextEditingController(
        text: m.dureeParJour > 0 ? m.dureeParJour.toString() : '');
    _methode = m.methodeNettoyage;
    _selectCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _selectAnim =
        CurvedAnimation(parent: _selectCtrl, curve: Curves.easeOutBack);
    _selectCtrl.forward();
  }

  @override
  void dispose() {
    _produit.dispose();
    _duree.dispose();
    _selectCtrl.dispose();
    super.dispose();
  }

  void _select(String val) {
    if (_methode == val) return;
    _selectCtrl.reset();
    setState(() => _methode = val);
    _selectCtrl.forward();
  }

  void _submit() {
    final updated = widget.intervention
      ..methodeNettoyage = _methode
      ..produitUtilise = _produit.text.trim()
      ..dureeParJour = double.tryParse(_duree.text) ?? 0;
    widget.onNext(updated);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'NETTOYAGE EFFECTUÉ',
            color: AppColors.sectionCleaning,
            icon: Icons.cleaning_services,
          ),
          const SizedBox(height: 20),

          // Titre section
          const Text(
            'Choisissez la méthode de nettoyage',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // ── Deux cartes image côte à côte ──────────────────────────
          Row(
            children: [
              Expanded(
                child: _ImageMethodCard(
                  value: 'brosse',
                  label: 'Brosse Manuelle',
                  imagePath: 'assets/images/brosse.jpg.jpeg',
                  icon: Icons.brush,
                  description: 'Nettoyage à la brosse avec eau',
                  selected: _methode == 'brosse',
                  onTap: () => _select('brosse'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ImageMethodCard(
                  value: 'robot',
                  label: 'Robot Automatique',
                  imagePath: 'assets/images/robot.jpg.png',
                  icon: Icons.smart_toy_outlined,
                  description: 'Robot autonome Cleanoov',
                  selected: _methode == 'robot',
                  onTap: () => _select('robot'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Bandeau récap méthode sélectionnée ─────────────────────
          AnimatedBuilder(
            animation: _selectAnim,
            builder: (ctx, child) => Transform.scale(
              scale: 0.95 + 0.05 * _selectAnim.value,
              child: child,
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.cleanoovGreen.withAlpha(15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.cleanoovGreen.withAlpha(80)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      _methode == 'brosse'
                          ? 'assets/images/brosse.jpg.jpeg'
                          : 'assets/images/robot.jpg.png',
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, e, t) => Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.cleanoovGreen.withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _methode == 'brosse' ? Icons.brush : Icons.smart_toy_outlined,
                          color: AppColors.cleanoovGreen, size: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Méthode sélectionnée',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        _methode == 'brosse'
                            ? 'Brosse Manuelle'
                            : 'Robot Automatique Cleanoov',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.cleanoovGreen,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.check_circle,
                      color: AppColors.cleanoovGreen, size: 22),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Produit & durée ────────────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextFormField(
                    controller: _produit,
                    decoration: const InputDecoration(
                      labelText: 'Produit utilisé',
                      prefixIcon: Icon(Icons.science_outlined),
                      hintText: 'Ex: Eau déminéralisée, savon neutre...',
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _duree,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[0-9.]'))
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Durée par jour',
                      prefixIcon: Icon(Icons.timer_outlined),
                      suffixText: 'heures',
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return null;
                      final d = double.tryParse(v);
                      if (d == null || d < 0 || d > 24) {
                        return 'Valeur entre 0 et 24h';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Suivant — Après Nettoyage'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ── Widget carte image méthode ──────────────────────────────────────────────
class _ImageMethodCard extends StatelessWidget {
  final String value;
  final String label;
  final String imagePath;
  final IconData icon;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  const _ImageMethodCard({
    required this.value,
    required this.label,
    required this.imagePath,
    required this.icon,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColors.cleanoovGreen
                : AppColors.border,
            width: selected ? 2.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.cleanoovGreen.withAlpha(60),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha(12),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Image principale ──────────────────────────────────
              Stack(
                children: [
                  Container(
                    height: 170,
                    width: double.infinity,
                    color: const Color(0xFFF8F9FA),
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (ctx, e, t) => Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(icon,
                              size: 44,
                              color: AppColors.cleanoovGreen),
                          const SizedBox(height: 6),
                          Text(
                            label,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.cleanoovGreen,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Overlay sélectionné
                  if (selected)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppColors.cleanoovGreen.withAlpha(100),
                            ],
                          ),
                        ),
                      ),
                    ),
                  // Badge checkmark
                  if (selected)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.cleanoovGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check,
                            color: Colors.white, size: 14),
                      ),
                    ),
                  // Badge méthode en bas de l'image
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(160),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // ── Description ───────────────────────────────────────
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 10),
                color: selected
                    ? AppColors.cleanoovGreen.withAlpha(15)
                    : Colors.white,
                child: Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
                    color: selected
                        ? AppColors.cleanoovGreen
                        : AppColors.textSecondary,
                    fontWeight: selected
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
