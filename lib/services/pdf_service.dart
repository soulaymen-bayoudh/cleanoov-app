import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/intervention_model.dart';

class PdfService {
  static final PdfColor _navy    = PdfColor.fromHex('1B3A6B');
  static final PdfColor _green   = PdfColor.fromHex('2E7D32');
  static final PdfColor _red     = PdfColor.fromHex('C62828');
  static final PdfColor _border  = PdfColor.fromHex('E0E7EF');
  static final PdfColor _textGrey = PdfColor.fromHex('6B7280');

  static Future<void> generateAndShare(InterventionModel m) async {
    final photoAvant = m.photosAvant.isNotEmpty
        ? await _safeLoadImage(m.photosAvant.first) : null;
    final photoApres = m.photosApres.isNotEmpty
        ? await _safeLoadImage(m.photosApres.first) : null;

    // Charger le logo depuis les assets
    pw.ImageProvider? logo;
    try {
      final data = await rootBundle.load('assets/images/logo.png');
      logo = pw.MemoryImage(data.buffer.asUint8List());
    } catch (_) {
      logo = null;
    }

    final pdf = pw.Document();
    final fmt = DateFormat('dd/MM/yyyy');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        header: (ctx) => _header(ctx, m, logo),
        footer: (ctx) => _footer(ctx),
        build: (ctx) => [
          _sectionClientInfo(m, fmt),
          pw.SizedBox(height: 12),
          _sectionAvant(m),
          pw.SizedBox(height: 12),
          _sectionNettoyage(m),
          pw.SizedBox(height: 12),
          _sectionApres(m),
          if (photoAvant != null || photoApres != null) ...[
            pw.SizedBox(height: 12),
            _sectionPhotos(photoAvant, photoApres),
          ],
          pw.SizedBox(height: 12),
          _sectionValidation(m, fmt),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: '${m.numeroFiche}.pdf',
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────
  static pw.Widget _header(pw.Context ctx, InterventionModel m,
      pw.ImageProvider? logo) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (logo != null)
                  pw.Image(logo, height: 40, fit: pw.BoxFit.contain)
                else
                  pw.RichText(
                    text: pw.TextSpan(
                      children: [
                        pw.TextSpan(text: 'CLE',
                            style: pw.TextStyle(fontSize: 22,
                                fontWeight: pw.FontWeight.bold, color: _navy)),
                        pw.TextSpan(text: 'A',
                            style: pw.TextStyle(fontSize: 22,
                                fontWeight: pw.FontWeight.bold, color: _green)),
                        pw.TextSpan(text: 'NOOV',
                            style: pw.TextStyle(fontSize: 22,
                                fontWeight: pw.FontWeight.bold, color: _navy)),
                      ],
                    ),
                  ),
                pw.SizedBox(height: 2),
                pw.Text(
                  '+216 27 773 723  |  cleanoov@gmail.com  |  Avenue Mourouj, Mahdia',
                  style: pw.TextStyle(fontSize: 8, color: _textGrey),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('FICHE DE DIAGNOSTIC PANNEAUX PV',
                    style: pw.TextStyle(fontSize: 12,
                        fontWeight: pw.FontWeight.bold, color: _navy)),
                pw.SizedBox(height: 2),
                pw.Text('N° ${m.numeroFiche}',
                    style: pw.TextStyle(fontSize: 9, color: _textGrey)),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 6),
        pw.Divider(color: _green, thickness: 1.5),
        pw.SizedBox(height: 8),
      ],
    );
  }

  static pw.Widget _footer(pw.Context ctx) {
    return pw.Column(
      children: [
        pw.Divider(color: _border),
        pw.SizedBox(height: 4),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('CLEANOOV — Diagnostic Panneaux PV',
                style: pw.TextStyle(fontSize: 7, color: _textGrey)),
            pw.Text('Page ${ctx.pageNumber} / ${ctx.pagesCount}',
                style: pw.TextStyle(fontSize: 7, color: _textGrey)),
          ],
        ),
      ],
    );
  }

  // ── Section 1 : Client ──────────────────────────────────────────────────
  static pw.Widget _sectionClientInfo(InterventionModel m, DateFormat fmt) {
    return pw.Column(
      children: [
        _sectionTitle('INFORMATIONS CLIENT & INSTALLATION', _navy),
        pw.SizedBox(height: 6),
        pw.Table(
          border: pw.TableBorder.all(color: _border),
          children: [
            pw.TableRow(children: [
              _cell('Nom / Prénom', m.nomPrenom, flex: 2),
              _cell('Téléphone', m.telephone, flex: 1),
            ]),
            pw.TableRow(children: [
              _cellFull('Adresse de l\'installation', m.adresse),
            ]),
            pw.TableRow(children: [
              _cell('Puissance installée (kWc)', '${m.puissanceInstallee}'),
              _cell('Nombre de panneaux', '${m.nombrePanneaux}'),
              _cell('Date d\'intervention', fmt.format(m.dateIntervention)),
              _cell('Prochaine intervention',
                  m.prochaineIntervention != null
                      ? fmt.format(m.prochaineIntervention!) : '—'),
            ]),
            pw.TableRow(children: [
              _cellFull('Technicien Cleanoov', m.technicien),
            ]),
          ],
        ),
      ],
    );
  }

  // ── Section 2 : Avant ───────────────────────────────────────────────────
  static pw.Widget _sectionAvant(InterventionModel m) {
    return pw.Column(
      children: [
        _sectionTitle('AVANT NETTOYAGE', _red),
        pw.SizedBox(height: 6),
        pw.Table(
          border: pw.TableBorder.all(color: _border),
          children: [
            pw.TableRow(children: [
              _cell('Puissance mesurée (W)',
                  m.puissanceAvant != null ? '${m.puissanceAvant} W' : '—'),
              _cell('Niveau d\'encrassement', _encLabel(m.niveauEncrassement)),
              _cell('Points chauds (hot-spots)',
                  m.pointsChaudes ? 'Présent — Nb: ${m.nbPointsChaudes}' : 'Absent'),
            ]),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Text('État visuel des panneaux :',
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold,
                color: _red)),
        pw.SizedBox(height: 3),
        pw.Table(
          border: pw.TableBorder.all(color: _border),
          children: [
            pw.TableRow(children: [
              _cell('Fissures / Micro-cracks',
                  m.fissures ? 'Oui — Nb: ${m.nbFissures}' : 'Non'),
              _cell('Coffret AC', _okLabel(m.coffretAC)),
              _cell('Onduleur', _okLabel(m.onduleur)),
              _cell('Visserie / Boulonnerie', _visserieLabel(m.visserie)),
            ]),
            pw.TableRow(children: [
              _cell('Câbles / Connecteurs MC4', _okLabel(m.cablesConnecteurs)),
              _cell('Coffret DC', _okLabel(m.coffretDC)),
              _cell('Structure / Ancrages', _okLabel(m.structureAncrages)),
              _cell('Ombrage partiel', m.ombragePartiel ? 'Présent' : 'Absent'),
            ]),
          ],
        ),
        if (m.observationsAvant.isNotEmpty) ...[
          pw.SizedBox(height: 4),
          _obsBox('Observations AVANT', m.observationsAvant),
        ],
      ],
    );
  }

  // ── Section 3 : Nettoyage ───────────────────────────────────────────────
  static pw.Widget _sectionNettoyage(InterventionModel m) {
    return pw.Column(
      children: [
        _sectionTitle('NETTOYAGE EFFECTUÉ', _green),
        pw.SizedBox(height: 6),
        pw.Table(
          border: pw.TableBorder.all(color: _border),
          children: [
            pw.TableRow(children: [
              _cell('Méthode de nettoyage',
                  m.methodeNettoyage == 'brosse'
                      ? 'Brosse manuelle' : 'Robot automatique'),
              _cell('Produit utilisé',
                  m.produitUtilise.isEmpty ? '—' : m.produitUtilise),
              _cell('Durée par jour (h)',
                  m.dureeParJour > 0 ? '${m.dureeParJour} h' : '—'),
            ]),
          ],
        ),
      ],
    );
  }

  // ── Section 4 : Après ───────────────────────────────────────────────────
  static pw.Widget _sectionApres(InterventionModel m) {
    double? gain;
    if (m.puissanceAvant != null && m.puissanceAvant! > 0 &&
        m.puissanceApres != null && m.puissanceApres! > 0) {
      gain = ((m.puissanceApres! - m.puissanceAvant!) / m.puissanceAvant!) * 100;
    }

    return pw.Column(
      children: [
        _sectionTitle('APRÈS NETTOYAGE', _navy),
        pw.SizedBox(height: 6),
        pw.Table(
          border: pw.TableBorder.all(color: _border),
          children: [
            pw.TableRow(children: [
              _cell('Puissance mesurée après (W)',
                m.puissanceApres != null
                    ? '${m.puissanceApres} W${gain != null ? '  (${gain >= 0 ? '+' : ''}${gain.toStringAsFixed(1)}%)' : ''}'
                    : '—'),
              _cell('Points chauds traités', _ptLabel(m.pointsChaudsTraites)),
            ]),
            pw.TableRow(children: [
              _cell('État général après nettoyage', _etatLabel(m.etatGeneral)),
              _cell('Recommandation', _recoLabel(m.recommandation)),
            ]),
          ],
        ),
        if (m.observationsApres.isNotEmpty) ...[
          pw.SizedBox(height: 4),
          _obsBox('Observations APRÈS', m.observationsApres),
        ],
      ],
    );
  }

  // ── Section 5 : Photos ──────────────────────────────────────────────────
  static pw.Widget _sectionPhotos(
      pw.ImageProvider? avant, pw.ImageProvider? apres) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('PHOTOS DE L\'INTERVENTION',
            PdfColor.fromHex('4A5568')),
        pw.SizedBox(height: 6),
        pw.Table(
          columnWidths: avant != null && apres != null
              ? {
                  0: const pw.FlexColumnWidth(),
                  1: const pw.FixedColumnWidth(10),
                  2: const pw.FlexColumnWidth(),
                }
              : {0: const pw.FlexColumnWidth()},
          children: [
            pw.TableRow(children: [
              if (avant != null) _photoCard('AVANT NETTOYAGE', avant, _red),
              if (avant != null && apres != null) pw.SizedBox(),
              if (apres != null) _photoCard('APRÈS NETTOYAGE', apres, _green),
            ]),
          ],
        ),
      ],
    );
  }

  static pw.Widget _photoCard(
      String label, pw.ImageProvider img, PdfColor accent) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: accent, width: 1.5),
      ),
      child: pw.Column(
        children: [
          pw.Container(
            color: accent,
            padding: const pw.EdgeInsets.symmetric(vertical: 5),
            child: pw.Center(
              child: pw.Text(label,
                  style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold)),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Image(img, height: 140, fit: pw.BoxFit.contain),
          ),
        ],
      ),
    );
  }

  // ── Section 6 : Validation ──────────────────────────────────────────────
  static pw.Widget _sectionValidation(InterventionModel m, DateFormat fmt) {
    return pw.Column(
      children: [
        // Prix
        if (m.prixMission > 0) ...[
          _sectionTitle('FACTURATION', _green),
          pw.SizedBox(height: 6),
          pw.Table(
            border: pw.TableBorder.all(color: _border),
            children: [
              pw.TableRow(children: [
                _cell('Prestation', 'Nettoyage panneaux photovoltaïques'),
                _cell('Technicien', m.technicien),
                _cell('Date', fmt.format(m.dateIntervention)),
                _cell('TOTAL (TND)',
                    '${m.prixMission.toStringAsFixed(3)} TND'),
              ]),
            ],
          ),
          pw.SizedBox(height: 12),
        ],
        // Signatures
        _sectionTitle('VALIDATION', _navy),
        pw.SizedBox(height: 6),
        pw.Table(
          border: pw.TableBorder.all(color: _border),
          columnWidths: {
            0: const pw.FlexColumnWidth(1),
            1: const pw.FlexColumnWidth(1),
            2: const pw.FlexColumnWidth(1),
          },
          children: [
            pw.TableRow(children: [
              _labelCell('Technicien Cleanoov'),
              _labelCell('Signature Client'),
              _labelCell('Copies'),
            ]),
            pw.TableRow(children: [
              _valueCell(m.technicien),
              _valueCell(''),
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('☑ Remise au client',
                        style: pw.TextStyle(fontSize: 8)),
                    pw.Text('☑ Archivée Cleanoov',
                        style: pw.TextStyle(fontSize: 8)),
                    pw.SizedBox(height: 6),
                    pw.Text(
                        'Lu et approuvé : ${m.luEtApprouve ? '☑' : '☐'}',
                        style: pw.TextStyle(fontSize: 8)),
                    pw.Text('Date : ${fmt.format(m.dateIntervention)}',
                        style: pw.TextStyle(fontSize: 8)),
                  ],
                ),
              ),
            ]),
          ],
        ),
      ],
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────
  static pw.Widget _sectionTitle(String title, PdfColor color) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: pw.BoxDecoration(color: color),
      child: pw.Text(title,
          style: pw.TextStyle(color: PdfColors.white, fontSize: 10,
              fontWeight: pw.FontWeight.bold, letterSpacing: 1)),
    );
  }

  static pw.Widget _cell(String label, String value, {int flex = 1}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(7),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label,
              style: pw.TextStyle(fontSize: 7,
                  color: PdfColor.fromHex('1B3A6B'),
                  fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 3),
          pw.Text(value.isNotEmpty ? value : '—',
              style: pw.TextStyle(fontSize: 9, color: PdfColors.black)),
        ],
      ),
    );
  }

  static pw.Widget _cellFull(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(7),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label,
              style: pw.TextStyle(fontSize: 7,
                  color: PdfColor.fromHex('1B3A6B'),
                  fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 3),
          pw.Text(value.isNotEmpty ? value : '—',
              style: pw.TextStyle(fontSize: 9, color: PdfColors.black)),
        ],
      ),
    );
  }

  static pw.Widget _labelCell(String label) {
    return pw.Container(
      color: PdfColor.fromHex('E8EEF7'),
      padding: const pw.EdgeInsets.all(7),
      child: pw.Text(label,
          style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('1B3A6B'))),
    );
  }

  static pw.Widget _valueCell(String value) {
    return pw.Container(
      height: 50,
      padding: const pw.EdgeInsets.all(7),
      child: pw.Text(value, style: pw.TextStyle(fontSize: 9)),
    );
  }

  static pw.Widget _obsBox(String label, String text) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColor.fromHex('E0E7EF')),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label,
              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('6B7280'))),
          pw.SizedBox(height: 4),
          pw.Text(text, style: pw.TextStyle(fontSize: 9)),
        ],
      ),
    );
  }

  // ── Chargement image sécurisé ────────────────────────────────────────────
  static Future<pw.ImageProvider?> _safeLoadImage(String path) async {
    try {
      if (path.isEmpty) return null;
      final Uint8List bytes;
      if (kIsWeb) {
        bytes = await XFile(path).readAsBytes();
      } else {
        bytes = await File(path).readAsBytes();
      }
      if (bytes.isEmpty) return null;
      return pw.MemoryImage(bytes);
    } catch (_) {
      return null;
    }
  }

  // ── Labels ───────────────────────────────────────────────────────────────
  static String _encLabel(String v) {
    switch (v) {
      case 'leger': return 'Léger';
      case 'moyen': return 'Moyen';
      case 'severe': return 'Sévère';
      default: return v.isNotEmpty ? v : '—';
    }
  }

  static String _okLabel(String v) =>
      v == 'ok' ? 'OK' : v == 'anomalie' ? 'Anomalie' : v.isNotEmpty ? v : '—';

  static String _visserieLabel(String v) {
    switch (v) {
      case 'ok': return 'OK';
      case 'desserree': return 'Desserrée';
      case 'manquante': return 'Manquante';
      default: return v.isNotEmpty ? v : '—';
    }
  }

  static String _ptLabel(String v) {
    switch (v) {
      case 'resolus': return 'Résolus';
      case 'persistants': return 'Persistants';
      case 'na': return 'N/A';
      default: return v.isNotEmpty ? v : '—';
    }
  }

  static String _etatLabel(String v) {
    switch (v) {
      case 'excellent': return 'Excellent';
      case 'bon': return 'Bon';
      case 'moyen': return 'Moyen';
      case 'necessite_suivi': return 'Nécessite suivi';
      default: return v.isNotEmpty ? v : '—';
    }
  }

  static String _recoLabel(String v) {
    switch (v) {
      case 'aucune': return 'Aucune';
      case 'devis_complementaire': return 'Devis complémentaire';
      case 'contacter_steg': return 'Contacter STEG';
      default: return v.isNotEmpty ? v : '—';
    }
  }
}
