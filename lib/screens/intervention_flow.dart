import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../theme/app_theme.dart';
import '../models/intervention_model.dart';
import '../services/storage_service.dart';
import 'steps/step1_client_info.dart';
import 'steps/step2_avant_nettoyage.dart';
import 'steps/step3_nettoyage.dart';
import 'steps/step4_apres_nettoyage.dart';
import 'steps/step5_validation.dart';

class InterventionFlow extends StatefulWidget {
  final String technicien;
  final String technicienTel;
  final InterventionModel? existing;
  final bool fromAdmin;

  const InterventionFlow({
    super.key,
    required this.technicien,
    this.technicienTel = '',
    this.existing,
    this.fromAdmin = false,
  });

  @override
  State<InterventionFlow> createState() => _InterventionFlowState();
}

class _InterventionFlowState extends State<InterventionFlow> {
  int _currentStep = 0;
  late InterventionModel _intervention;

  final List<String> _stepTitles = [
    'Infos Client',
    'Avant Nettoyage',
    'Nettoyage',
    'Après Nettoyage',
    'Validation',
  ];

  final List<IconData> _stepIcons = [
    Icons.person_outline,
    Icons.search,
    Icons.cleaning_services,
    Icons.check_circle_outline,
    Icons.picture_as_pdf,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _intervention = widget.existing!;
    } else {
      _intervention = InterventionModel(
        id: const Uuid().v4(),
        numeroFiche: InterventionModel.generateNumero(),
        nomPrenom: '',
        telephone: '',
        adresse: '',
        puissanceInstallee: 0,
        nombrePanneaux: 0,
        dateIntervention: DateTime.now(),
        technicien: widget.technicien,
        technicienTelephone: widget.technicienTel,
      );
    }
  }

  void _next(InterventionModel updated) async {
    _intervention = updated;
    await StorageService.saveIntervention(_intervention);
    if (_currentStep < 4) {
      setState(() => _currentStep++);
    }
  }

  void _prev() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  void _finish() {
    Navigator.pop(context, true);
  }

  void _goToDashboard() {
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_stepTitles[_currentStep]),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_currentStep > 0) {
              _prev();
            } else {
              Navigator.pop(context, false);
            }
          },
        ),
        actions: widget.fromAdmin
            ? [
                TextButton.icon(
                  onPressed: _goToDashboard,
                  icon: const Icon(Icons.dashboard_outlined,
                      color: Colors.white, size: 18),
                  label: const Text('Dashboard',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 4),
              ]
            : null,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: _buildStepIndicator(),
        ),
      ),
      body: _buildCurrentStep(),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: List.generate(_stepTitles.length, (i) {
          final done = i < _currentStep;
          final active = i == _currentStep;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: done
                              ? AppColors.accentLight
                              : active
                                  ? Colors.white
                                  : Colors.white.withAlpha(50),
                          border: Border.all(
                            color: active ? Colors.white : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: done
                              ? const Icon(Icons.check, size: 16, color: Colors.white)
                              : Icon(
                                  _stepIcons[i],
                                  size: 16,
                                  color: active
                                      ? AppColors.primary
                                      : Colors.white.withAlpha(150),
                                ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _stepTitles[i],
                        style: TextStyle(
                          fontSize: 9,
                          color: active
                              ? Colors.white
                              : Colors.white.withAlpha(150),
                          fontWeight: active
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (i < _stepTitles.length - 1)
                  Expanded(
                    child: Container(
                      height: 1,
                      margin: const EdgeInsets.only(bottom: 18),
                      color: i < _currentStep
                          ? AppColors.accentLight
                          : Colors.white.withAlpha(50),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return Step1ClientInfo(
          intervention: _intervention,
          onNext: _next,
        );
      case 1:
        return Step2AvantNettoyage(
          intervention: _intervention,
          onNext: _next,
          onPrev: _prev,
        );
      case 2:
        return Step3Nettoyage(
          intervention: _intervention,
          onNext: _next,
          onPrev: _prev,
        );
      case 3:
        return Step4ApresNettoyage(
          intervention: _intervention,
          onNext: _next,
          onPrev: _prev,
        );
      case 4:
        return Step5Validation(
          intervention: _intervention,
          onPrev: _prev,
          onFinish: _finish,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
