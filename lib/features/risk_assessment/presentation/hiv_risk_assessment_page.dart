import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/models/risk_question_model.dart';
import 'hiv_risk_result_page.dart';

class HivRiskAssessmentPage extends StatefulWidget {
  final String ageRange;
  const HivRiskAssessmentPage({super.key, required this.ageRange});

  @override
  State<HivRiskAssessmentPage> createState() => _HivRiskAssessmentPageState();
}

class _HivRiskAssessmentPageState extends State<HivRiskAssessmentPage> {
  int _currentIndex = 0;
  
  // Clinical Risk Questions
  final List<RiskQuestion> _questions = [
    RiskQuestion(question: "Have you had more than one sexual partner in the past 6 months?"),
    RiskQuestion(question: "Have you ever had sex in exchange for money, gifts, or other benefits?"),
    RiskQuestion(question: "Have you had sex without a condom with someone who is not your regular partner?"),
    RiskQuestion(question: "Have you had unprotected sex while under the influence of alcohol or drugs?"),
    RiskQuestion(question: "In the past 6 months, have you noticed unusual discharge or sores?"),
    RiskQuestion(question: "Have you ever experienced sexual violence or been forced to have sex?"),
    RiskQuestion(question: "Do you feel uncomfortable talking about sexual health with your partner?"),
  ];

  void _handleNavigation() {
    if (_questions[_currentIndex].answer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select an answer to continue"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_currentIndex < _questions.length - 1) {
      setState(() => _currentIndex++);
    } else {
      // Navigate to Result and remove assessment from stack
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HivRiskResultPage(
            questions: _questions,
            ageRange: widget.ageRange,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final question = _questions[_currentIndex];
    const Color primaryBlue = Color(0xFF005C8F);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A1220) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Disables default back button
        leading: _currentIndex == 0 
          ? IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: isDark ? Colors.white : primaryBlue),
              onPressed: () => Navigator.pop(context), // Back to Counseling Page
            ) 
          : null, // Arrow disappears after Question 1
        title: Text(
          "Health Assessment",
          style: GoogleFonts.poppins(
            color: isDark ? Colors.white : primaryBlue, 
            fontSize: 16, 
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: LinearProgressIndicator(
                value: (_currentIndex + 1) / _questions.length,
                borderRadius: BorderRadius.circular(10),
                minHeight: 8,
                backgroundColor: isDark ? Colors.white10 : primaryBlue.withOpacity(0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(primaryBlue),
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "QUESTION ${_currentIndex + 1} OF ${_questions.length}",
                      style: GoogleFonts.poppins(
                        fontSize: 13, 
                        fontWeight: FontWeight.w800, 
                        color: const Color(0xFF0F7ACF),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      question.question,
                      style: GoogleFonts.poppins(
                        fontSize: 24, 
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Options (Yes/No)
                    _buildOption("Yes", question.answer == true, 
                        () => setState(() => question.answer = true), isDark, primaryBlue),
                    const SizedBox(height: 16),
                    _buildOption("No", question.answer == false, 
                        () => setState(() => question.answer = false), isDark, primaryBlue),
                  ],
                ),
              ),
            ),
            
            // Bottom Action Buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // BACK TEXT: Only shows from Question 2 onwards
                  _currentIndex > 0 
                    ? TextButton(
                        onPressed: () => setState(() => _currentIndex--),
                        child: Text(
                          "BACK",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w900, 
                            color: isDark ? Colors.blue.shade300 : primaryBlue,
                            letterSpacing: 1.1,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
                    
                  ElevatedButton(
                    onPressed: _handleNavigation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 4,
                    ),
                    child: Text(
                      _currentIndex == _questions.length - 1 ? "FINISH" : "NEXT",
                      style: const TextStyle(
                        color: Colors.white, 
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(String label, bool isSelected, VoidCallback onTap, bool isDark, Color primary) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 22),
        width: double.infinity,
        decoration: BoxDecoration(
          color: isSelected ? primary : (isDark ? const Color(0xFF161D2C) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primary : (isDark ? Colors.white12 : Colors.black12),
            width: 2,
          ),
          boxShadow: isSelected ? [BoxShadow(color: primary.withOpacity(0.3), blurRadius: 12)] : [],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 18, 
              fontWeight: FontWeight.bold, 
              color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black87)
            ),
          ),
        ),
      ),
    );
  }
}