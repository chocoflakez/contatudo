import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  // Singleton instance
  static final AuthService _instance = AuthService._internal();

  // Supabase client
  final SupabaseClient _supabase = Supabase.instance.client;

  // Private constructor
  AuthService._internal();

  // Access point to the singleton instance
  static AuthService get instance => _instance;

  // User information
  String? _name;
  String? _phone;
  String? _email;

  // Getter for the current session
  Session? currentSession() {
    return _supabase.auth.currentSession;
  }

  // Get the current user
  User? currentUser() {
    return _supabase.auth.currentUser;
  }

  // Get user details
  String? get userName => _name;
  String? get userPhone => _phone;
  String? get userEmail => _email;

  // Login the user with Email and Password
  Future<bool> login(String email, String password) async {
    try {
      // Perform login
      final response = await _supabase.auth
          .signInWithPassword(email: email, password: password);

      if (response.user != null) {
        // Load user details
        await loadUserDetails(response.user!.id);
        return true; // Login successful
      } else {
        return false; // Login failed
      }
    } catch (e) {
      print('Erro no login: $e');
      return false;
    }
  }

  // Logout the user
  Future<bool> signOut() async {
    try {
      await _supabase.auth.signOut();
      _clearUserDetails(); // Clear stored user details
      return true; // Sign out successful
    } catch (e) {
      print('Erro no logout: $e');
      return false; // Sign out failed
    }
  }

  // Register the user with Email, Password, and additional data
  Future<bool> register(
      {required String email,
      required String password,
      Map<String, dynamic>? additionalData}) async {
    try {
      // Step 1: Register the user
      final response =
          await _supabase.auth.signUp(email: email, password: password);

      if (response.user != null) {
        // Step 2: Insert additional data into the database
        if (additionalData != null) {
          final userId = response.user!.id;
          await _supabase.from('user').insert({
            'id': userId,
            ...additionalData,
            'email': email, // Ensure email is saved
          });
        }

        // Load the user details
        await loadUserDetails(response.user!.id);

        return true; // Registration successful
      } else {
        return false; // Registration failed
      }
    } catch (e) {
      print('Erro no registro: $e');
      return false;
    }
  }

  // Reset the password for a given email
  Future<bool> sendResetPassword(String email) async {
    print('AuthService::sendResetPassword INI');
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      print('AuthService::sendResetPassword END');
      return true; // Reset email sent successfully
    } catch (e) {
      print('Erro ao solicitar reset de senha: $e');
      print('AuthService::sendResetPassword END');
      return false; // Reset email failed
    }
  }

  // Public: Load user details from the database
  Future<void> loadUserDetails(String userId) async {
    try {
      final response = await _supabase
          .from('user')
          .select('name, phone, email')
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        _name = response['name'] as String?;
        _phone = response['phone'] as String?;
        _email = response['email'] as String?;
      }
    } catch (e) {
      print('Erro ao carregar detalhes do utilizador: $e');
    }
  }

  // Private: Clear user details on logout
  void _clearUserDetails() {
    _name = null;
    _phone = null;
    _email = null;
  }
}
