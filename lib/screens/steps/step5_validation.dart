import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../models/intervention_model.dart';
import '../../services/pdf_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/section_header.dart';

class Step5Validation extends StatefulWidget {
  final InterventionModel intervention;
  final VoidCallback onPrev;
  final VoidCallback onFinish;

  const Step5Validation({
    super.key,
    required this.intervention,
    required this.onPrev,
    required this.onFinish,
  });

  @override
  State<Step5Validation> createState() => _Step5ValidationState();
}

class _Step5ValidationState extends State<Step5Validation> {
  bool _luEtApprouve = false;
  bool _generatingPdf = false;
  final _prixCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.intervention.prixMission > 0) {
      _prixCtrl.text = widget.intervention.prixMission.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _prixCtrl.dispose();
    super.dispose();
  }

  double get _prix => double.tryParse(_prixCtrl.text) ?? 0;

  Future<void> _generatePdf() async {
    setState(() => _generatingPdf = true);
    try {
      widget.intervention.luEtApprouve = _luEtApprouve;
      widget.intervention.prixMission = _prix;
      await StorageService.saveIntervention(widget.intervention);
      await PdfService.generateAndShare(widget.intervention);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur PDF: $e'), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _generatingPdf = false);
    }
  }

  Future<void> _finish() async {
    // Vérifier que le prix est renseigné
    if (_prix <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [
            Icon(Icons.warning_amber_outlined, color: Colors.white, size: 18),
            SizedBox(width: 10),
            Text('Veuillez saisir le prix de la mission'),
          ]),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    // Confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.cleanoovGreen),
            SizedBox(width: 10),
            Text('Terminer la mission'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cette intervention sera enregistrée dans l\'espace admin.',
              style: TextStyle(fontSize: 14),
            ),
            if (_prix > 0) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Prix: ', style: TextStyle(color: AppColors.textSecondary)),
                  Text(
                    '${_prix.toStringAsFixed(2)} TND',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.cleanoovGreen,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cleanoovGreen,
              minimumSize: const Size(0, 40),
            ),
            icon: const Icon(Icons.check, size: 16),
            label: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    widget.intervention.luEtApprouve = _luEtApprouve;
    widget.intervention.prixMission = _prix;
    widget.intervention.termine = true;
    await StorageService.saveIntervention(widget.intervention);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [
            Icon(Icons.check_circle, color: Colors.white, size: 18),
            SizedBox(width: 10),
            Text('Mission terminée et enregistrée !'),
          ]),
          backgroundColor: AppColors.cleanoovGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }

    widget.onFinish();
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.intervention;
    final fmt = DateFormat('dd/MM/yyyy');
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SectionHeader(
            title: 'VALIDATION & RAPPORT',
            color: AppColors.primary,
            icon: Icons.picture_as_pdf,
          ),
          const SizedBox(height: 16),

          // Récap
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Récapitulatif de l\'intervention',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary),
                  ),
                  const SizedBox(height: 12),
                  _recapRow('N° Fiche', m.numeroFiche),
                  _recapRow('Client', m.nomPrenom),
                  _recapRow('Téléphone', m.telephone),
                  _recapRow('Adresse', m.adresse),
                  _recapRow('Date', fmt.format(m.dateIntervention)),
                  _recapRow('Technicien', m.technicien),
                  if (m.technicienTelephone.isNotEmpty)
                    _recapRow('Tél. technicien', m.technicienTelephone),
                  _recapRow(
                      'Panneaux', '${m.nombrePanneaux} (${m.puissanceInstallee} kWc)'),
                  const Divider(height: 20),
                  _recapRow('Encrassement', _encLabel(m.niveauEncrassement)),
                  if (m.puissanceAvant != null)
                    _recapRow('Puissance avant', '${m.puissanceAvant} W'),
                  if (m.puissanceApres != null)
                    _recapRow('Puissance après', '${m.puissanceApres} W'),
                  _recapRow('État général', _etatLabel(m.etatGeneral)),
                  _recapRow('Recommandation', _recoLabel(m.recommandation)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Prix de la mission
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.payments_outlined,
                          color: AppColors.cleanoovGreen, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Facturation',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _prixCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Prix de la mission (TND) *',
                      labelStyle: TextStyle(
                        color: _prix <= 0 ? AppColors.danger : AppColors.textSecondary,
                      ),
                      prefixIcon: Icon(Icons.attach_money,
                          color: _prix > 0 ? AppColors.cleanoovGreen : AppColors.danger,
                          size: 20),
                      suffixText: 'TND',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: _prix <= 0
                              ? AppColors.danger.withAlpha(120)
                              : Colors.grey.shade300,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: _prix > 0 ? AppColors.cleanoovGreen : AppColors.danger,
                          width: 1.5,
                        ),
                      ),
                      helperText: _prix <= 0 ? 'Champ obligatoire' : null,
                      helperStyle: const TextStyle(color: AppColors.danger, fontSize: 11),
                    ),
                  ),
                  if (_prix > 0) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.cleanoovGreen.withAlpha(15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total mission',
                              style: TextStyle(color: AppColors.textSecondary)),
                          Text(
                            '${_prix.toStringAsFixed(2)} TND',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: AppColors.cleanoovGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Signature / Lu et approuvé
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _luEtApprouve,
                        onChanged: (v) =>
                            setState(() => _luEtApprouve = v ?? false),
                        activeColor: AppColors.primary,
                      ),
                      const Expanded(
                        child: Text(
                          'Lu et approuvé — Le client confirme avoir reçu et accepté le rapport d\'intervention.',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Date : ${fmt.format(m.dateIntervention)}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Bouton PDF
          ElevatedButton.icon(
            onPressed: _generatingPdf ? null : _generatePdf,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              minimumSize: const Size(double.infinity, 52),
            ),
            icon: _generatingPdf
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.picture_as_pdf),
            label: Text(_generatingPdf
                ? 'Génération en cours...'
                : 'Générer & Partager le PDF'),
          ),
          const SizedBox(height: 12),

          // Bouton terminer
          ElevatedButton.icon(
            onPressed: _finish,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cleanoovGreen,
              minimumSize: const Size(double.infinity, 52),
            ),
            icon: const Icon(Icons.check_circle_outline),
            label: const Text(
              'Terminer la mission',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _recapRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }

  String _encLabel(String v) {
    switch (v) {
      case 'leger': return 'Léger';
      case 'moyen': return 'Moyen';
      case 'severe': return 'Sévère';
      default: return v;
    }
  }

  String _etatLabel(String v) {
    switch (v) {
      case 'excellent': return 'Excellent';
      case 'bon': return 'Bon';
      case 'moyen': return 'Moyen';
      case 'necessite_suivi': return 'Nécessite suivi';
      default: return v;
    }
  }

  String _recoLabel(String v) {
    switch (v) {
      case 'aucune': return 'Aucune';
      case 'devis_complementaire': return 'Devis complémentaire';
      case 'contacter_steg': return 'Contacter STEG';
      default: return v;
    }
  }
}
