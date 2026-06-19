import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TechnicienProfile {
  final String uid;
  final String nom;
  final String telephone;
  final bool isAdmin;

  const TechnicienProfile({
    required this.uid,
    required this.nom,
    required this.telephone,
    this.isAdmin = false,
  });
}

class AuthService {
  // ── Identifiants locaux (avant configuration Firebase) ─────────────────────
  static const _localTechPassword = 'cleanoov2024';
  static const _localAdminEmail = 'admin@cleanoov.com';
  static const _localAdminPassword = 'Admin@Cleanoov2024';

  static bool get _firebaseReady {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static TechnicienProfile? _localSession;

  static TechnicienProfile? get currentLocalSession => _localSession;

  static User? get currentFirebaseUser =>
      _firebaseReady ? FirebaseAuth.instance.currentUser : null;

  static Stream<User?> get authStateChanges => _firebaseReady
      ? FirebaseAuth.instance.authStateChanges()
      : const Stream.empty();

  // ── Inscription ─────────────────────────────────────────────────────────────
  static Future<TechnicienProfile> signUp({
    required String email,
    required String password,
    required String nom,
    required String telephone,
  }) async {
    if (_firebaseReady) {
      return _firebaseSignUp(
          email: email, password: password, nom: nom, telephone: telephone);
    }
    throw Exception(
        'Firebase non configuré — inscription impossible en mode local');
  }

  static Future<TechnicienProfile> _firebaseSignUp({
    required String email,
    required String password,
    required String nom,
    required String telephone,
  }) async {
    final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    final user = cred.user!;
    await user.updateDisplayName(nom.trim());

    // Sauvegarder profil dans Firestore
    await FirebaseFirestore.instance
        .collection('techniciens')
        .doc(user.uid)
        .set({
      'nom': nom.trim(),
      'telephone': telephone.trim(),
      'email': email.trim(),
      'isAdmin': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return TechnicienProfile(
      uid: user.uid,
      nom: nom.trim(),
      telephone: telephone.trim(),
    );
  }

  // ── Connexion ───────────────────────────────────────────────────────────────
  static Future<TechnicienProfile> signIn(
      String email, String password) async {
    if (_firebaseReady) {
      return _firebaseSignIn(email, password);
    }
    return _localSignIn(email, password);
  }

  // ── Firebase Auth ───────────────────────────────────────────────────────────
  static Future<TechnicienProfile> _firebaseSignIn(
      String email, String password) async {
    final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    final user = cred.user!;
    return _fetchOrCreateProfile(user);
  }

  static Future<TechnicienProfile> _fetchOrCreateProfile(User user) async {
    final ref = FirebaseFirestore.instance
        .collection('techniciens')
        .doc(user.uid);
    final doc = await ref.get();

    if (!doc.exists) {
      final nom = user.displayName ?? user.email!.split('@').first;
      await ref.set({
        'nom': nom,
        'telephone': '',
        'email': user.email,
        'isAdmin': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return TechnicienProfile(uid: user.uid, nom: nom, telephone: '');
    }

    final data = doc.data()!;
    return TechnicienProfile(
      uid: user.uid,
      nom: data['nom'] ?? '',
      telephone: data['telephone'] ?? '',
      isAdmin: data['isAdmin'] ?? false,
    );
  }

  // ── Mode local (fallback avant Firebase) ───────────────────────────────────
  static Future<TechnicienProfile> _localSignIn(
      String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simule réseau

    // Admin local
    if (email.trim().toLowerCase() == _localAdminEmail &&
        password == _localAdminPassword) {
      _localSession = const TechnicienProfile(
        uid: 'local-admin',
        nom: 'Administrateur',
        telephone: '',
        isAdmin: true,
      );
      return _localSession!;
    }

    // Technicien local — email quelconque + mot de passe commun
    if (password == _localTechPassword && email.contains('@')) {
      final nom = email.split('@').first;
      _localSession = TechnicienProfile(
        uid: 'local-$nom',
        nom: nom,
        telephone: '',
        isAdmin: false,
      );
      return _localSession!;
    }

    throw Exception('Email ou mot de passe incorrect');
  }

  // ── Déconnexion ─────────────────────────────────────────────────────────────
  static Future<void> signOut() async {
    _localSession = null;
    if (_firebaseReady) {
      await FirebaseAuth.instance.signOut();
    }
  }

  // ── Profil utilisateur courant ──────────────────────────────────────────────
  static Future<TechnicienProfile?> getCurrentProfile() async {
    if (_localSession != null) return _localSession;
    if (!_firebaseReady) return null;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return _fetchOrCreateProfile(user);
  }

  // ── Réinitialisation mot de passe ───────────────────────────────────────────
  static Future<void> resetPassword(String email) async {
    if (!_firebaseReady) {
      throw Exception(
          'Firebase non configuré — réinitialisation impossible en mode local');
    }
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
  }

  // ── Mettre à jour téléphone Firestore ───────────────────────────────────────
  static Future<void> updateTelephone(String uid, String tel) async {
    if (!_firebaseReady) return;
    await FirebaseFirestore.instance
        .collection('techniciens')
        .doc(uid)
        .update({'telephone': tel});
  }
}
