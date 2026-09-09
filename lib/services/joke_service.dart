import 'package:http/http.dart' as http;
import 'dart:convert';

class Joke {
  final String setup;
  final String punchline;
  final String type;

  Joke({
    required this.setup,
    required this.punchline,
    required this.type,
  });

  factory Joke.fromJson(Map<String, dynamic> json) {
    return Joke(
      setup: json['setup'] ?? '',
      punchline: json['punchline'] ?? '',
      type: json['type'] ?? 'general',
    );
  }
}

class JokeService {
  static const String _baseUrl = 'https://official-joke-api.appspot.com';

  /// Fetch a random joke
  static Future<Joke> getRandomJoke() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/random_joke'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Joke.fromJson(json);
      } else {
        throw Exception('Failed to load joke: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: $e');
    } on FormatException catch (e) {
      throw Exception('Invalid response format: $e');
    } catch (e) {
      throw Exception('Error fetching joke: $e');
    }
  }

  /// Fetch jokes by type (e.g., 'general', 'programming', 'knock-knock')
  static Future<List<Joke>> getJokesByType(String type) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/jokes/$type/ten'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Joke.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load jokes: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: $e');
    } on FormatException catch (e) {
      throw Exception('Invalid response format: $e');
    } catch (e) {
      throw Exception('Error fetching jokes: $e');
    }
  }

  /// Fetch a random joke from a specific type
  static Future<Joke> getRandomJokeByType(String type) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/jokes/$type/random'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        // Handle case where API returns an array
        if (json is List) {
          return Joke.fromJson(json[0]);
        }
        return Joke.fromJson(json);
      } else {
        throw Exception('Failed to load joke: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: $e');
    } on FormatException catch (e) {
      throw Exception('Invalid response format: $e');
    } catch (e) {
      throw Exception('Error fetching joke: $e');
    }
  }
}
