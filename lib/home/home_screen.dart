import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        title: Text(
          "UGSSA",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications, color: Colors.white, size: 28),
          )
        ],
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// -------------------------
            /// SEARCH BAR
            /// -------------------------
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search for schemes, services...",
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: Icon(Icons.search, color: Colors.deepPurple),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(15),
                ),
              ),
            ),

            SizedBox(height: 25),

            /// -------------------------
            /// QUICK ACTIONS
            /// -------------------------
            Text(
              "Quick Actions",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),

            SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _quickAction(Icons.account_balance, "Govt\nOffices"),
                _quickAction(Icons.description, "My Docs"),
                _quickAction(Icons.account_circle, "Profile"),
                _quickAction(Icons.support_agent, "Support"),
              ],
            ),

            SizedBox(height: 30),

            /// -------------------------
            /// CATEGORIES
            /// -------------------------
            Text(
              "Categories",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),

            SizedBox(height: 15),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              childAspectRatio: 1.2,
              physics: NeverScrollableScrollPhysics(),
              children: [
                _categoryCard(Icons.local_hospital, "Health Services"),
                _categoryCard(Icons.school, "Education"),
                _categoryCard(Icons.agriculture, "Farmer Schemes"),
                _categoryCard(Icons.apartment, "Housing"),
              ],
            ),

            SizedBox(height: 30),

            /// -------------------------
            /// GOVERNMENT SCHEMES CAROUSEL
            /// -------------------------
            Text(
              "Recommended Schemes",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),

            SizedBox(height: 12),

            SizedBox(
              height: 170,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _schemeCard(
                    "PM-KISAN",
                    "Financial support for farmers",
                  ),
                  _schemeCard(
                    "Ayushman Bharat",
                    "Free health insurance up to 5 lakhs",
                  ),
                  _schemeCard(
                    "PMAY",
                    "Affordable housing scheme",
                  ),
                ],
              ),
            ),

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// -------------------------------------------------------
  /// QUICK ACTION WIDGET
  /// -------------------------------------------------------
  Widget _quickAction(IconData icon, String title) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.deepPurple.shade100,
          child: Icon(icon, size: 30, color: Colors.deepPurple),
        ),
        SizedBox(height: 6),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  /// -------------------------------------------------------
  /// CATEGORY CARD
  /// -------------------------------------------------------
  Widget _categoryCard(IconData icon, String title) {
    return Container(
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 45, color: Colors.deepPurple),
          SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          )
        ],
      ),
    );
  }

  /// -------------------------------------------------------
  /// SCHEME CARD (CAROUSEL)
  /// -------------------------------------------------------
  Widget _schemeCard(String title, String subtitle) {
    return Container(
      width: 230,
      margin: EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple, Colors.deepPurpleAccent],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 8),

          Text(
            subtitle,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),

          Spacer(),

          Align(
            alignment: Alignment.bottomRight,
            child: Icon(Icons.arrow_forward_ios,
                color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }
}
