import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../screens/profile/profile_screen.dart';
import '../screens/mydocs/mydocs_screen.dart';
import '../screens/map/govt_map_screen.dart';
import '../screens/scheme_details_screen.dart';
import '../services/api_service.dart';
import '../search/scheme_search_delegate.dart';
import '../screens/category_schemes_screen.dart'; // ✅ ADDED (required)

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  List<dynamic> searchResults = [];
  bool isLoading = false;

  // 🎠 Carousel
  List<String> carouselTitles = [];
  bool _isCarouselLoading = true;
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _carouselTimer;

  // 🎨 Theme
  final Color primaryPurple = const Color(0xFF6C4AB6);
  final Color lightPurple = const Color(0xFFE6DFFF);

  // ✅ Pages
  List<Widget> get _pages => [
    _homeContent(),
    const MyDocsScreen(),
    const SizedBox(),
    _notificationsPage(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    fetchCarousel();
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // 🔄 Carousel fetch
  Future<void> fetchCarousel() async {
    setState(() => _isCarouselLoading = true);

    try {
      final data = await ApiService.getCarouselSchemes();
      List<String> titles = [];

      if (data.isNotEmpty) {
        if (data.first is String) {
          titles = List<String>.from(data);
        } else if (data.first is Map) {
          titles = data
              .where((e) => e["title"] != null || e["scheme_title"] != null)
              .map<String>(
                (e) => (e["title"] ?? e["scheme_title"]).toString().trim(),
              )
              .toList();
        }
      }

      setState(() {
        carouselTitles = titles.length > 6 ? titles.sublist(0, 6) : titles;
        _isCarouselLoading = false;
      });

      if (carouselTitles.isNotEmpty) {
        _carouselTimer?.cancel();
        _carouselTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
          if (_pageController.hasClients) {
            _currentPage = (_currentPage + 1) % carouselTitles.length;
            _pageController.animateToPage(
              _currentPage,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          }
        });
      }
    } catch (_) {
      setState(() {
        _isCarouselLoading = false;
        carouselTitles = [];
      });
    }
  }

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: primaryPurple,
        title: Text(
          "JanSaathi",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: _bottomNavBar(),
      floatingActionButton: _locationButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _homeContent() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchBar(),
          const SizedBox(height: 16),
          _buildCarousel(),
          const SizedBox(height: 20),
          _buildCategoryGrid(),
          const SizedBox(height: 20),
          _buildSearchResults(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () {
        showSearch(context: context, delegate: SchemeSearchDelegate());
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade400),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: primaryPurple),
            const SizedBox(width: 10),
            const Text(
              "Search government schemes...",
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarousel() {
    if (_isCarouselLoading) {
      return SizedBox(
        height: 140,
        child: Center(child: CircularProgressIndicator(color: primaryPurple)),
      );
    }

    if (carouselTitles.isEmpty) {
      return const SizedBox(
        height: 140,
        child: Center(child: Text("No schemes available")),
      );
    }

    return SizedBox(
      height: 120,
      child: PageView.builder(
        controller: _pageController,
        itemCount: carouselTitles.length,
        itemBuilder: (context, index) {
          final title = carouselTitles[index];
          return GestureDetector(
            onTap: () => _openSchemeDetails(title),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryPurple,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ✅ ONLY THIS PART WAS UPDATED (CATEGORY LOGIC)
  Widget _buildCategoryGrid() {
    final categories = [
      {
        'icon': Icons.agriculture,
        'label': 'Farmers',
        'categories': ['Agriculture, Rural & Environment'],
      },
      {
        'icon': Icons.school,
        'label': 'School',
        'categories': ['Education & Learning'],
      },
      {
        'icon': Icons.local_hospital,
        'label': 'Health',
        'categories': ['Health & Wellness'],
      },
      {
        'icon': Icons.woman,
        'label': 'Women & Child',
        'categories': ['Women and Child'],
      },
      {
        'icon': Icons.home,
        'label': 'Housing',
        'categories': ['Housing & Shelter'],
      },
      {
        'icon': Icons.work,
        'label': 'Business',
        'categories': ['Business & Entrepreneurship'],
      },
      {
        'icon': Icons.account_balance,
        'label': 'Banking',
        'categories': ['Banking, Financial Services and Insurance'],
      },
      {
        'icon': Icons.balance,
        'label': 'Justice',
        'categories': ['Public Safety, Law & Justice'],
      },
      {
        'icon': Icons.trending_up,
        'label': 'Skills',
        'categories': ['Skills & Employment'],
      },
      {
        'icon': Icons.sports_cricket,
        'label': 'Sports',
        'categories': ['Sports & Culture'],
      },
      {
        'icon': Icons.cleaning_services,
        'label': 'Sanitation',
        'categories': ['Utility & Sanitation'],
      },
      {
        'icon': Icons.directions_bus,
        'label': 'Transport & Travel',
        'categories': ['Transport & Infrastructure', 'Travel & Tourism'],
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final cat = categories[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CategorySchemesScreen(
                  title: cat['label'] as String,
                  categories: List<String>.from(cat['categories'] as List),
                ),
              ),
            );
          },
          child: Column(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: lightPurple,
                child: Icon(cat['icon'] as IconData, color: primaryPurple),
              ),
              const SizedBox(height: 6),
              Text(cat['label'] as String),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchResults() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (searchResults.isEmpty) return const SizedBox();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final scheme = searchResults[index];
        return ListTile(
          title: Text(scheme["title"] ?? "No Title"),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _openSchemeDetails(scheme["title"]),
        );
      },
    );
  }

  Widget _bottomNavBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home, 0),
          _navItem(Icons.folder, 1),
          const SizedBox(width: 40),
          _navItem(Icons.notifications, 3),
          _navItem(Icons.person, 4),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, int index) {
    return IconButton(
      icon: Icon(
        icon,
        color: _currentIndex == index ? primaryPurple : Colors.grey,
      ),
      onPressed: () => setState(() => _currentIndex = index),
    );
  }

  static Widget _notificationsPage() {
    return const Center(child: Text("Notifications"));
  }

  Widget _locationButton() {
    return FloatingActionButton(
      backgroundColor: primaryPurple,
      child: const Icon(Icons.location_on),
      onPressed: _openGovtMap,
    );
  }

  void _openGovtMap() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: const GovtMapScreen(),
      ),
    );
  }

  void _openSchemeDetails(String? title) {
    if (title == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SchemeDetailsScreen(title: title)),
    );
  }
}
