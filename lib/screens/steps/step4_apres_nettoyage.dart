import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme.dart';
import '../../models/intervention_model.dart';
import '../../widgets/section_header.dart';
import '../../widgets/cleanoov_radio_group.dart';

class Step4ApresNettoyage extends StatefulWidget {
  final InterventionModel intervention;
  final void Function(InterventionModel) onNext;
  final VoidCallback onPrev;

  const Step4ApresNettoyage({
    super.key,
    required this.intervention,
    required this.onNext,
    required this.onPrev,
  });

  @override
  State<Step4ApresNettoyage> createState() => _Step4ApresNettoyageState();
}

class _Step4ApresNettoyageState extends State<Step4ApresNettoyage> {
  late final TextEditingController _puissance;
  late final TextEditingController _observations;
  late String _pointsTraites;
  late String _etatGeneral;
  late String _recommandation;
  late List<String> _photos;

  @override
  void initState() {
    super.initState();
    final m = widget.intervention;
    _puissance = TextEditingController(
        text: m.puissanceApres != null ? m.puissanceApres.toString() : '');
    _observations = TextEditingController(text: m.observationsApres);
    _pointsTraites = m.pointsChaudsTraites;
    _etatGeneral = m.etatGeneral;
    _recommandation = m.recommandation;
    _photos = List.from(m.photosApres);
  }

  @override
  void dispose() {
    _puissance.dispose();
    _observations.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('Prendre une photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('Choisir depuis la galerie'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (source == null) return;
    try {
      final xfile = await ImagePicker().pickImage(
          source: source, imageQuality: 80);
      if (xfile != null && mounted) {
        setState(() => _photos.add(xfile.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Impossible d\'accéder à la caméra: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  void _submit() {
    final updated = widget.intervention
      ..puissanceApres = double.tryParse(_puissance.text)
      ..pointsChaudsTraites = _pointsTraites
      ..etatGeneral = _etatGeneral
      ..recommandation = _recommandation
      ..observationsApres = _observations.text.trim()
      ..photosApres = _photos;
    widget.onNext(updated);
  }

  @override
  Widget build(BuildContext context) {
    final avant = widget.intervention.puissanceAvant;
    final apres = double.tryParse(_puissance.text);
    double? gain;
    if (avant != null && avant > 0 && apres != null && apres > 0) {
      gain = ((apres - avant) / avant) * 100;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SectionHeader(
            title: 'APRÈS NETTOYAGE',
            color: AppColors.sectionAfter,
            icon: Icons.check_circle_outline,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextFormField(
                    controller: _puissance,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                    ],
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Puissance mesurée après (W)',
                      prefixIcon: Icon(Icons.bolt_outlined),
                    ),
                  ),

                  // Gain de puissance
                  if (gain != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: gain >= 0
                            ? AppColors.accent.withAlpha(20)
                            : AppColors.danger.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            gain >= 0
                                ? Icons.trending_up
                                : Icons.trending_down,
                            color: gain >= 0
                                ? AppColors.accent
                                : AppColors.danger,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Gain de puissance : ${gain >= 0 ? '+' : ''}${gain.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: gain >= 0
                                  ? AppColors.accent
                                  : AppColors.danger,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  CleanoovRadioGroup(
                    label: 'Points chauds traités',
                    value: _pointsTraites,
                    onChanged: (v) => setState(() => _pointsTraites = v),
                    options: const [
                      RadioOption('resolus', 'Résolus'),
                      RadioOption('persistants', 'Persistants'),
                      RadioOption('na', 'N/A'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CleanoovRadioGroup(
                    label: 'État général après nettoyage',
                    value: _etatGeneral,
                    onChanged: (v) => setState(() => _etatGeneral = v),
                    options: const [
                      RadioOption('excellent', 'Excellent'),
                      RadioOption('bon', 'Bon'),
                      RadioOption('moyen', 'Moyen'),
                      RadioOption('necessite_suivi', 'Nécessite suivi'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CleanoovRadioGroup(
                    label: 'Recommandation',
                    value: _recommandation,
                    onChanged: (v) => setState(() => _recommandation = v),
                    options: const [
                      RadioOption('aucune', 'Aucune'),
                      RadioOption('devis_complementaire', 'Devis complémentaire'),
                      RadioOption('contacter_steg', 'Contacter STEG'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextFormField(
                    controller: _observations,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Observations APRÈS',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _photoSection(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Suivant — Validation'),
          ),
        ],
      ),
    );
  }

  Widget _photoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Photos APRÈS',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary)),
            TextButton.icon(
              onPressed: _pickPhoto,
              icon: const Icon(Icons.camera_alt, size: 16),
              label: const Text('Ajouter'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ],
        ),
        if (_photos.isNotEmpty)
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _photos.length,
              itemBuilder: (ctx, i) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: kIsWeb
                          ? Image.network(_photos[i],
                              width: 80, height: 80, fit: BoxFit.cover,
                              errorBuilder: (ctx, err, trace) => Container(
                                width: 80, height: 80,
                                color: AppColors.border,
                                child: const Icon(Icons.image,
                                    color: AppColors.textSecondary),
                              ))
                          : Image.file(File(_photos[i]),
                              width: 80, height: 80, fit: BoxFit.cover,
                              errorBuilder: (ctx, err, trace) => Container(
                                width: 80, height: 80,
                                color: AppColors.border,
                                child: const Icon(Icons.image,
                                    color: AppColors.textSecondary),
                              )),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: GestureDetector(
                        onTap: () => setState(() => _photos.removeAt(i)),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: AppColors.danger,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close,
                              size: 12, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
