import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../models/intervention_model.dart';
import '../../widgets/section_header.dart';

class Step1ClientInfo extends StatefulWidget {
  final InterventionModel intervention;
  final void Function(InterventionModel) onNext;

  const Step1ClientInfo({
    super.key,
    required this.intervention,
    required this.onNext,
  });

  @override
  State<Step1ClientInfo> createState() => _Step1ClientInfoState();
}

class _Step1ClientInfoState extends State<Step1ClientInfo> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nom;
  late final TextEditingController _tel;
  late final TextEditingController _adresse;
  late final TextEditingController _puissance;
  late final TextEditingController _nbPanneaux;
  late final TextEditingController _technicien;
  late DateTime _dateIntervention;
  DateTime? _prochaineIntervention;

  @override
  void initState() {
    super.initState();
    final m = widget.intervention;
    _nom = TextEditingController(text: m.nomPrenom);
    _tel = TextEditingController(text: m.telephone);
    _adresse = TextEditingController(text: m.adresse);
    _puissance = TextEditingController(
        text: m.puissanceInstallee > 0 ? m.puissanceInstallee.toString() : '');
    _nbPanneaux = TextEditingController(
        text: m.nombrePanneaux > 0 ? m.nombrePanneaux.toString() : '');
    _technicien = TextEditingController(text: m.technicien);
    _dateIntervention = m.dateIntervention;
    _prochaineIntervention = m.prochaineIntervention;
  }

  @override
  void dispose() {
    _nom.dispose(); _tel.dispose(); _adresse.dispose();
    _puissance.dispose(); _nbPanneaux.dispose(); _technicien.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isProchaine}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isProchaine
          ? (_prochaineIntervention ?? DateTime.now().add(const Duration(days: 180)))
          : _dateIntervention,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isProchaine) {
          _prochaineIntervention = picked;
        } else {
          _dateIntervention = picked;
        }
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final updated = widget.intervention
      ..nomPrenom = _nom.text.trim()
      ..telephone = _tel.text.trim()
      ..adresse = _adresse.text.trim()
      ..puissanceInstallee = double.tryParse(_puissance.text) ?? 0
      ..nombrePanneaux = int.tryParse(_nbPanneaux.text) ?? 0
      ..dateIntervention = _dateIntervention
      ..prochaineIntervention = _prochaineIntervention
      ..technicien = _technicien.text.trim();
    widget.onNext(updated);
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy');
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const SectionHeader(
              title: 'INFORMATIONS CLIENT & INSTALLATION',
              color: AppColors.primary,
              icon: Icons.person,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _field(_nom, 'Nom / Prénom', Icons.person_outline,
                        caps: TextCapitalization.words,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Champ requis';
                          if (v.trim().length < 2) return 'Minimum 2 caractères';
                          return null;
                        }),
                    const SizedBox(height: 12),
                    _field(_tel, 'Téléphone', Icons.phone_outlined,
                        keyboard: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(8),
                        ],
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Champ requis';
                          if (v.trim().length != 8) return 'Le numéro doit contenir exactement 8 chiffres';
                          return null;
                        }),
                    const SizedBox(height: 12),
                    _field(_adresse, 'Adresse de l\'installation',
                        Icons.location_on_outlined,
                        maxLines: 2,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Champ requis';
                          if (v.trim().length < 5) return 'Adresse trop courte';
                          return null;
                        }),
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
                    Row(
                      children: [
                        Expanded(
                          child: _field(
                            _puissance, 'Puissance (kWc)',
                            Icons.bolt_outlined,
                            keyboard: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                            ],
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Champ requis';
                              final d = double.tryParse(v);
                              if (d == null || d <= 0) return 'Valeur invalide';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _field(
                            _nbPanneaux, 'Nb panneaux',
                            Icons.grid_view,
                            keyboard: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Champ requis';
                              final n = int.tryParse(v);
                              if (n == null || n <= 0) return 'Min 1 panneau';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _datePicker(
                            label: 'Date intervention',
                            value: fmt.format(_dateIntervention),
                            onTap: () => _pickDate(isProchaine: false),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _datePicker(
                            label: 'Prochaine intervention',
                            value: _prochaineIntervention != null
                                ? fmt.format(_prochaineIntervention!)
                                : 'Choisir',
                            onTap: () => _pickDate(isProchaine: true),
                            optional: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _field(_technicien, 'Technicien Cleanoov',
                        Icons.engineering_outlined,
                        caps: TextCapitalization.words,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Champ requis';
                          if (v.trim().length < 2) return 'Minimum 2 caractères';
                          return null;
                        }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary.withAlpha(50)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.tag, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'N° ${widget.intervention.numeroFiche}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Suivant — Avant Nettoyage'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool required = false,
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
    TextCapitalization caps = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboard,
      maxLines: maxLines,
      textCapitalization: caps,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
      ),
      validator: validator ??
          (required
              ? (v) => v == null || v.trim().isEmpty ? 'Champ requis' : null
              : null),
    );
  }

  Widget _datePicker({
    required String label,
    required String value,
    required VoidCallback onTap,
    bool optional = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today,
                    size: 14, color: AppColors.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: value == 'Choisir'
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
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
