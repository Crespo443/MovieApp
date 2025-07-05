class DashboardStats {
  final int totalUsers;
  final int totalSubscriptionUsers;
  final int totalComments;
  final double totalIncome;
  final double totalWatchingHours;

  DashboardStats({
    required this.totalUsers,
    required this.totalSubscriptionUsers,
    required this.totalComments,
    required this.totalIncome,
    required this.totalWatchingHours,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalUsers: json['totalUsers'] as int? ?? 0,
      totalSubscriptionUsers: json['totalSubscriptionUsers'] as int? ?? 0,
      totalComments: json['totalComments'] as int? ?? 0,
      totalIncome: (json['totalIncome'] as num?)?.toDouble() ?? 0.0,
      totalWatchingHours:
          (json['totalWatchingHours'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
