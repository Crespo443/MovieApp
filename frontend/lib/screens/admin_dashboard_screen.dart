import 'package:flutter/material.dart';
import 'package:flutter_video_app/models/dashboard_stats.dart';
import 'package:flutter_video_app/screens/admin_add_movie_screen.dart';
import 'package:flutter_video_app/screens/admin_movie_list_screen.dart';
import 'package:flutter_video_app/screens/admin_user_list_screen.dart';
import 'package:flutter_video_app/screens/admin_unreplied_comments_screen.dart';
import 'package:flutter_video_app/services/admin_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Future<DashboardStats>? _dashboardStatsFuture;

  @override
  void initState() {
    super.initState();
    _dashboardStatsFuture = AdminService.getDashboardStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.grey[850],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.movie),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminAddMovieScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminUserListScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'Manage Movies',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminMovieListScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<DashboardStats>(
        future: _dashboardStatsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final stats = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Card(
                  color: Colors.grey[800],
                  child: ListTile(
                    leading: const Icon(Icons.people, color: Colors.white),
                    title: Text(
                      'Total Users',
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing: Text(
                      '${stats.totalUsers}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  color: Colors.grey[800],
                  child: ListTile(
                    leading: const Icon(Icons.star, color: Colors.amber),
                    title: Text(
                      'Total Subscription Users',
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing: Text(
                      '${stats.totalSubscriptionUsers}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  color: Colors.grey[800],
                  child: ListTile(
                    leading: const Icon(
                      Icons.comment,
                      color: Colors.lightBlueAccent,
                    ),
                    title: Text(
                      'Total Comments',
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing: Text(
                      '${stats.totalComments}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  color: Colors.grey[800],
                  child: ListTile(
                    leading: const Icon(
                      Icons.attach_money,
                      color: Colors.green,
                    ),
                    title: Text(
                      'Total Income',
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing: Text(
                      'SGD ${stats.totalIncome.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  color: Colors.red[800],
                  child: ListTile(
                    leading: const Icon(
                      Icons.question_answer,
                      color: Colors.white,
                    ),
                    title: const Text(
                      'Unreplied Comments',
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => const AdminUnrepliedCommentsScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          } else {
            return const Center(child: Text('No data'));
          }
        },
      ),
    );
  }
}
