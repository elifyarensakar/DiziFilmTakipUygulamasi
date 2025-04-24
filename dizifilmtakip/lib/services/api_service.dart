import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<void> kaydol(Map<String, dynamic> kullanici) async {
    final url = Uri.parse('http://127.0.0.1:5000/kaydol'); // Emülatör dışı testte IP gerekebilir

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(kullanici),
    );

    if (response.statusCode == 201) {
      print("Kayıt başarılı: ${response.body}");
    } else {
      print("Hata oluştu: ${response.body}");
    }
  }
}
