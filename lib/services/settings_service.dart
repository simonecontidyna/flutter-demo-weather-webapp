import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class SettingsService {
  static const _apiKeyKey = 'owm_api_key';

  static String loadApiKey() {
    return html.window.localStorage[_apiKeyKey] ?? '';
  }

  static void saveApiKey(String key) {
    html.window.localStorage[_apiKeyKey] = key.trim();
  }

  static void clearApiKey() {
    html.window.localStorage.remove(_apiKeyKey);
  }

  static String maskApiKey(String key) {
    if (key.length <= 8) return key.isNotEmpty ? '****' : '';
    return '${key.substring(0, 4)}${'*' * (key.length - 8)}${key.substring(key.length - 4)}';
  }
}
