import 'dart:convert';
import 'package:http/http.dart' as http;

class Charity {
  final String name;
  final String mission;
  final String url;
  final String category;

  const Charity({
    required this.name,
    required this.mission,
    required this.url,
    required this.category,
  });

  factory Charity.fromJson(Map<String, dynamic> json) {
    return Charity(
      name: json['name'] ?? '',
      mission: json['mission'] ?? '',
      url: json['url'] ?? '',
      category: json['category'] ?? '',
    );
  }
}

class CharityService {
  static const String baseUrl = 'http://localhost:8000';
  
  static Future<List<Charity>> getCharitiesForCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/charities/$category'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Charity.fromJson(json)).toList();
      } else {
        print('Failed to load charities: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error loading charities: $e');
      return [];
    }
  }

  static Future<List<String>> getCategories() async {
    // Return predefined categories for now
    return [
      'environment',
      'health',
      'education',
      'poverty',
      'animals',
      'disaster_relief',
      'human_rights',
      'technology',
    ];
  }

  static Future<List<Charity>> getAllCharities() async {
    final categories = await getCategories();
    final allCharities = <Charity>[];
    
    for (final category in categories) {
      final charities = await getCharitiesForCategory(category);
      allCharities.addAll(charities);
    }
    
    return allCharities;
  }
}
