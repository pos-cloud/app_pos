import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String apiUrl = 'https://d-api-v1.poscloud.ar/api/login';

  // Método para hacer la solicitud de login
  Future<String?> login(
      String database, String username, String password) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "database": database,
        "user": username,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      final token = responseBody['user']['token'];
      return token;
    } else {
      return null;
    }
  }
}
