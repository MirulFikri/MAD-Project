import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Common vet clinic services
const List<String> commonVetServices = [
  'General Checkup',
  'Vaccinations',
  'Dental Care',
  'Surgery',
  'Emergency Care',
  'X-Ray',
  'Ultrasound',
  'Blood Tests',
  'Grooming',
  'Neutering/Spaying',
  'Dermatology',
  'Orthopedics',
];

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password for Pet Owner
  Future<Map<String, dynamic>> signUpOwner({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      // Create user in Firebase Auth
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      print(
        'DEBUG: Owner signup - uid: ${userCredential.user!.uid}, email: $email',
      );

      // Create user profile in Firestore
      await _firestore.collection('owners').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'name': name,
        'phone': phone,
        'userType': 'owner',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('DEBUG: Owner document created in Firestore');

      return {
        'success': true,
        'user': userCredential.user,
        'userType': 'owner',
      };
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'error': _getAuthErrorMessage(e.code)};
    } catch (e) {
      print('DEBUG: SignUpOwner error: $e');
      return {
        'success': false,
        'error': 'An unexpected error occurred. Please try again.',
      };
    }
  }

  // Sign up with email and password for Clinic
  Future<Map<String, dynamic>> signUpClinic({
    required String email,
    required String password,
    required String clinicName,
    required String phone,
    required String address,
    List<String>? services,
  }) async {
    try {
      // Create user in Firebase Auth
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Create clinic profile in Firestore
      await _firestore.collection('clinics').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'clinicName': clinicName,
        'phone': phone,
        'address': address,
        'services': services ?? [],
        'userType': 'clinic',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'user': userCredential.user,
        'userType': 'clinic',
      };
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'error': _getAuthErrorMessage(e.code)};
    } catch (e) {
      return {
        'success': false,
        'error': 'An unexpected error occurred. Please try again.',
      };
    }
  }

  // Sign in with email and password
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check user type
      String? userType = await getUserType(userCredential.user!.uid);
      print(
        'DEBUG: SignIn - uid: ${userCredential.user!.uid}, userType: $userType',
      );

      return {
        'success': true,
        'user': userCredential.user,
        'userType': userType,
      };
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'error': _getAuthErrorMessage(e.code)};
    } catch (e) {
      print('DEBUG: SignIn error: $e');
      return {
        'success': false,
        'error': 'An unexpected error occurred. Please try again.',
      };
    }
  }

  // Get user type (owner or clinic)
  Future<String?> getUserType(String uid) async {
    try {
      // Check if user is an owner
      DocumentSnapshot ownerDoc = await _firestore
          .collection('owners')
          .doc(uid)
          .get();
      if (ownerDoc.exists) {
        return 'owner';
      }

      // Check if user is a clinic
      DocumentSnapshot clinicDoc = await _firestore
          .collection('clinics')
          .doc(uid)
          .get();
      if (clinicDoc.exists) {
        return 'clinic';
      }

      // Debug: Log that document not found
      print('DEBUG: No owner or clinic document found for uid: $uid');
      return null;
    } catch (e) {
      print('DEBUG: Error in getUserType: $e');
      return null;
    }
  }

  // Get user data
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      String? userType = await getUserType(uid);

      if (userType == 'owner') {
        DocumentSnapshot doc = await _firestore
            .collection('owners')
            .doc(uid)
            .get();
        return doc.data() as Map<String, dynamic>?;
      } else if (userType == 'clinic') {
        DocumentSnapshot doc = await _firestore
            .collection('clinics')
            .doc(uid)
            .get();
        return doc.data() as Map<String, dynamic>?;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // Update user profile
  Future<bool> updateUserProfile({
    required String uid,
    required String userType,
    required Map<String, dynamic> data,
  }) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();

      if (userType == 'owner') {
        await _firestore.collection('owners').doc(uid).update(data);
      } else if (userType == 'clinic') {
        await _firestore.collection('clinics').doc(uid).update(data);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Reset password
  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return {
        'success': true,
        'message': 'Password reset email sent. Please check your inbox.',
      };
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'error': _getAuthErrorMessage(e.code)};
    } catch (e) {
      return {
        'success': false,
        'error': 'An unexpected error occurred. Please try again.',
      };
    }
  }

  // Change password
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        return {'success': false, 'error': 'No user is currently signed in.'};
      }

      // Re-authenticate user
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);

      return {'success': true, 'message': 'Password changed successfully.'};
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'error': _getAuthErrorMessage(e.code)};
    } catch (e) {
      return {
        'success': false,
        'error': 'An unexpected error occurred. Please try again.',
      };
    }
  }

  // Delete account
  Future<Map<String, dynamic>> deleteAccount(String password) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        return {'success': false, 'error': 'No user is currently signed in.'};
      }

      // Re-authenticate user
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);

      // Get user type and delete Firestore data
      String? userType = await getUserType(user.uid);
      if (userType == 'owner') {
        await _firestore.collection('owners').doc(user.uid).delete();
      } else if (userType == 'clinic') {
        await _firestore.collection('clinics').doc(user.uid).delete();
      }

      // Delete user account
      await user.delete();

      return {'success': true, 'message': 'Account deleted successfully.'};
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'error': _getAuthErrorMessage(e.code)};
    } catch (e) {
      return {
        'success': false,
        'error': 'An unexpected error occurred. Please try again.',
      };
    }
  }

  // Get all clinics
  Future<List<Map<String, dynamic>>> getAllClinics() async {
    try {
      final snapshot = await _firestore.collection('clinics').get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('DEBUG: Error getting clinics: $e');
      return [];
    }
  }

  // Get user-friendly error messages
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'requires-recent-login':
        return 'Please sign in again to complete this action.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
