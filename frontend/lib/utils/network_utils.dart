import 'package:http/http.dart' as http;

Future<bool> checkUserHasHealthData(String? token) async {
  final response = await http.get(
    Uri.parse('https://10.0.2.2:8000/users/user_has_health_data'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    return response.body == 'true';
  } else {
    throw Exception('Failed to check user health data');
  }
}

