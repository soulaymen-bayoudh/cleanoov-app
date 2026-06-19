import 'dart:convert';

class InterventionModel {
  String id;
  String numeroFiche;

  // Étape 1 — Infos Client
  String nomPrenom;
  String telephone;
  String adresse;
  double puissanceInstallee;
  int nombrePanneaux;
  DateTime dateIntervention;
  DateTime? prochaineIntervention;
  String technicien;
  String technicienTelephone; // Numéro du technicien

  // Étape 2 — Avant nettoyage
  double? puissanceAvant;
  String niveauEncrassement;
  bool pointsChaudes;
  int nbPointsChaudes;
  bool fissures;
  int nbFissures;
  String coffretAC;
  String onduleur;
  String visserie;
  String cablesConnecteurs;
  String coffretDC;
  String structureAncrages;
  bool ombragePartiel;
  String observationsAvant;
  List<String> photosAvant;

  // Étape 3 — Nettoyage effectué
  String methodeNettoyage;
  String produitUtilise;
  double dureeParJour;

  // Étape 4 — Après nettoyage
  double? puissanceApres;
  String pointsChaudsTraites;
  String etatGeneral;
  String recommandation;
  String observationsApres;
  List<String> photosApres;

  // Validation & Facturation
  bool luEtApprouve;
  double prixMission; // Prix de la mission (TND)
  bool termine;       // Mission terminée/envoyée à l'admin

  InterventionModel({
    required this.id,
    required this.numeroFiche,
    required this.nomPrenom,
    required this.telephone,
    required this.adresse,
    required this.puissanceInstallee,
    required this.nombrePanneaux,
    required this.dateIntervention,
    this.prochaineIntervention,
    required this.technicien,
    this.technicienTelephone = '',
    this.puissanceAvant,
    this.niveauEncrassement = 'leger',
    this.pointsChaudes = false,
    this.nbPointsChaudes = 0,
    this.fissures = false,
    this.nbFissures = 0,
    this.coffretAC = 'ok',
    this.onduleur = 'ok',
    this.visserie = 'ok',
    this.cablesConnecteurs = 'ok',
    this.coffretDC = 'ok',
    this.structureAncrages = 'ok',
    this.ombragePartiel = false,
    this.observationsAvant = '',
    this.photosAvant = const [],
    this.methodeNettoyage = 'brosse',
    this.produitUtilise = '',
    this.dureeParJour = 0,
    this.puissanceApres,
    this.pointsChaudsTraites = 'na',
    this.etatGeneral = 'bon',
    this.recommandation = 'aucune',
    this.observationsApres = '',
    this.photosApres = const [],
    this.luEtApprouve = false,
    this.prixMission = 0,
    this.termine = false,
  });

  static String generateNumero() {
    final now = DateTime.now();
    final date =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final rand = (now.millisecondsSinceEpoch % 1000).toString().padLeft(3, '0');
    return 'CLN-$date-$rand';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'numeroFiche': numeroFiche,
        'nomPrenom': nomPrenom,
        'telephone': telephone,
        'adresse': adresse,
        'puissanceInstallee': puissanceInstallee,
        'nombrePanneaux': nombrePanneaux,
        'dateIntervention': dateIntervention.toIso8601String(),
        'prochaineIntervention': prochaineIntervention?.toIso8601String(),
        'technicien': technicien,
        'technicienTelephone': technicienTelephone,
        'puissanceAvant': puissanceAvant,
        'niveauEncrassement': niveauEncrassement,
        'pointsChaudes': pointsChaudes,
        'nbPointsChaudes': nbPointsChaudes,
        'fissures': fissures,
        'nbFissures': nbFissures,
        'coffretAC': coffretAC,
        'onduleur': onduleur,
        'visserie': visserie,
        'cablesConnecteurs': cablesConnecteurs,
        'coffretDC': coffretDC,
        'structureAncrages': structureAncrages,
        'ombragePartiel': ombragePartiel,
        'observationsAvant': observationsAvant,
        'photosAvant': photosAvant,
        'methodeNettoyage': methodeNettoyage,
        'produitUtilise': produitUtilise,
        'dureeParJour': dureeParJour,
        'puissanceApres': puissanceApres,
        'pointsChaudsTraites': pointsChaudsTraites,
        'etatGeneral': etatGeneral,
        'recommandation': recommandation,
        'observationsApres': observationsApres,
        'photosApres': photosApres,
        'luEtApprouve': luEtApprouve,
        'prixMission': prixMission,
        'termine': termine,
      };

  factory InterventionModel.fromJson(Map<String, dynamic> json) =>
      InterventionModel(
        id: json['id'],
        numeroFiche: json['numeroFiche'],
        nomPrenom: json['nomPrenom'],
        telephone: json['telephone'],
        adresse: json['adresse'],
        puissanceInstallee: (json['puissanceInstallee'] as num).toDouble(),
        nombrePanneaux: json['nombrePanneaux'],
        dateIntervention: DateTime.parse(json['dateIntervention']),
        prochaineIntervention: json['prochaineIntervention'] != null
            ? DateTime.parse(json['prochaineIntervention'])
            : null,
        technicien: json['technicien'],
        technicienTelephone: json['technicienTelephone'] ?? '',
        puissanceAvant: json['puissanceAvant'] != null
            ? (json['puissanceAvant'] as num).toDouble()
            : null,
        niveauEncrassement: json['niveauEncrassement'] ?? 'leger',
        pointsChaudes: json['pointsChaudes'] ?? false,
        nbPointsChaudes: json['nbPointsChaudes'] ?? 0,
        fissures: json['fissures'] ?? false,
        nbFissures: json['nbFissures'] ?? 0,
        coffretAC: json['coffretAC'] ?? 'ok',
        onduleur: json['onduleur'] ?? 'ok',
        visserie: json['visserie'] ?? 'ok',
        cablesConnecteurs: json['cablesConnecteurs'] ?? 'ok',
        coffretDC: json['coffretDC'] ?? 'ok',
        structureAncrages: json['structureAncrages'] ?? 'ok',
        ombragePartiel: json['ombragePartiel'] ?? false,
        observationsAvant: json['observationsAvant'] ?? '',
        photosAvant: List<String>.from(json['photosAvant'] ?? []),
        methodeNettoyage: json['methodeNettoyage'] ?? 'brosse',
        produitUtilise: json['produitUtilise'] ?? '',
        dureeParJour: (json['dureeParJour'] as num?)?.toDouble() ?? 0,
        puissanceApres: json['puissanceApres'] != null
            ? (json['puissanceApres'] as num).toDouble()
            : null,
        pointsChaudsTraites: json['pointsChaudsTraites'] ?? 'na',
        etatGeneral: json['etatGeneral'] ?? 'bon',
        recommandation: json['recommandation'] ?? 'aucune',
        observationsApres: json['observationsApres'] ?? '',
        photosApres: List<String>.from(json['photosApres'] ?? []),
        luEtApprouve: json['luEtApprouve'] ?? false,
        prixMission: (json['prixMission'] as num?)?.toDouble() ?? 0,
        termine: json['termine'] ?? false,
      );

  String toJsonString() => jsonEncode(toJson());
  factory InterventionModel.fromJsonString(String s) =>
      InterventionModel.fromJson(jsonDecode(s));
}
