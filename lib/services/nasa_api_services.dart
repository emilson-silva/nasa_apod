import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/apod_model.dart';
import '../core/constants.dart'; // Importe o arquivo constants.dart

class NasaApiServices {
  static Future<ApodModel> fetchApod(DateTime date) async {
    final url = 'https://api.nasa.gov/planetary/apod?api_key=$nasaApiKey&date=${date.toIso8601String().split('T').first}';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return ApodModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load APOD: ${response.reasonPhrase}');
    }
  }
}