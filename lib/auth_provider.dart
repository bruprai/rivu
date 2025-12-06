import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseClient supabase = Supabase.instance.client;

  User? _user;
  User? get user => _user;

  AuthProvider() {
    _user = supabase.auth.currentUser;
    supabase.auth.onAuthStateChange.listen((data) {
      _user = data.session?.user;
      notifyListeners();
    });
  }

  Future<void> signIn(String email, String password) async {
    final res = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (res.user != null) {
      _user = res.user;
      notifyListeners();
    } else {
      throw Exception("Sign-in failed");
    }
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
    _user = null;
    notifyListeners();
  }
}
