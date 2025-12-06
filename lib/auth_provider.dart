import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseClient supabase = Supabase.instance.client;

  User? _user;
  bool _isLoading = true;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _checkAuthState();
  }

  // ✅ Check initial auth state
  Future<void> _checkAuthState() async {
    _isLoading = true;
    notifyListeners();

    final session = supabase.auth.currentSession;
    _user = session?.user;

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _errorMessage = null;
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      _user = response.user;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = _getUserFriendlyError(e.message);
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Network error. Check your connection.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String email, String password) async {
    try {
      _errorMessage = null;
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );
      _user = response.user;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = _getUserFriendlyError(e.message);
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Network error. Check your connection.';
      notifyListeners();
      return false;
    }
  }

  // ✅ Logout
  Future<void> signOut() async {
    await supabase.auth.signOut();
    _user = null;
    notifyListeners();
  }

  // ✅ Auth state listener
  void initAuthListener() {
    supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      _user = session?.user;
      notifyListeners();
    });
  }

  String _getUserFriendlyError(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'Wrong email or password';
    } else if (message.contains('Email not confirmed')) {
      return 'Please confirm your email first';
    } else if (message.contains('User already registered')) {
      return 'Email already exists. Try login.';
    } else if (message.contains('weak_password')) {
      return 'Password too weak. Use 6+ characters.';
    } else if (message.contains('validation_failed')) {
      return 'Please check your input';
    }
    return 'Something went wrong. Try again.';
  }
}
