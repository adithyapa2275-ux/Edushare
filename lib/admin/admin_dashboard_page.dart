import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../core/colors.dart';
import '../core/text_styles.dart';
import '../providers/admin_provider.dart';
import 'views/overview_view.dart';
import 'views/manage_users_view.dart';
import 'views/manage_listings_view.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Initial fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      adminProvider.fetchAllUsers();
      adminProvider.fetchAllListings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // Sidebar / Navigation Rail
          NavigationRail(
            extended: isDesktop,
            backgroundColor: Colors.white,
            elevation: 5,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
            },
            leading: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.shield,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                if (isDesktop) ...[
                  const SizedBox(height: 10),
                  const Text(
                    'Admin',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
                const SizedBox(height: 40),
              ],
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: IconButton(
                    icon: const Icon(Icons.logout, color: Colors.red),
                    onPressed: () => context.go('/login'),
                  ),
                ),
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard, color: AppColors.primary),
                label: Text('Overview'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people, color: AppColors.primary),
                label: Text('Manage Users'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.library_books_outlined),
                selectedIcon: Icon(
                  Icons.library_books,
                  color: AppColors.primary,
                ),
                label: Text('Manage Listings'),
              ),
            ],
          ),

          const VerticalDivider(thickness: 1, width: 1),

          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Header
                Container(
                  height: 70,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Text(
                        _selectedIndex == 0
                            ? 'Dashboard Overview'
                            : _selectedIndex == 1
                            ? 'User Management'
                            : 'Listing Moderation',
                        style: AppTextStyles.h2,
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () {
                          final p = Provider.of<AdminProvider>(
                            context,
                            listen: false,
                          );
                          p.fetchAllUsers();
                          p.fetchAllListings();
                        },
                      ),
                    ],
                  ),
                ),

                // Active View
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: const [
                      OverviewView(),
                      ManageUsersView(),
                      ManageListingsView(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
