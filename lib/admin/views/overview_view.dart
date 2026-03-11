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
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('System Statistics', style: AppTextStyles.h3),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: isDesktop ? 4 : (size.width > 600 ? 2 : 1),
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: isDesktop ? 1.2 : 1.5,
            children: [
              _buildStatCard(
                'Total Users',
                totalUsers.toString(),
                Icons.people,
                Colors.blue,
              ),
              _buildStatCard(
                'Active Sellers',
                adminProvider.totalSellers.toString(),
                Icons.store,
                Colors.purple,
              ),
              _buildStatCard(
                'Marketplace Listings',
                totalListings.toString(),
                Icons.library_books,
                Colors.green,
              ),
              _buildStatCard(
                'Total Bookings',
                adminProvider.allOrders.length.toString(),
                Icons.shopping_bag,
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
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
              ),
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
    return Builder(
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 16),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: AppTextStyles.h1.copyWith(color: color, fontSize: 32),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: AppTextStyles.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
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
