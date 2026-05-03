import 'package:nhost_flutter_auth/nhost_flutter_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

final nhostClient = NhostClient(
  subdomain: Subdomain(
    subdomain: 'hdlupyawqibeobhzjlhm',
    region: 'eu-central-1',
  ),
  authStore: _SharedPrefsAuthStore(),
);

class _SharedPrefsAuthStore implements AuthStore {
  @override
  Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  @override
  Future<void> setString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  @override
  Future<void> removeItem(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}
