import 'dart:convert';
import 'package:http/http.dart' as http;
import 'news_api_service.dart';

class AiBriefService {
  Future<Map<String, dynamic>> fetchBrief(String category) async {
    try {
      final uri = Uri.parse(
        '${NewsApiService.baseUrl}/api/ai-brief',
      ).replace(
        queryParameters: {'category': category},
      );

      final response = await http.get(uri);

      final data = jsonDecode(response.body);

      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid AI Brief response.');
      }

      if (response.statusCode != 200 || data['success'] != true) {
        throw Exception(
          data['error'] ??
              data['message'] ??
              'Unable to generate AI Brief.',
        );
      }

      return data;
    } catch (e) {
      throw Exception('AI Brief error: $e');
    }
  }
}