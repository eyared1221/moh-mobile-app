import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import 'package:yegna_health/features/services/presentation/health_professionals_page.dart';
import 'package:yegna_health/features/services/presentation/clinic_page.dart';

class HivRiskResultPage extends StatefulWidget {
  final List<dynamic> questions;
  final String ageRange;

  const HivRiskResultPage({super.key, required this.questions, required this.ageRange});

  @override
  State<HivRiskResultPage> createState() => _HivRiskResultPageState();
}

class _HivRiskResultPageState extends State<HivRiskResultPage> {
  // Track which card is currently hovered
  int? _hoveredFeatureIndex;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final int score = widget.questions.where((q) => q.answer == true).length;
    final Color primaryBlue = const Color(0xFF005C8F);
    
    Color statusColor = score <= 1 ? Colors.green : (score <= 3 ? Colors.orange : Colors.red);
    String statusText = score <= 1 ? "Low Risk" : (score <= 3 ? "Moderate Risk" : "High Risk");

    String coolDownText = score <= 1 
      ? "You're doing great! Your habits show you care about your health. Keep staying informed and safe."
      : "Take a deep breath. Knowing your status is the first step to staying healthy. We are here to support you every step of the way.";

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A1220) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: isDark ? Colors.white : primaryBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Your Result", 
          style: GoogleFonts.poppins(color: isDark ? Colors.white : primaryBlue, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Center(child: _buildResultCircle(statusColor, statusText)),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: statusColor.withOpacity(0.2))
                  ),
                  child: Text(
                    coolDownText,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14, 
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white70 : Colors.black87,
                      height: 1.5
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(22, 10, 22, 12),
                child: Text("Recommended Next Steps", 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: isDark ? Colors.white : const Color(0xFF1E293B))),
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  children: [
                    _featTile(0, Icons.location_on_outlined, "Find a Clinic", "Locate nearest health center", primaryBlue, isDark, () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ClinicPage(ageRange: widget.ageRange)));
                    }),
                    _featTile(1, Icons.medical_services_outlined, "Ask a Professional", "Direct expert health advice", primaryBlue, isDark, () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => HealthProfessionalsPage(ageRange: widget.ageRange)));
                    }),
                    _featTile(2, Icons.smart_toy_outlined, "AI Health Chatbot", "Instant answers (Coming soon)", Colors.purple, isDark, () {
                      // Future Chatbot Logic
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(ageRange: widget.ageRange, currentIndex: -1),
    );
  }

  Widget _buildResultCircle(Color color, String text) {
    return Container(
      height: 140, width: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle, 
        color: color.withOpacity(0.1), 
        border: Border.all(color: color, width: 6),
        boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 20)]
      ),
      child: Center(
        child: Text(text.toUpperCase(), textAlign: TextAlign.center, 
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w900, color: color)),
      ),
    );
  }

  // UPDATED: Now includes index and Hover/Animation logic same as Home Page
  Widget _featTile(int index, IconData icon, String title, String sub, Color primary, bool isDark, VoidCallback onTap) {
    bool isHovered = _hoveredFeatureIndex == index;

    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hoveredFeatureIndex = index),
        onExit: (_) => setState(() => _hoveredFeatureIndex = null),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          // Slides to the right by 8 pixels when hovered
          transform: Matrix4.identity()..translate(isHovered ? 8.0 : 0.0),
          decoration: BoxDecoration(
            color: isHovered 
                ? (isDark ? primary.withOpacity(0.2) : const Color(0xFFEDF2F7)) 
                : (isDark ? const Color(0xFF161D2C) : Colors.white),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: isHovered ? primary.withOpacity(0.4) : Colors.transparent, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isHovered ? 0.08 : 0.04), 
                blurRadius: 10, 
                offset: const Offset(0, 4)
              )
            ],
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isHovered ? primary : primary.withOpacity(0.1), 
                borderRadius: BorderRadius.circular(15)
              ),
              child: Icon(icon, color: isHovered ? Colors.white : primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: isDark ? Colors.white : Colors.black87)),
              Text(sub, style: TextStyle(fontSize: 12, color: isDark ? Colors.blueGrey[200] : Colors.blueGrey)),
            ])),
            // The arrow icon also highlights on hover
            Icon(Icons.arrow_forward_ios, size: 14, color: isHovered ? primary : primary.withOpacity(0.3)),
          ]),
        ),
      ),
    );
  }
}
