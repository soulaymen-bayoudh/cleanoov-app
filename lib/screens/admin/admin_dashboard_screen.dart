import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../models/intervention_model.dart';
import '../../services/pdf_service.dart';
import '../../services/storage_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  List<InterventionModel> _all = [];
  List<InterventionModel> _filtered = [];
  bool _loading = true;
  String _search = '';
  String _sortField = 'date';
  bool _sortAsc = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await StorageService.loadInterventions();
    if (mounted) {
      setState(() {
        _all = list;
        _applyFilter();
        _loading = false;
      });
    }
  }

  void _applyFilter() {
    final q = _search.toLowerCase();
    _filtered = _all.where((m) {
      return m.technicien.toLowerCase().contains(q) ||
          m.technicienTelephone.contains(q) ||
          m.nomPrenom.toLowerCase().contains(q) ||
          m.numeroFiche.toLowerCase().contains(q);
    }).toList();
    _sortList();
  }

  void _sortList() {
    _filtered.sort((a, b) {
      int cmp;
      switch (_sortField) {
        case 'technicien':
          cmp = a.technicien.compareTo(b.technicien);
          break;
        case 'client':
          cmp = a.nomPrenom.compareTo(b.nomPrenom);
          break;
        case 'prix':
          cmp = a.prixMission.compareTo(b.prixMission);
          break;
        default:
          cmp = a.dateIntervention.compareTo(b.dateIntervention);
      }
      return _sortAsc ? cmp : -cmp;
    });
  }

  void _setSort(String field) {
    setState(() {
      if (_sortField == field) {
        _sortAsc = !_sortAsc;
      } else {
        _sortField = field;
        _sortAsc = false;
      }
      _sortList();
    });
  }

  double get _totalRevenu =>
      _filtered.fold(0, (sum, m) => sum + m.prixMission);

  int get _nbTerminees => _filtered.where((m) => m.termine).length;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy');
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.cleanoovGreen))
                : _filtered.isEmpty
                    ? _buildEmpty()
                    : _buildTable(fmt),
          ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF111827),
        border: Border(bottom: BorderSide(color: Color(0xFF1F2937))),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white54, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Image.asset(
                    'assets/images/logo_dark.png',
                    height: 28,
                    errorBuilder: (ctx, e, t) => const Text(
                      'CLEANOOV',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.amber.withAlpha(30),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.amber.withAlpha(60)),
                    ),
                    child: const Text(
                      'ADMIN',
                      style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.w800),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white54, size: 20),
                    onPressed: _load,
                  ),
                ],
              ),
            ),

            // KPI stats
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  _kpi('${_all.length}', 'Interventions', Icons.solar_power, AppColors.cleanoovGreen),
                  const SizedBox(width: 10),
                  _kpi('$_nbTerminees', 'Terminées', Icons.check_circle_outline, Colors.blue),
                  const SizedBox(width: 10),
                  _kpi(
                    '${_totalRevenu.toStringAsFixed(0)} TND',
                    'Revenu total',
                    Icons.payments_outlined,
                    Colors.amber,
                  ),
                ],
              ),
            ),

            // Barre de recherche
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextField(
                onChanged: (v) => setState(() { _search = v; _applyFilter(); }),
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Rechercher technicien, client, N° fiche...',
                  hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                  prefixIcon: const Icon(Icons.search, color: Colors.white38, size: 18),
                  filled: true,
                  fillColor: Colors.white.withAlpha(10),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.white.withAlpha(15)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.white.withAlpha(15)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.cleanoovGreen),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── KPI Box ───────────────────────────────────────────────────────────────
  Widget _kpi(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withAlpha(40)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w800)),
            Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  // ── Tableau ───────────────────────────────────────────────────────────────
  Widget _buildTable(DateFormat fmt) {
    return Column(
      children: [
        // En-têtes colonnes
        Container(
          color: const Color(0xFF1F2937),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              _headerCell('N° Fiche', flex: 3, field: 'fiche'),
              _headerCell('Technicien', flex: 3, field: 'technicien'),
              _headerCell('Téléphone', flex: 2),
              _headerCell('Client', flex: 3, field: 'client'),
              _headerCell('Date', flex: 2, field: 'date'),
              _headerCell('Prix (TND)', flex: 2, field: 'prix'),
              _headerCell('Statut', flex: 2),
              _headerCell('PDF', flex: 2),
            ],
          ),
        ),
        // Lignes
        Expanded(
          child: RefreshIndicator(
            onRefresh: _load,
            color: AppColors.cleanoovGreen,
            child: ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (ctx, i) => _buildRow(_filtered[i], fmt, i),
            ),
          ),
        ),
        // Pied de tableau — total
        Container(
          color: const Color(0xFF1F2937),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_filtered.length} mission${_filtered.length != 1 ? 's' : ''}',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              Row(
                children: [
                  const Text('Total : ', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  Text(
                    '${_totalRevenu.toStringAsFixed(2)} TND',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _headerCell(String label, {int flex = 1, String? field}) {
    final active = field != null && _sortField == field;
    return Expanded(
      flex: flex,
      child: GestureDetector(
        onTap: field != null ? () => _setSort(field) : null,
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: active ? AppColors.cleanoovGreen : Colors.white38,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (active)
              Icon(
                _sortAsc ? Icons.arrow_upward : Icons.arrow_downward,
                size: 10,
                color: AppColors.cleanoovGreen,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(InterventionModel m, DateFormat fmt, int index) {
    final isEven = index % 2 == 0;
    final statusColor = m.termine ? AppColors.cleanoovGreen : Colors.orange;
    return Container(
      color: isEven ? const Color(0xFF111827) : const Color(0xFF0F1117),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          // N° Fiche
          Expanded(
            flex: 3,
            child: Text(
              m.numeroFiche,
              style: const TextStyle(
                color: AppColors.cleanoovGreenLight,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Technicien
          Expanded(
            flex: 3,
            child: Text(
              m.technicien,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Téléphone
          Expanded(
            flex: 2,
            child: Text(
              m.technicienTelephone.isEmpty ? '—' : m.technicienTelephone,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ),
          // Client
          Expanded(
            flex: 3,
            child: Text(
              m.nomPrenom,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Date
          Expanded(
            flex: 2,
            child: Text(
              fmt.format(m.dateIntervention),
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ),
          // Prix
          Expanded(
            flex: 2,
            child: Text(
              m.prixMission > 0 ? '${m.prixMission.toStringAsFixed(0)} TND' : '—',
              style: TextStyle(
                color: m.prixMission > 0 ? Colors.amber : Colors.white38,
                fontSize: 12,
                fontWeight: m.prixMission > 0 ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
          // Statut
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: statusColor.withAlpha(25),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                m.termine ? 'Terminée' : 'En cours',
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Bouton PDF
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () => _generatePdf(m),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.danger.withAlpha(20),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.danger.withAlpha(60)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.picture_as_pdf, color: AppColors.danger, size: 12),
                    SizedBox(width: 4),
                    Text(
                      'PDF',
                      style: TextStyle(
                        color: AppColors.danger,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generatePdf(InterventionModel m) async {
    try {
      await PdfService.generateAndShare(m);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur PDF: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 60, color: Colors.white.withAlpha(30)),
          const SizedBox(height: 16),
          Text(
            _search.isEmpty ? 'Aucune intervention enregistrée' : 'Aucun résultat',
            style: const TextStyle(color: Colors.white38, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
