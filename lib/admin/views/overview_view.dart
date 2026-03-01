import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/text_styles.dart';
import '../../providers/admin_provider.dart';

class OverviewView extends StatelessWidget {
  const OverviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);
    final totalUsers = adminProvider.allUsers.length;
    final totalListings = adminProvider.allListings.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('System Statistics', style: AppTextStyles.h3),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildStatCard(
                'Total Users',
                totalUsers.toString(),
                Icons.people,
                Colors.blue,
              ),
              const SizedBox(width: 24),
              _buildStatCard(
                'Marketplace Listings',
                totalListings.toString(),
                Icons.sell,
                Colors.green,
              ),
              const SizedBox(width: 24),
              _buildStatCard(
                'Platform Status',
                'Active',
                Icons.check_circle,
                Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 48),
          Text('Recent Activity Signals', style: AppTextStyles.h3),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                _buildActivityRow('System sync completed', '2 mins ago'),
                const Divider(),
                _buildActivityRow(
                  'New user registration spike detected',
                  '1 hour ago',
                ),
                const Divider(),
                _buildActivityRow(
                  'Marketplace database optimized',
                  '3 hours ago',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 16),
            Text(value, style: AppTextStyles.h1.copyWith(color: color)),
            const SizedBox(height: 4),
            Text(title, style: AppTextStyles.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityRow(String title, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}
