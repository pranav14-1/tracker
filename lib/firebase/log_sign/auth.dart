import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  static Future<UserCredential> signUpWithEmail(
    String email,
    String password,
  ) async {
    final credential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await saveUserData(credential.user!);
    return credential;
  }

  static Future<void> saveUserData(User user) async {
    final userDoc = firestore.collection('Users').doc(user.uid);
    final userData = {'uid': user.uid, 'email': user.email};
    await userDoc.set(
      userData,
      SetOptions(merge: true),
    );
  }

  static Future<UserCredential> loginWithEmail(
    String email,
    String password,
  ) async {
    return await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> logout() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    if (await googleSignIn.isSignedIn()) {
      await googleSignIn.disconnect();
      await googleSignIn.signOut();
    }
    await auth.signOut();
  }

  static Future<UserCredential?> loginWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null;
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final authResult = await auth.signInWithCredential(credential);
    await saveUserData(authResult.user!);
    return authResult;
  }
  static User? getCurrentUser() {
    return auth.currentUser;
  }
}
