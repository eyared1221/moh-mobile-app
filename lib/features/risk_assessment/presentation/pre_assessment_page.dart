import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/widgets/top_header.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import 'hiv_risk_assessment_page.dart';

class PreAssessmentCounselingPage extends StatelessWidget {
  final String ageRange;
  const PreAssessmentCounselingPage({super.key, required this.ageRange});

  static const Color kMOHBlue = Color(0xFF005C8F);
  static const Color kMOHAccent = Color(0xFF0F7ACF);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color scaffoldBg = isDark ? const Color(0xFF0A1220) : const Color(0xFFF1F5F9);
    final Color cardBg = isDark ? const Color(0xFF161D2C) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color subTextColor = isDark ? Colors.white60 : Colors.black54;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context, isDark),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        _buildMOHLogo(isDark),
                        const SizedBox(height: 32),
                        _buildPanicPreventionCard(isDark),
                        const SizedBox(height: 20),
                        _buildSectionLabel("Understanding the Scale", isDark),
                        _buildGlassCard(
                          isDark: isDark,
                          cardBg: cardBg,
                          child: Column(
                            children: [
                              _riskIndicator(Colors.green, "LOW", "Everything looks good!", subTextColor),
                              _riskIndicator(Colors.orange, "MODERATE", "A few risks identified.", subTextColor),
                              _riskIndicator(Colors.red, "HIGH", "Action is recommended.", subTextColor),
                              Divider(height: 24, color: isDark ? Colors.white10 : Colors.black12),
                              Text(
                                "Results are based on your answers and are not a clinical diagnosis.",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(fontSize: 12, color: isDark ? Colors.white38 : Colors.black45, fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildSectionLabel("Confidentiality", isDark),
                        _buildGlassCard(
                          isDark: isDark,
                          cardBg: cardBg,
                          child: _privacyRow(Icons.lock_person_rounded, "Your Data is Private", "The MOH values your anonymity.", isDark, subTextColor),
                        ),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildStartButton(context, textColor),
        ],
      ),
      bottomNavigationBar: AppBottomNav(ageRange: ageRange, currentIndex: 0),
    );
  }

  // --- Helper Widgets (Cleaned up and optimized) ---
  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TopHeader(onBellTap: () {}),
          Row(
            children: [
              IconButton(icon: Icon(Icons.arrow_back_ios_new, size: 18, color: isDark ? Colors.white : kMOHBlue), onPressed: () => Navigator.pop(context)),
              Text("Counseling", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: isDark ? Colors.white : kMOHBlue)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMOHLogo(bool isDark) {
    return Column(
      children: [
        Container(
          height: 100, width: 100,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.05) : Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: kMOHBlue.withOpacity(0.1), blurRadius: 20)]),
          child: Image.asset('assets/images/logo.png', errorBuilder: (c, e, s) => const Icon(Icons.health_and_safety, size: 50, color: kMOHBlue)),
        ),
        const SizedBox(height: 16),
        Text("Ministry of Health", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : kMOHBlue)),
      ],
    );
  }

  Widget _buildPanicPreventionCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: isDark ? [const Color(0xFF2C1E00), const Color(0xFF161D2C)] : [Colors.orange.shade50, Colors.white], begin: Alignment.topLeft),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: isDark ? Colors.orange.withOpacity(0.2) : Colors.orange.shade100, width: 2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.favorite, color: Colors.orange, size: 20),
              const SizedBox(width: 12),
              Text("Stay Calm", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: isDark ? Colors.orange.shade300 : Colors.orange.shade900)),
            ],
          ),
          const SizedBox(height: 8),
          Text("Moderate or High results simply mean you may need support. We are here to help.", style: GoogleFonts.inter(fontSize: 14, color: isDark ? Colors.white70 : Colors.orange.shade900.withOpacity(0.8))),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text, bool isDark) => Container(alignment: Alignment.centerLeft, padding: const EdgeInsets.only(left: 4, bottom: 8), child: Text(text.toUpperCase(), style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w800, color: isDark ? Colors.white30 : Colors.black38, letterSpacing: 1.1)));

  Widget _buildGlassCard({required Widget child, required bool isDark, required Color cardBg}) => Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(24), border: Border.all(color: isDark ? Colors.white10 : Colors.transparent)), child: child);

  Widget _riskIndicator(Color color, String label, String desc, Color sub) => Row(children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 12), Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: color)), const SizedBox(width: 10), Expanded(child: Text(desc, style: GoogleFonts.inter(fontSize: 12, color: sub)))]);

  Widget _privacyRow(IconData icon, String title, String desc, bool isDark, Color sub) => Row(children: [Icon(icon, color: isDark ? Colors.blue.shade300 : kMOHBlue), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : kMOHBlue)), Text(desc, style: GoogleFonts.inter(fontSize: 12, color: sub))]))]);

  Widget _buildStartButton(BuildContext context, Color textColor) {
    return Positioned(
      bottom: 24, left: 24, right: 24,
      child: Container(
        height: 60,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: const LinearGradient(colors: [kMOHBlue, kMOHAccent])),
        child: ElevatedButton(
          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HivRiskAssessmentPage(ageRange: ageRange))),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
          child: Text("I Understand & Accept", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
    );
  }
}