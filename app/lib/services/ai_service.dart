import 'dart:convert';
import 'package:http/http.dart' as http;
import 'charity_service.dart';
import 'news_service.dart';

class AIRecommendation {
  final Charity charity;
  final NewsArticle newsArticle;
  final double relevanceScore;
  final String reason;

  const AIRecommendation({
    required this.charity,
    required this.newsArticle,
    required this.relevanceScore,
    required this.reason,
  });

  factory AIRecommendation.fromJson(Map<String, dynamic> json) {
    return AIRecommendation(
      charity: Charity.fromJson(json['charity']),
      newsArticle: NewsArticle.fromJson(json['news_article']),
      relevanceScore: (json['relevance_score'] ?? 0.0).toDouble(),
      reason: json['reason'] ?? '',
    );
  }
}

class AIService {
  static const String baseUrl = 'http://localhost:8000'; // Main API
  
  static Future<List<AIRecommendation>> getRecommendations(String userId) async {
    try {
      print('AIService: Getting recommendations for user: $userId');
      final url = '$baseUrl/ai/recommendations/$userId';
      print('AIService: Calling URL: $url');
      
      final response = await http.get(Uri.parse(url));
      print('AIService: Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(response.body);
        print('AIService: Received ${body.length} recommendations from API');
        return body.map((dynamic item) => AIRecommendation.fromJson(item)).toList();
      } else {
        print('AIService: Error loading AI recommendations: ${response.statusCode}');
        print('AIService: Response body: ${response.body}');
        return _getMockRecommendations(); // Fallback to mock data
      }
    } catch (e) {
      print('AIService: Error loading AI recommendations: $e');
      return _getMockRecommendations(); // Fallback to mock data
    }
  }

  static Future<void> updateUserPreferences(String userId, Map<String, dynamic> preferences) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/userpreferences'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'preferences': preferences,
        }),
      );
      
      if (response.statusCode != 200) {
        print('Failed to update preferences: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating preferences: $e');
    }
  }

  static List<AIRecommendation> _getMockRecommendations() {
    // This would normally come from the AI processing
    // For now, return mock data that simulates the AI matching
    return [
      AIRecommendation(
        charity: Charity(
          name: "Red Cross",
          mission: "Emergency disaster relief and humanitarian aid",
          url: "https://redcross.org",
          category: "disaster_relief",
        ),
        newsArticle: NewsArticle(
          title: "Hurricane Maria Devastates Puerto Rico",
          description: "Category 5 hurricane causes widespread destruction",
          url: "https://example.com/hurricane-maria",
          category: "disaster_relief",
          urgencyScore: 9.5,
          publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        relevanceScore: 0.95,
        reason: "High urgency disaster relief needed - Red Cross is actively responding",
      ),
      AIRecommendation(
        charity: Charity(
          name: "World Wildlife Fund",
          mission: "Conservation of nature and wildlife",
          url: "https://wwf.org",
          category: "environment",
        ),
        newsArticle: NewsArticle(
          title: "Climate Change Summit: New Initiatives",
          description: "World leaders announce environmental initiatives",
          url: "https://example.com/climate-summit",
          category: "environment",
          urgencyScore: 7.2,
          publishedAt: DateTime.now().subtract(const Duration(hours: 6)),
        ),
        relevanceScore: 0.87,
        reason: "Environmental initiatives align with climate change response",
      ),
    ];
  }
}
