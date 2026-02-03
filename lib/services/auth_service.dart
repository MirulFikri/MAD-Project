import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Used as default or reference when creating clinic profiles
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
/// Service class for handling user authentication and profile management
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Returns the currently logged-in user, or null if no user is signed in
  User? get currentUser => _auth.currentUser;

  /// Returns the unique ID of the currently logged-in user, or null if not signed in
  String? get currentUserId => _auth.currentUser?.uid;

  /// A stream that emits the current authentication state whenever it changes
  /// Used to listen for login/logout events throughout the app
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Creates a new pet owner account in Firebase and stores owner profile in Firestore
  Future<Map<String, dynamic>> signUpOwner({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      // Create the user account in Firebase Authentication
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      /// Prints the newly created user's unique identifier (uid) and email address
      /// to the console for debugging and verification purposes.
      print(
        'DEBUG: Owner signup - uid: ${userCredential.user!.uid}, email: $email',
      );

      // Store the owner's profile information in Firestore database
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

  /// Creates a new veterinary clinic account in Firebase and stores clinic profile in Firestore
  Future<Map<String, dynamic>> signUpClinic({
    required String email,
    required String password,
    required String clinicName,
    required String phone,
    required String address,
    List<String>? services,
  }) async {
    try {
      // Create the clinic account in Firebase Authentication
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Store the clinic's detailed profile information in Firestore database
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

  /// Authenticates a user with their email and password
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // After successful login, determine whether this is an owner or clinic account
      // This is used to show the correct dashboard
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

  /// Determines whether a user is a pet owner or a veterinary clinic
  Future<String?> getUserType(String uid) async {
    try {
      // First, check if this user is registered as a pet owner
      DocumentSnapshot ownerDoc = await _firestore
          .collection('owners')
          .doc(uid)
          .get();
      if (ownerDoc.exists) {
        return 'owner';
      }

      // If not found in owners, check if they are registered as a clinic
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

  /// Retrieves the complete profile data for a user from Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      // Determine user type first, then retrieve data from the appropriate collection
      String? userType = await getUserType(uid);

      if (userType == 'owner') {
        // Retrieve owner profile data from Firestore
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

  /// Updates a user's profile information in Firestore
  Future<bool> updateUserProfile({
    required String uid,
    required String userType,
    required Map<String, dynamic> data,
  }) async {
    try {
      // Add a server timestamp to record when this update happened
      data['updatedAt'] = FieldValue.serverTimestamp();

      // Update the appropriate collection based on user type
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

  /// This clears the user's session and prevents access to protected features.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Sends a password reset email to the user
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

  /// Changes the password of the currently logged-in user
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        return {'success': false, 'error': 'No user is currently signed in.'};
      }

      // Verify the user's identity by re-authenticating with current password
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // If verified, update to the new password
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

  /// Permanently deletes the user's account from Firebase and Firestore
  Future<Map<String, dynamic>> deleteAccount(String password) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        return {'success': false, 'error': 'No user is currently signed in.'};
      }

      // Verify the user's identity by re-authenticating with their password
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);

      // Delete the user's profile data from Firestore
      String? userType = await getUserType(user.uid);
      if (userType == 'owner') {
        await _firestore.collection('owners').doc(user.uid).delete();
      } else if (userType == 'clinic') {
        await _firestore.collection('clinics').doc(user.uid).delete();
      }

      // Delete the user's Firebase Auth account
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

  /// Retrieves a list of all registered veterinary clinics.
  /// Used by pet owners to find and browse available clinics.
  /// Returns all clinic profiles from the Firestore database.
  Future<List<Map<String, dynamic>>> getAllClinics() async {
    try {
      final snapshot = await _firestore.collection('clinics').get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('DEBUG: Error getting clinics: $e');
      return [];
    }
  }

  /// Converts Firebase error codes into clear, user-friendly error messages
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
