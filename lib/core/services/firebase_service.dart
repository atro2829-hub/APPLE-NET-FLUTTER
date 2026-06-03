import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_database/firebase_database.dart';

/// Firebase configuration constants for the Apple.NET project.
const firebaseConfig = {
  'apiKey': 'AIzaSyBAhuybF3tz1oh6j9HtNfhyo52tAX_t-_4',
  'authDomain': 'apple-net-df0e7.firebaseapp.com',
  'databaseURL': 'https://apple-net-df0e7-default-rtdb.firebaseio.com',
  'projectId': 'apple-net-df0e7',
  'storageBucket': 'apple-net-df0e7.firebasestorage.app',
  'messagingSenderId': '910060697351',
  'appId': '1:910060697351:android:177b0075a87ca0cb5ab7a2',
};

/// A comprehensive Firebase Realtime Database service for the Apple.NET app.
///
/// Provides authentication helpers and CRUD operations against the Firebase
/// Realtime Database with proper error handling and a singleton guarantee.
class FirebaseService {
  // ---------------------------------------------------------------------------
  // Singleton
  // ---------------------------------------------------------------------------
  FirebaseService._();
  static final FirebaseService _instance = FirebaseService._();
  static FirebaseService get instance => _instance;

  // ---------------------------------------------------------------------------
  // Firebase clients
  // ---------------------------------------------------------------------------
  late final firebase_auth.FirebaseAuth _auth;
  late final FirebaseDatabase _db;

  /// Whether [initialize] has been called successfully.
  bool _initialized = false;
  bool get isInitialized => _initialized;

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  /// Initializes the Firebase core SDK and wires up the Auth & Database
  /// clients using the project's configuration values.
  ///
  /// Call this once (e.g. in `main()`) before using any other method.
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      final options = FirebaseOptions(
        apiKey: firebaseConfig['apiKey']!,
        authDomain: firebaseConfig['authDomain']!,
        databaseURL: firebaseConfig['databaseURL']!,
        projectId: firebaseConfig['projectId']!,
        storageBucket: firebaseConfig['storageBucket']!,
        messagingSenderId: firebaseConfig['messagingSenderId']!,
        appId: firebaseConfig['appId']!,
      );

      await Firebase.initializeApp(options: options);

      _auth = firebase_auth.FirebaseAuth.instance;
      _db = FirebaseDatabase.instance;

      _initialized = true;
    } catch (e) {
      throw FirebaseInitializationException(
        'Failed to initialize Firebase: $e',
      );
    }
  }

  // ===========================================================================
  // Authentication
  // ===========================================================================

  /// Signs in with [email] and [password].
  ///
  /// Returns the authenticated [firebase_auth.User] on success.
  Future<firebase_auth.User> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user!;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      throw FirebaseServiceException('Sign-in failed: $e');
    }
  }

  /// Creates a new account with [email] and [password].
  ///
  /// Returns the newly created [firebase_auth.User] on success.
  Future<firebase_auth.User> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user!;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      throw FirebaseServiceException('Sign-up failed: $e');
    }
  }

  /// Signs out the currently authenticated user.
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw FirebaseServiceException('Sign-out failed: $e');
    }
  }

  /// Returns the currently signed-in user, or `null` if none.
  firebase_auth.User? getCurrentUser() {
    try {
      return _auth.currentUser;
    } catch (e) {
      throw FirebaseServiceException('Failed to get current user: $e');
    }
  }

  /// Emits the authentication state as a stream.
  ///
  /// Emits `null` when the user is signed out.
  Stream<firebase_auth.User?> authStateChanges() {
    try {
      return _auth.authStateChanges();
    } catch (e) {
      throw FirebaseServiceException(
        'Failed to listen to auth state changes: $e',
      );
    }
  }

  // ===========================================================================
  // Database – Read
  // ===========================================================================

  /// Reads data at [path] and returns the raw [DataSnapshot].
  ///
  /// Throws [FirebaseServiceException] on failure.
  Future<DataSnapshot> read(String path) async {
    try {
      final ref = _db.ref(path);
      final snapshot = await ref.get();
      return snapshot;
    } catch (e) {
      throw FirebaseServiceException('Read failed at "$path": $e');
    }
  }

  /// Reads data at [path] and returns it as a `Map<String, dynamic>?`.
  ///
  /// Returns `null` when the snapshot does not exist or its value is not a
  /// map.
  Future<Map<String, dynamic>?> readMap(String path) async {
    try {
      final snapshot = await read(path);
      if (!snapshot.exists) return null;
      final value = snapshot.value;
      if (value is Map<String, dynamic>) return value;
      if (value is Map) return Map<String, dynamic>.from(value);
      return null;
    } catch (e) {
      throw FirebaseServiceException('readMap failed at "$path": $e');
    }
  }

  // ===========================================================================
  // Database – Write / Update / Delete
  // ===========================================================================

  /// Writes [data] to [path], overwriting any existing value.
  Future<void> write(String path, dynamic data) async {
    try {
      final ref = _db.ref(path);
      await ref.set(data);
    } catch (e) {
      throw FirebaseServiceException('Write failed at "$path": $e');
    }
  }

  /// Updates specific fields at [path] with the key–value pairs in [data].
  ///
  /// Existing keys not present in [data] are left untouched.
  Future<void> update(String path, Map<String, dynamic> data) async {
    try {
      final ref = _db.ref(path);
      await ref.update(data);
    } catch (e) {
      throw FirebaseServiceException('Update failed at "$path": $e');
    }
  }

  /// Deletes the data at [path].
  Future<void> delete(String path) async {
    try {
      final ref = _db.ref(path);
      await ref.remove();
    } catch (e) {
      throw FirebaseServiceException('Delete failed at "$path": $e');
    }
  }

  /// Pushes [data] under [path], generating a unique auto-id key.
  ///
  /// Returns the generated key (e.g. `"-MxAbCdEfGhIjKlMn"`).
  Future<String> push(String path, dynamic data) async {
    try {
      final ref = _db.ref(path).push();
      await ref.set(data);
      return ref.key!;
    } catch (e) {
      throw FirebaseServiceException('Push failed at "$path": $e');
    }
  }

  // ===========================================================================
  // Database – Realtime Listener
  // ===========================================================================

  /// Subscribes to value changes at [path].
  ///
  /// The [callback] is invoked with the latest [DataSnapshot] whenever the
  /// data at [path] changes.
  ///
  /// Returns an unsubscribe function — call it to detach the listener.
  void Function() listen(String path, void Function(DataSnapshot) callback) {
    try {
      final ref = _db.ref(path);
      final subscription = ref.onValue.listen((event) {
        callback(event.snapshot);
      });
      return subscription.cancel;
    } catch (e) {
      throw FirebaseServiceException('Listen failed at "$path": $e');
    }
  }

  // ===========================================================================
  // Database – Transaction
  // ===========================================================================

  /// Runs an atomic transaction at [path].
  ///
  /// The [callback] receives the current [MutableData] and must return the
  /// desired new value (or the current value to abort the transaction).
  ///
  /// Returns the committed [TransactionResult].
  Future<TransactionResult> runTransaction(
    String path,
    TransactionHandler callback,
  ) async {
    try {
      final ref = _db.ref(path);
      return await ref.runTransaction(callback);
    } catch (e) {
      throw FirebaseServiceException('Transaction failed at "$path": $e');
    }
  }

  // ===========================================================================
  // Internal helpers
  // ===========================================================================

  /// Maps a [firebase_auth.FirebaseAuthException] to a domain-level
  /// [FirebaseServiceException] with a user-friendly message.
  FirebaseServiceException _mapAuthException(
    firebase_auth.FirebaseAuthException e,
  ) {
    switch (e.code) {
      case 'user-not-found':
        return FirebaseServiceException('No user found for that email.');
      case 'wrong-password':
        return FirebaseServiceException('Wrong password provided.');
      case 'email-already-in-use':
        return FirebaseServiceException('The email is already in use.');
      case 'weak-password':
        return FirebaseServiceException('The password is too weak.');
      case 'invalid-email':
        return FirebaseServiceException('The email address is invalid.');
      case 'user-disabled':
        return FirebaseServiceException('This user account has been disabled.');
      case 'too-many-requests':
        return FirebaseServiceException(
          'Too many requests. Please try again later.',
        );
      case 'operation-not-allowed':
        return FirebaseServiceException(
          'This sign-in method is not enabled.',
        );
      case 'network-request-failed':
        return FirebaseServiceException(
          'Network error. Please check your connection.',
        );
      default:
        return FirebaseServiceException(
          'Authentication error: ${e.message ?? e.code}',
        );
    }
  }
}

// =============================================================================
// Custom Exceptions
// =============================================================================

/// Thrown when Firebase initialization fails.
class FirebaseInitializationException implements Exception {
  final String message;
  FirebaseInitializationException(this.message);

  @override
  String toString() => 'FirebaseInitializationException: $message';
}

/// General-purpose exception for Firebase service operations.
class FirebaseServiceException implements Exception {
  final String message;
  FirebaseServiceException(this.message);

  @override
  String toString() => 'FirebaseServiceException: $message';
}
