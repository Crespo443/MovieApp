import 'package:flutter/material.dart';
import 'package:flutter_video_app/models/dashboard_stats.dart';
import 'package:flutter_video_app/screens/admin_add_movie_screen.dart';
import 'package:flutter_video_app/screens/admin_user_list_screen.dart';
import 'package:flutter_video_app/services/admin_service.dart';
import 'package:flutter_video_app/widgets/admin_dashboard/income.dart';
import 'package:flutter_video_app/widgets/admin_dashboard/new_comments.dart';
import 'package:flutter_video_app/widgets/admin_dashboard/watching_hours.dart';

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
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('Clear All Watch History'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text('Confirm'),
                            content: const Text(
                              'Are you sure you want to clear all users\' watch history?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Yes, Clear'),
                              ),
                            ],
                          ),
                    );
                    if (confirmed == true) {
                      try {
                        await AdminService.clearAllWatchHistory();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('All watch history cleared!'),
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: ${e.toString()}')),
                          );
                        }
                      }
                    }
                  },
                ),
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
