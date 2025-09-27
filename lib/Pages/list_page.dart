import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vakeel_diary/Database/crud_operation.dart';
import 'package:vakeel_diary/Pages/add_case_page.dart';
import 'package:vakeel_diary/Pages/home_page.dart';

class ReadData extends StatefulWidget {
  const ReadData({super.key});

  @override
  State<ReadData> createState() => _ReadDataState();
}

class _ReadDataState extends State<ReadData> {
  int _selectedIndex = 2; // Index for the current page

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AddCasePage()),
        );
        break;
      case 2:
        // Already on ReadData page
        break;
    }
  }

  // A method to show a dialog with all case details.
  void _showCaseDetailsDialog(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            data['CaseTitleAttribute'] ?? 'Case Details',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow("Case Number:", data['CaseNumberAttribute']),
                _buildDetailRow("Court Name:", data['CourtNameAttribute']),
                _buildDetailRow("Judge Name:", data['JudgeNameAttribute']),
                _buildDetailRow(
                  "Previous Date:",
                  data['PreviousDateAttribute'] != null
                      ? DateFormat('dd/MM/yyyy').format(
                          (data['PreviousDateAttribute'] as Timestamp).toDate(),
                        )
                      : 'N/A',
                ),
                _buildDetailRow(
                  "Next Date:",
                  data['NextDateAttribute'] != null
                      ? DateFormat('dd/MM/yyyy').format(
                          (data['NextDateAttribute'] as Timestamp).toDate(),
                        )
                      : 'N/A',
                ),
                const SizedBox(height: 16),
                const Text(
                  "Notes:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  data['NotesAttribute'] ?? 'N/A',
                  style: const TextStyle(color: Colors.black87),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close", style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87),
          children: [
            TextSpan(
              text: label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: " $value"),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("View Cases", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: CrudOperation().read(),
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
                "No cases found.",
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

              final caseTitle = data['CaseTitleAttribute'] ?? 'N/A';
              final caseNumber = data['CaseNumberAttribute'] ?? 'N/A';
              final courtName = data['CourtNameAttribute'] ?? 'N/A';
              final nextDate = (data['NextDateAttribute'] as Timestamp)
                  .toDate();

              return Dismissible(
                key: Key(caseId),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(
                    Icons.delete_forever,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                onDismissed: (direction) {
                  CrudOperation().delete(caseId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("$caseTitle dismissed")),
                  );
                },
                child: GestureDetector(
                  onLongPress: () => _showCaseDetailsDialog(data),
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        caseTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            "Case No: $caseNumber",
                            style: const TextStyle(color: Colors.black87),
                          ),
                          Text(
                            "Court: $courtName",
                            style: const TextStyle(color: Colors.black87),
                          ),
                          Text(
                            "Next Date: ${DateFormat('dd/MM/yyyy').format(nextDate)}",
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueAccent),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddCasePage(
                                caseId: caseId,
                                initialData: data,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add'),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'View All',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        onTap: _onItemTapped,
      ),
    );
  }
}
