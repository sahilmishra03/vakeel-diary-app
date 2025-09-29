import 'package:flutter/material.dart';
import 'package:vakeel_diary/Database/crud_operation.dart';
import 'package:vakeel_diary/Pages/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vakeel_diary/widgets/reusable_widgets.dart';
import 'package:vakeel_diary/widgets/bottom_nav_bar.dart';

// --- THEME COLORS ---
const Color primaryBlue = Color(0xFF1A237E);
const Color offWhite = Color(0xFFF5F5F5);
const Color darkGray = Color(0xFF424242);
const Color lightGray = Color(0xFFE0E0E0);

class AddCasePage extends StatefulWidget {
  final String? caseId;
  final Map<String, dynamic>? initialData;

  const AddCasePage({super.key, this.caseId, this.initialData});

  @override
  State<AddCasePage> createState() => _AddCasePageState();
}

class _AddCasePageState extends State<AddCasePage> {
  final TextEditingController _caseTitleController = TextEditingController();
  final TextEditingController _caseNumberController = TextEditingController();
  final TextEditingController _courtNameController = TextEditingController();
  final TextEditingController _judgeNameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime? _previousDate;
  DateTime? _nextDate;
  bool _isPressed = false; // New state variable for button animation

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _caseTitleController.text =
          widget.initialData!['CaseTitleAttribute'] ?? '';
      _caseNumberController.text =
          widget.initialData!['CaseNumberAttribute'] ?? '';
      _courtNameController.text =
          widget.initialData!['CourtNameAttribute'] ?? '';
      _judgeNameController.text =
          widget.initialData!['JudgeNameAttribute'] ?? '';
      _notesController.text = widget.initialData!['NotesAttribute'] ?? '';
      if (widget.initialData!['PreviousDateAttribute'] != null) {
        _previousDate =
            (widget.initialData!['PreviousDateAttribute'] as Timestamp)
                .toDate();
      }
      if (widget.initialData!['NextDateAttribute'] != null) {
        _nextDate = (widget.initialData!['NextDateAttribute'] as Timestamp)
            .toDate();
      }
    }
  }

  @override
  void dispose() {
    _caseTitleController.dispose();
    _caseNumberController.dispose();
    _courtNameController.dispose();
    _judgeNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isPreviousDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isPreviousDate
          ? _previousDate ?? DateTime.now()
          : _nextDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryBlue,
              onPrimary: offWhite,
              onSurface: darkGray,
            ),
            dialogTheme: const DialogThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isPreviousDate) {
          _previousDate = picked;
        } else {
          _nextDate = picked;
        }
      });
    }
  }

  void _submitData() async {
    if (_caseTitleController.text.isEmpty ||
        _caseNumberController.text.isEmpty ||
        _courtNameController.text.isEmpty ||
        _judgeNameController.text.isEmpty ||
        _previousDate == null ||
        _nextDate == null ||
        _notesController.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in all fields."),
          backgroundColor: primaryBlue,
        ),
      );
      return;
    }

    if (!mounted) return;

    if (widget.caseId != null) {
      await CrudOperation().update(
        widget.caseId!,
        _caseTitleController.text,
        _caseNumberController.text,
        _courtNameController.text,
        _judgeNameController.text,
        _previousDate!,
        _nextDate!,
        _notesController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Case updated successfully!")),
      );
    } else {
      await CrudOperation().create(
        _caseTitleController.text,
        _caseNumberController.text,
        _courtNameController.text,
        _judgeNameController.text,
        _previousDate!,
        _nextDate!,
        _notesController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Case added successfully!")));
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isUpdateMode = widget.caseId != null;

    return Scaffold(
      backgroundColor: offWhite,
      appBar: AppBar(
        title: Text(
          isUpdateMode ? "Update Case" : "Add New Case",
          style: const TextStyle(
            color: darkGray,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: offWhite,
        elevation: 0,
        iconTheme: const IconThemeData(color: darkGray),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isUpdateMode
                  ? "Update the case details."
                  : "Enter the case details to add a new record.",
              style: const TextStyle(color: darkGray, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            buildTextField("Case Title", _caseTitleController),
            const SizedBox(height: 24),
            buildTextField(
              "Case Number",
              _caseNumberController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            buildTextField("Court Name", _courtNameController),
            const SizedBox(height: 24),
            buildTextField("Judge Name", _judgeNameController),
            const SizedBox(height: 24),
            buildDateField(
              "Previous Hearing Date",
              _previousDate,
              () => _selectDate(context, true),
            ),
            const SizedBox(height: 24),
            buildDateField(
              "Next Hearing Date",
              _nextDate,
              () => _selectDate(context, false),
            ),
            const SizedBox(height: 24),
            buildTextField("Notes", _notesController, maxLines: 5),
            const SizedBox(height: 48),
            GestureDetector(
              onTapDown: (_) => setState(() => _isPressed = true),
              onTapUp: (_) => setState(() => _isPressed = false),
              onTapCancel: () => setState(() => _isPressed = false),
              onTap: _submitData,
              child: AnimatedScale(
                scale: _isPressed ? 0.95 : 1.0,
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeInOut,
                child: ElevatedButton(
                  onPressed: _submitData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: offWhite,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Text(isUpdateMode ? "UPDATE" : "SUBMIT"),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(selectedIndex: 1),
    );
  }
}
