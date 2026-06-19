import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme.dart';
import '../../models/intervention_model.dart';
import '../../widgets/section_header.dart';
import '../../widgets/cleanoov_radio_group.dart';

class Step2AvantNettoyage extends StatefulWidget {
  final InterventionModel intervention;
  final void Function(InterventionModel) onNext;
  final VoidCallback onPrev;

  const Step2AvantNettoyage({
    super.key,
    required this.intervention,
    required this.onNext,
    required this.onPrev,
  });

  @override
  State<Step2AvantNettoyage> createState() => _Step2AvantNettoyageState();
}

class _Step2AvantNettoyageState extends State<Step2AvantNettoyage> {
  late final TextEditingController _puissance;
  late final TextEditingController _nbPoints;
  late final TextEditingController _nbFissures;
  late final TextEditingController _observations;

  late String _encrassement;
  late bool _pointsChaudes;
  late bool _fissures;
  late String _coffretAC;
  late String _onduleur;
  late String _visserie;
  late String _cables;
  late String _coffretDC;
  late String _structure;
  late bool _ombrage;
  late List<String> _photos;

  @override
  void initState() {
    super.initState();
    final m = widget.intervention;
    _puissance = TextEditingController(
        text: m.puissanceAvant != null ? m.puissanceAvant.toString() : '');
    _nbPoints = TextEditingController(text: m.nbPointsChaudes.toString());
    _nbFissures = TextEditingController(text: m.nbFissures.toString());
    _observations = TextEditingController(text: m.observationsAvant);
    _encrassement = m.niveauEncrassement;
    _pointsChaudes = m.pointsChaudes;
    _fissures = m.fissures;
    _coffretAC = m.coffretAC;
    _onduleur = m.onduleur;
    _visserie = m.visserie;
    _cables = m.cablesConnecteurs;
    _coffretDC = m.coffretDC;
    _structure = m.structureAncrages;
    _ombrage = m.ombragePartiel;
    _photos = List.from(m.photosAvant);
  }

  @override
  void dispose() {
    _puissance.dispose(); _nbPoints.dispose();
    _nbFissures.dispose(); _observations.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    ImageSource? source;

    if (kIsWeb) {
      // Sur web : dialog caméra ou fichier
      source = await showModalBottomSheet<ImageSource>(
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
    } else {
      // Sur mobile : même dialog
      source = await showModalBottomSheet<ImageSource>(
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
    }

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
      ..puissanceAvant = double.tryParse(_puissance.text)
      ..niveauEncrassement = _encrassement
      ..pointsChaudes = _pointsChaudes
      ..nbPointsChaudes = int.tryParse(_nbPoints.text) ?? 0
      ..fissures = _fissures
      ..nbFissures = int.tryParse(_nbFissures.text) ?? 0
      ..coffretAC = _coffretAC
      ..onduleur = _onduleur
      ..visserie = _visserie
      ..cablesConnecteurs = _cables
      ..coffretDC = _coffretDC
      ..structureAncrages = _structure
      ..ombragePartiel = _ombrage
      ..observationsAvant = _observations.text.trim()
      ..photosAvant = _photos;
    widget.onNext(updated);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SectionHeader(
            title: 'AVANT NETTOYAGE',
            color: AppColors.sectionBefore,
            icon: Icons.search,
          ),
          const SizedBox(height: 16),

          // Mesures
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextFormField(
                    controller: _puissance,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                    decoration: const InputDecoration(
                      labelText: 'Puissance mesurée (W)',
                      prefixIcon: Icon(Icons.bolt_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CleanoovRadioGroup(
                    label: 'Niveau d\'encrassement',
                    value: _encrassement,
                    onChanged: (v) => setState(() => _encrassement = v),
                    options: const [
                      RadioOption('leger', 'Léger'),
                      RadioOption('moyen', 'Moyen'),
                      RadioOption('severe', 'Sévère'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _switchTile(
                          'Points chauds (hot-spots)',
                          _pointsChaudes,
                          (v) => setState(() => _pointsChaudes = v),
                        ),
                      ),
                      if (_pointsChaudes) ...[
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 80,
                          child: TextFormField(
                            controller: _nbPoints,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: const InputDecoration(labelText: 'Nb'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // État visuel
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('État visuel des panneaux',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _switchTile('Fissures / Micro-cracks', _fissures,
                            (v) => setState(() => _fissures = v)),
                      ),
                      if (_fissures) ...[
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 80,
                          child: TextFormField(
                            controller: _nbFissures,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: const InputDecoration(labelText: 'Nb'),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const Divider(height: 20),
                  _etatRow('Coffret AC', _coffretAC,
                      (v) => setState(() => _coffretAC = v),
                      options: const [RadioOption('ok', 'OK'), RadioOption('anomalie', 'Anomalie')]),
                  const SizedBox(height: 12),
                  _etatRow('Onduleur', _onduleur,
                      (v) => setState(() => _onduleur = v),
                      options: const [RadioOption('ok', 'OK'), RadioOption('anomalie', 'Anomalie')]),
                  const SizedBox(height: 12),
                  _etatRow('Visserie / Boulonnerie', _visserie,
                      (v) => setState(() => _visserie = v),
                      options: const [
                        RadioOption('ok', 'OK'),
                        RadioOption('desserree', 'Desserrée'),
                        RadioOption('manquante', 'Manquante'),
                      ]),
                  const SizedBox(height: 12),
                  _etatRow('Câbles / Connecteurs MC4', _cables,
                      (v) => setState(() => _cables = v),
                      options: const [RadioOption('ok', 'OK'), RadioOption('anomalie', 'Anomalie')]),
                  const SizedBox(height: 12),
                  _etatRow('Coffret DC', _coffretDC,
                      (v) => setState(() => _coffretDC = v),
                      options: const [RadioOption('ok', 'OK'), RadioOption('anomalie', 'Anomalie')]),
                  const SizedBox(height: 12),
                  _etatRow('Structure / Ancrages', _structure,
                      (v) => setState(() => _structure = v),
                      options: const [RadioOption('ok', 'OK'), RadioOption('anomalie', 'Anomalie')]),
                  const SizedBox(height: 12),
                  _switchTile('Ombrage partiel', _ombrage,
                      (v) => setState(() => _ombrage = v)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Observations & Photos
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _observations,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Observations AVANT',
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
            label: const Text('Suivant — Nettoyage Effectué'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _switchTile(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Expanded(
          child: Text(label,
              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.danger,
        ),
      ],
    );
  }

  Widget _etatRow(String label, String value, ValueChanged<String> onChanged,
      {required List<RadioOption> options}) {
    return CleanoovRadioGroup(
      label: label,
      value: value,
      onChanged: onChanged,
      options: options,
    );
  }

  Widget _photoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Photos AVANT',
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
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _photos.length,
              separatorBuilder: (ctx, i) => const SizedBox(width: 8),
              itemBuilder: (_, i) => Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: kIsWeb
                        ? Image.network(_photos[i],
                            width: 80, height: 80, fit: BoxFit.cover,
                            errorBuilder: (ctx, err, trace) => Container(
                              width: 80, height: 80,
                              color: AppColors.border,
                              child: const Icon(Icons.image, color: AppColors.textSecondary),
                            ))
                        : Image.file(File(_photos[i]),
                            width: 80, height: 80, fit: BoxFit.cover,
                            errorBuilder: (ctx, err, trace) => Container(
                              width: 80, height: 80,
                              color: AppColors.border,
                              child: const Icon(Icons.image, color: AppColors.textSecondary),
                            )),
                  ),
                  Positioned(
                    top: 2, right: 2,
                    child: GestureDetector(
                      onTap: () => setState(() => _photos.removeAt(i)),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: AppColors.danger,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 12, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
