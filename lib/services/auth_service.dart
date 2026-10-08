import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;
  Stream<User?> authStateChanges() => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  String get currentUserName {
    final name = currentUser?.displayName?.trim();

    if (name != null && name.isNotEmpty) return name;
    return currentUser?.email ?? '';
  }

  Future<void> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> register(String name, String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await credential.user?.updateDisplayName(name);
    await credential.user?.reload();
  }

  Future<void> signOut() => _auth.signOut();
}
