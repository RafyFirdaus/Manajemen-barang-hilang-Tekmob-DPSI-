import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dashboard_tab_bar.dart';
import 'dashboard_search_bar.dart';

class DashboardHeader extends StatelessWidget {
  final String username;
  final TabController tabController;
  final List<String> tabTitles;
  final TextEditingController searchController;
  final VoidCallback? onRefreshPressed;
  final Function(String)? onSearchChanged;

  const DashboardHeader({
    Key? key,
    required this.username,
    required this.tabController,
    required this.tabTitles,
    required this.searchController,
    this.onRefreshPressed,
    this.onSearchChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selamat datang, $username',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          DashboardTabBar(
            controller: tabController,
            tabTitles: tabTitles,
          ),
          const SizedBox(height: 20),
          DashboardSearchBar(
            controller: searchController,
            onRefreshPressed: onRefreshPressed,
            onSearchChanged: onSearchChanged,
          ),
        ],
      ),
    );
  }
}