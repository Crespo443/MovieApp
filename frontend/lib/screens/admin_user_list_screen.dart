import 'package:flutter/material.dart';
import 'package:flutter_video_app/models/user_model.dart';
import 'package:flutter_video_app/services/admin_service.dart';
import 'package:intl/intl.dart';

class AdminUserListScreen extends StatefulWidget {
  const AdminUserListScreen({super.key});

  @override
  State<AdminUserListScreen> createState() => _AdminUserListScreenState();
}

class _AdminUserListScreenState extends State<AdminUserListScreen> {
  late Future<List<UserModel>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = AdminService.getAllUsers();
  }

  String getPlanName(String? planId) {
    return {
          'price_1RYDjQFJqSjpkwgi7LpWIYfj': 'Basic Plan',
          'price_1RYDgNFJqSjpkwgim7nwsQ4F': 'Premium Plan',
          // Add more as needed
        }[planId ?? ''] ??
        'Unknown Plan';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User List')),
      body: FutureBuilder<List<UserModel>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: \\${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users found.'));
          }
          final users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              // Try to get createdAt from user if available
              String regDate = 'Unknown';
              if (user.toJson().containsKey('createdAt') &&
                  user.toJson()['createdAt'] != null) {
                final rawDate = user.toJson()['createdAt'];
                final parsed = DateTime.tryParse(rawDate);
                if (parsed != null) {
                  regDate = DateFormat('yyyy-MM-dd').format(parsed);
                }
              }
              final planId = user.subscription?.planId;
              final planName = getPlanName(planId);
              return ListTile(
                leading: CircleAvatar(child: Text((index + 1).toString())),
                title: Text(user.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Registered: $regDate'),
                    Text('Plan: $planName'),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    // Handle delete user
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
