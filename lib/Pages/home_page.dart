import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vakeel_diary/Database/crud_operation.dart';
import 'package:vakeel_diary/widgets/bottom_nav_bar.dart';
import 'package:vakeel_diary/widgets/reusable_widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The Scaffold widget automatically handles extending the background
      // color to the edges of the screen, including the "safe area"
      // where the gesture bar is located.
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text(
          "Today's Cases",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: CrudOperation().readTodayCases(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.black),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No cases scheduled for today.",
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
            );
          }
          final cases = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: cases.length,
            itemBuilder: (context, index) {
              final caseDoc = cases[index];
              final caseId = caseDoc.id;
              final data = caseDoc.data() as Map<String, dynamic>;
              return buildCaseCard(context, caseId, data, false);
            },
          );
        },
      ),
      // This is the correct place for your bottom navigation bar.
      // Placing it within the Scaffold's bottomNavigationBar property
      // ensures it is correctly positioned and its background extends
      // to the bottom of the screen.
      bottomNavigationBar: const BottomNavBar(selectedIndex: 0),
    );
  }
}