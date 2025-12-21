import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../screens/profile/profile_screen.dart';
import '../screens/mydocs/mydocs_screen.dart';
import '../screens/map/govt_map_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _homeContent(),          // Home
      const MyDocsScreen(),    // MyDocs
      const SizedBox(),        // Placeholder for FAB
      _notificationsPage(),    // Notifications
      const ProfileScreen(),   // Profile
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(
          "Jan-Saathi",
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

  // ================= HOME CONTENT =================
  static Widget _homeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _searchBar(),
          const SizedBox(height: 20),
          _adsCarousel(),
          const SizedBox(height: 30),
          _sectionTitle("Scheme Categories"),
          const SizedBox(height: 15),
          _categoriesGrid(),
          const SizedBox(height: 30),
          _sectionTitle("Trending Schemes"),
          const SizedBox(height: 12),
          _trendingSchemes(),
        ],
      ),
    );
  }

  // ================= SEARCH BAR =================
  static Widget _searchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: "Search government schemes...",
          prefixIcon: Icon(Icons.search, color: Colors.deepPurple),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(15),
        ),
      ),
    );
  }

  // ================= ADS =================
  static Widget _adsCarousel() {
    return SizedBox(
      height: 170,
      child: PageView(
        children: const [
          _AdCard("PM-KISAN", "₹6000 yearly farmer support"),
          _AdCard("Ayushman Bharat", "Health cover up to ₹5 Lakhs"),
          _AdCard("PMAY", "Affordable housing for all"),
        ],
      ),
    );
  }

  // ================= CATEGORIES =================
  static Widget _categoriesGrid() {
    final categories = [
      {"icon": Icons.school, "title": "Students"},
      {"icon": Icons.agriculture, "title": "Farmers"},
      {"icon": Icons.local_hospital, "title": "Health"},
      {"icon": Icons.house, "title": "Housing"},
      {"icon": Icons.business_center, "title": "Business"},
      {"icon": Icons.account_balance, "title": "Loans"},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      itemCount: categories.length,
      itemBuilder: (_, i) {
        return Column(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.deepPurple.shade100,
              child: Icon(
                categories[i]["icon"] as IconData,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 6),
            Text(categories[i]["title"] as String),
          ],
        );
      },
    );
  }

  // ================= TRENDING =================
  static Widget _trendingSchemes() {
    return const Column(
      children: [
        ListTile(title: Text("Scholarship Scheme")),
        ListTile(title: Text("Startup India")),
        ListTile(title: Text("Mudra Loan")),
      ],
    );
  }

  // ================= NAV BAR =================
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
      icon: Icon(icon, color: _currentIndex == index ? Colors.deepPurple : Colors.grey),
      onPressed: () => setState(() => _currentIndex = index),
    );
  }

  // ================= EXTRA =================
  static Widget _notificationsPage() {
    return const Center(child: Text("Notifications"));
  }

  // ================= LOCATION BUTTON =================
  Widget _locationButton() {
    return FloatingActionButton(
      backgroundColor: Colors.deepPurple,
      child: const Icon(Icons.location_on),
      onPressed: () => _openGovtMap(context),
    );
  }

  void _openGovtMap(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: const GovtMapScreen(),
      ),
    );
  }

  static Widget _sectionTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// ================= AD CARD =================
class _AdCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _AdCard(this.title, this.subtitle);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.deepPurple, Colors.deepPurpleAccent],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.poppins(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

// ================= MAP SCREEN =================
class GovtMapScreen extends StatefulWidget {
  const GovtMapScreen({super.key});

  @override
  State<GovtMapScreen> createState() => _GovtMapScreenState();
}

class _GovtMapScreenState extends State<GovtMapScreen> {
  final Set<Marker> _markers = {};

  static const LatLng _center = LatLng(10.8505, 76.2711); // Kerala center

  @override
  void initState() {
    super.initState();
    _loadGovtPlaces();
  }

  void _loadGovtPlaces() {
    final places = [
      {
        "name": "Police Station",
        "position": LatLng(10.8510, 76.2715),
        "icon": BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      },
      {
        "name": "Hospital",
        "position": LatLng(10.8490, 76.2720),
        "icon": BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      },
      {
        "name": "Akshaya Center",
        "position": LatLng(10.8520, 76.2730),
        "icon": BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      },
      {
        "name": "Janasena Office",
        "position": LatLng(10.8530, 76.2740),
        "icon": BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
      },
    ];

    for (var place in places) {
      _markers.add(Marker(
        markerId: MarkerId(place["name"].toString()),
        position: place["position"] as LatLng,
        infoWindow: InfoWindow(title: place["name"].toString()),
        icon: place["icon"] as BitmapDescriptor,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nearby Govt Places"),
        backgroundColor: Colors.deepPurple,
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: _center,
          zoom: 14,
        ),
        markers: _markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
