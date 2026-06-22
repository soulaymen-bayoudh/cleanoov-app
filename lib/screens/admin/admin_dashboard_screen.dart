import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../models/intervention_model.dart';
import '../../services/pdf_service.dart';
import '../../services/storage_service.dart';
import '../login_screen.dart';
import '../intervention_flow.dart';
import '../../services/auth_service.dart';

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
    _filtered = _all.where((m) =>
      m.technicien.toLowerCase().contains(q) ||
      m.nomPrenom.toLowerCase().contains(q) ||
      m.numeroFiche.toLowerCase().contains(q)
    ).toList()
      ..sort((a, b) => b.dateIntervention.compareTo(a.dateIntervention));
  }

  double get _totalRevenu => _all.fold(0, (s, m) => s + m.prixMission);
  int get _nbTerminees => _all.where((m) => m.termine).length;

  Future<void> _openIntervention(InterventionModel m) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InterventionFlow(
          technicien: m.technicien,
          technicienTel: m.technicienTelephone,
          existing: m,
          fromAdmin: true,
        ),
      ),
    );
    _load();
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Déconnexion Admin'),
        content: const Text('Voulez-vous quitter l\'espace admin ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger,
                minimumSize: const Size(0, 38)),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await AuthService.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy', 'fr');
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      body: Column(
        children: [
          _buildHeader(),
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              onChanged: (v) => setState(() { _search = v; _applyFilter(); }),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Rechercher client, technicien, N° fiche...',
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: Colors.white38),
                filled: true,
                fillColor: Colors.white.withAlpha(10),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withAlpha(20)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withAlpha(20)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.cleanoovGreen),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${_filtered.length} mission${_filtered.length != 1 ? 's' : ''}',
                    style: const TextStyle(color: Colors.white54, fontSize: 12)),
                Text('Total : ${_totalRevenu.toStringAsFixed(2)} TND',
                    style: const TextStyle(color: Colors.amber,
                        fontSize: 13, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.cleanoovGreen))
                : _filtered.isEmpty
                    ? _buildEmpty()
                    : RefreshIndicator(
                        onRefresh: _load,
                        color: AppColors.cleanoovGreen,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                          itemCount: _filtered.length,
                          itemBuilder: (_, i) => _buildCard(_filtered[i], fmt),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

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
            // Top row — logo + logout
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                children: [
                  Image.asset('assets/images/logo_dark.png', height: 30,
                      errorBuilder: (ctx, err, st) => const Text('CLEANOOV',
                          style: TextStyle(color: Colors.white,
                              fontWeight: FontWeight.w900, fontSize: 16))),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.amber.withAlpha(30),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.amber.withAlpha(60)),
                    ),
                    child: const Text('ADMIN',
                        style: TextStyle(color: Colors.amber,
                            fontSize: 10, fontWeight: FontWeight.w800)),
                  ),
                  const Spacer(),
                  // Bouton refresh
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white54, size: 22),
                    onPressed: _load,
                    tooltip: 'Actualiser',
                  ),
                  const SizedBox(width: 4),
                  // Bouton déconnexion — grand et visible
                  ElevatedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout, size: 16),
                    label: const Text('Quitter', style: TextStyle(fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.danger,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),

            // KPI cards
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Row(
                children: [
                  _kpi('${_all.length}', 'Total', Icons.solar_power,
                      AppColors.cleanoovGreen),
                  const SizedBox(width: 10),
                  _kpi('$_nbTerminees', 'Terminées',
                      Icons.check_circle_outline, Colors.blue),
                  const SizedBox(width: 10),
                  _kpi('${_totalRevenu.toStringAsFixed(0)} TND', 'Revenu',
                      Icons.payments_outlined, Colors.amber),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kpi(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(40)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(color: color, fontSize: 15,
                    fontWeight: FontWeight.w800)),
            Text(label,
                style: const TextStyle(color: Colors.white38, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(InterventionModel m, DateFormat fmt) {
    final statusColor = m.termine ? AppColors.cleanoovGreen : Colors.orange;
    return InkWell(
      onTap: () => _openIntervention(m),
      borderRadius: BorderRadius.circular(14),
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withAlpha(15)),
      ),
      child: Column(
        children: [
          // Barre colorée en haut
          Container(
            height: 3,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                // Ligne 1 — N° fiche + statut
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(m.numeroFiche,
                        style: const TextStyle(
                            color: AppColors.cleanoovGreenLight,
                            fontSize: 13,
                            fontWeight: FontWeight.w700)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: statusColor.withAlpha(60)),
                      ),
                      child: Text(m.termine ? '✓ Terminée' : '⏳ En cours',
                          style: TextStyle(color: statusColor,
                              fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(color: Color(0xFF2D3748), height: 1),
                const SizedBox(height: 10),

                // Ligne 2 — Infos
                Row(
                  children: [
                    Expanded(
                      child: _infoLine(
                          Icons.person_outline, 'Client', m.nomPrenom),
                    ),
                    Expanded(
                      child: _infoLine(
                          Icons.engineering, 'Technicien', m.technicien),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _infoLine(Icons.calendar_today,
                          'Date', fmt.format(m.dateIntervention)),
                    ),
                    Expanded(
                      child: _infoLine(
                        Icons.payments_outlined,
                        'Prix',
                        m.prixMission > 0
                            ? '${m.prixMission.toStringAsFixed(2)} TND'
                            : '—',
                        valueColor: m.prixMission > 0
                            ? Colors.amber : Colors.white38,
                      ),
                    ),
                  ],
                ),
                if (m.technicienTelephone.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _infoLine(Icons.phone_outlined, 'Tél. Technicien',
                      m.technicienTelephone),
                ],
                const SizedBox(height: 12),

                // Bouton PDF — pleine largeur, facile à tapper
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _generatePdf(m),
                    icon: const Icon(Icons.picture_as_pdf, size: 18),
                    label: const Text('Générer le Rapport PDF',
                        style: TextStyle(fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.danger,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 44),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _infoLine(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 13, color: Colors.white38),
        const SizedBox(width: 5),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: Colors.white38, fontSize: 10)),
              Text(value,
                  style: TextStyle(
                      color: valueColor ?? Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _generatePdf(InterventionModel m) async {
    try {
      await PdfService.generateAndShare(m);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur PDF: $e'),
              backgroundColor: AppColors.danger),
        );
      }
    }
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64,
              color: Colors.white.withAlpha(30)),
          const SizedBox(height: 16),
          Text(
            _search.isEmpty
                ? 'Aucune intervention enregistrée'
                : 'Aucun résultat pour "$_search"',
            style: const TextStyle(color: Colors.white38, fontSize: 15),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
