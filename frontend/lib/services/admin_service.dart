import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_video_app/models/dashboard_stats.dart';
import 'package:flutter_video_app/services/api_service.dart';
import 'package:flutter_video_app/models/user_model.dart';

class AdminService {
  static Future<DashboardStats> getDashboardStats() async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/admin/dashboard-stats'),
      headers: ApiService.headers, // Use public getter
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return DashboardStats.fromJson(json['data']);
    } else {
      throw Exception('Failed to load dashboard stats');
    }
  }

  static Future<void> clearAllWatchHistory() async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/admin/clear-watch-history'),
      headers: ApiService.headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to clear all watch history');
    }
  }

  static Future<List<UserModel>> getAllUsers() async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/users/admin/users'),
      headers: ApiService.headers,
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return (json['data'] as List).map((u) => UserModel.fromJson(u)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  static Future<void> addMovie({
    required String title,
    required String description,
    required String videoUrl,
    required String posterPath,
    required String backdropPath,
    required List<String> genre,
    required List<String> type,
    required int rating,
    required String releaseDate,
    required String tmdbId,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/movies/admin/movies'),
      headers: ApiService.headers,
      body: jsonEncode({
        'title': title,
        'description': description,
        'videoUrl': videoUrl,
        'posterPath': posterPath,
        'backdropPath': backdropPath,
        'genre': genre,
        'type': type,
        'rating': rating,
        'releaseDate': releaseDate,
        'tmdbId': tmdbId,
      }),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add movie: \n' + response.body);
    }
  }
}
