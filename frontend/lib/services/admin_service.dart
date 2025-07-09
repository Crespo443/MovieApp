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

  static Future<List<UserModel>> getAllUsers({
    String search = '',
    int page = 1,
    int limit = 20,
  }) async {
    final uri = Uri.parse('${ApiService.baseUrl}/users/admin/users').replace(
      queryParameters: {
        if (search.isNotEmpty) 'search': search,
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );
    final response = await http.get(uri, headers: ApiService.headers);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return (json['data'] as List).map((u) => UserModel.fromJson(u)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  static Future<void> editUser({
    required String userId,
    String? name,
    String? email,
    String? role,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiService.baseUrl}/users/admin/users/$userId'),
      headers: ApiService.headers,
      body: jsonEncode({
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (role != null) 'role': role,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to edit user: \n${response.body}');
    }
  }

  static Future<void> deleteUser(String userId) async {
    final response = await http.delete(
      Uri.parse('${ApiService.baseUrl}/users/admin/users/$userId'),
      headers: ApiService.headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete user: \n${response.body}');
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
      throw Exception('Failed to add movie: \n${response.body}');
    }
  }
}
