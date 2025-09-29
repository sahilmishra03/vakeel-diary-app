import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vakeel_diary/Database/crud_operation.dart';
import 'package:vakeel_diary/widgets/bottom_nav_bar.dart';
import 'package:vakeel_diary/widgets/reusable_widgets.dart';

// --- THEME COLORS ---
const Color primaryBlue = Color(0xFF1A237E);
const Color offWhite = Color(0xFFF5F5F5);
const Color darkGray = Color(0xFF424242);

class ReadData extends StatelessWidget {
  const ReadData({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: offWhite, // Use the off-white background color
      appBar: AppBar(
        title: const Text(
          "All Cases", // A clearer title
          style: TextStyle(
            color: darkGray,
            fontWeight: FontWeight.bold,
            fontSize: 24, // Consistent font size with HomePage's AppBar
          ),
        ),
        centerTitle: true,
        backgroundColor: offWhite,
        elevation: 0, // A clean, flat app bar
        iconTheme: const IconThemeData(color: darkGray),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: CrudOperation().read(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: primaryBlue,
              ), // Use the primary theme color
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: darkGray),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "No cases found. 📝", // Clearer message with an emoji
                    style: TextStyle(
                      color: darkGray,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "You'll see all your cases here once you add them.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: darkGray, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          final cases = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            itemCount: cases.length,
            itemBuilder: (context, index) {
              final caseDoc = cases[index];
              final caseId = caseDoc.id;
              final data = caseDoc.data() as Map<String, dynamic>;

              return buildCaseCard(
                context,
                caseId,
                data,
                true,
              ); // Pass true to show the edit button
            },
          );
        },
      ),
      bottomNavigationBar: const BottomNavBar(selectedIndex: 2),
    );
  }
}
