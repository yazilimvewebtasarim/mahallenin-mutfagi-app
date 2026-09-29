import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const _keyToken = 'auth_token';
  static const _keyRole = 'auth_role';
  static const _keyUserId = 'auth_user_id';
  static const _keyName = 'auth_user_name';

  static String? currentUserId;

  static Future<void> save({
    required String token,
    required String role,
    required String userId,
    String? name,
  }) async {
    currentUserId = userId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyRole, role);
    await prefs.setString(_keyUserId, userId);
    if (name != null) await prefs.setString(_keyName, name);
  }

  static Future<Map<String, String?>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString(_keyUserId);
    currentUserId = uid;
    return {
      'token': prefs.getString(_keyToken),
      'role': prefs.getString(_keyRole),
      'userId': uid,
      'name': prefs.getString(_keyName),
    };
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyRole);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyName);
  }

  static Future<bool> hasSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_keyToken);
    return token != null && token.isNotEmpty;
  }
}
