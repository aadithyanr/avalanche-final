import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsArticle {
  final String title;
  final String description;
  final String url;
  final String category;
  final double urgencyScore;
  final DateTime publishedAt;

  const NewsArticle({
    required this.title,
    required this.description,
    required this.url,
    required this.category,
    required this.urgencyScore,
    required this.publishedAt,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
      category: json['category'] ?? '',
      urgencyScore: (json['urgency_score'] ?? 0.0).toDouble(),
      publishedAt: DateTime.parse(json['published_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class NewsService {
  static const String baseUrl = 'http://localhost:8002'; // RSS feed service
  
  static Future<List<NewsArticle>> getRelevantNews() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:8000/ai/news'));
      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(response.body);
        return body.map((dynamic item) => NewsArticle.fromJson(item)).toList();
      } else {
        print('Error loading news: ${response.statusCode}');
        return _getMockNewsArticles(); // Fallback to mock data
      }
    } catch (e) {
      print('Error loading news: $e');
      return _getMockNewsArticles(); // Fallback to mock data
    }
  }

  static List<NewsArticle> _getMockNewsArticles() {
    return [
      NewsArticle(
        title: "Hurricane Maria Devastates Puerto Rico - Urgent Aid Needed",
        description: "Category 5 hurricane causes widespread destruction, leaving millions without power and clean water.",
        url: "https://example.com/hurricane-maria",
        category: "disaster_relief",
        urgencyScore: 9.5,
        publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      NewsArticle(
        title: "Wildfire Spreads Across California - Evacuations Underway",
        description: "Massive wildfire threatens thousands of homes, emergency services need immediate support.",
        url: "https://example.com/california-wildfire",
        category: "disaster_relief",
        urgencyScore: 8.8,
        publishedAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      NewsArticle(
        title: "Climate Change Summit: New Initiatives for Carbon Reduction",
        description: "World leaders announce new environmental initiatives to combat climate change.",
        url: "https://example.com/climate-summit",
        category: "environment",
        urgencyScore: 7.2,
        publishedAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      NewsArticle(
        title: "Refugee Crisis: Thousands Flee Conflict Zone",
        description: "Humanitarian crisis unfolds as thousands seek safety from ongoing conflict.",
        url: "https://example.com/refugee-crisis",
        category: "human_rights",
        urgencyScore: 9.1,
        publishedAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
    ];
  }
}
