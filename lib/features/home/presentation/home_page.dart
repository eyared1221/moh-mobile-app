import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:async';

// Internal Widget Imports
import '../../../shared/widgets/top_header.dart';
import '../../../shared/widgets/hero_banner.dart';
import '../../../shared/widgets/app_bottom_nav.dart';


// Screen Imports
import 'package:yegna_health/features/community/presentation/community_chat_page.dart';
import 'package:yegna_health/features/services/presentation/health_professionals_page.dart';
import 'package:yegna_health/features/risk_assessment/presentation/pre_assessment_page.dart';
import 'package:yegna_health/features/learning/presentation/hiv_description_page.dart';
class HomePage extends StatefulWidget {
  final String ageRange;
  final String? userName;
  const HomePage({super.key, required this.ageRange, this.userName});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isSendingSOS = false;
  int? _hoveredModuleIndex;
  int? _hoveredFeatureIndex;

  static const Map<String, List<String>> _ageModuleImages = {
    '10-14': ['assets/images/Hiv10g.jpg', 'assets/images/srh10g.jpg', 'assets/images/gbv10g.png', 'assets/images/hepit10g.jpg', 'assets/images/srt10g.png', 'assets/images/drug10g.png'],
    '15-19': ['assets/images/hivb15.png', 'assets/images/STDb15.png', 'assets/images/GBVb15.png', 'assets/images/hepb15.png', 'assets/images/SRHb15.png', 'assets/images/drubb15.png'],
    '20-24': ['assets/images/Aidsbbb.png', 'assets/images/stdb.png', 'assets/images/GBVB.png', 'assets/images/HBTB.png', 'assets/images/momb.png', 'assets/images/smokingb.png'],
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryBlue = const Color(0xFF005C8F);
    
    final images = _ageModuleImages[widget.ageRange] ?? _ageModuleImages['10-14']!;
    final titles = ['HIV/ AIDS', 'STIs', 'GBV Awareness', 'Hepatitis', 'SRH Services', 'Risk Check'];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A1220) : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildOriginalHeader(isDark),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSlantedHero(isDark),
                    _buildSectionTitle("Learning Modules", isDark),
                    _buildModuleGrid(images, titles, isDark),
                    const SizedBox(height: 10),
                    _buildSectionTitle("Yegna Features", isDark),
                    _buildDynamicFeatureList(isDark, primaryBlue),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(ageRange: widget.ageRange, currentIndex: 0),
    );
  }

  // --- HEADER WITH SMALL SOS ---
  Widget _buildOriginalHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(child: TopHeader(onBellTap: () {}, showThemeToggle: true)),
          const SizedBox(width: 12),
          GestureDetector(
            onLongPress: _triggerSOS,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 42, height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isSendingSOS ? Colors.orange : const Color(0xFFD32F2F),
                boxShadow: [
                  BoxShadow(color: Colors.red.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 3))
                ],
              ),
              child: Center(
                child: _isSendingSOS 
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("SOS", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- FIGMA STYLE SLANTED HERO (Great Slate Diagonal) ---
  Widget _buildSlantedHero(bool isDark) {
    return Center(
      child: Transform(
        transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateX(-0.06)..rotateY(0.03),
        alignment: Alignment.center,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          // SETTING AN APPROPRIATE HEIGHT FOR FIGMA LOOK
          constraints: const BoxConstraints(minHeight: 180), 
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark 
                ? [Colors.white.withOpacity(0.12), Colors.white.withOpacity(0.01)]
                : [const Color(0xFFFFFFFF), const Color(0xFFE2E8F0)], 
            ),
            border: Border.all(color: isDark ? Colors.white.withOpacity(0.15) : Colors.white, width: 2),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.08), blurRadius: 25, offset: const Offset(0, 12))
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: HeroBanner(
                title: widget.ageRange == '10-14' ? "Learn, Stay Safe, & Grow Healthy" : "Empower Your Health, Break Stigma",
                subtitle: "", 
                age: widget.ageRange,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- SECTION TITLE ---
  Widget _buildSectionTitle(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 25, 22, 12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w900,
          color: isDark ? Colors.white : const Color(0xFF1E293B),
        ),
      ),
    );
  }

  // --- MODULE GRID ---
  Widget _buildModuleGrid(List<String> images, List<String> titles, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 0, childAspectRatio: 0.82,
        ),
        itemBuilder: (context, index) => _buildModuleCard(titles[index], images[index], isDark, index),
      ),
    );
  }

  Widget _buildModuleCard(String title, String image, bool isDark, int index) {
    bool isPressed = _hoveredModuleIndex == index;
    return GestureDetector(
      onTapDown: (_) => setState(() => _hoveredModuleIndex = index),
      onTapUp: (_) => setState(() => _hoveredModuleIndex = null),
      onTap: () => _handleModuleTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 20),
        transform: Matrix4.identity()..scale(isPressed ? 0.95 : 1.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          // Subtle highlight on top for Dark Mode visibility
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.transparent),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(isDark ? 0.4 : 0.1), blurRadius: 12, offset: const Offset(0, 6))
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Positioned.fill(child: Image.asset(image, fit: BoxFit.cover)),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.05), const Color(0xFF005C8F).withOpacity(0.85)],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 12, left: 14, right: 14,
                child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- YEGNA FEATURES ---
  Widget _buildDynamicFeatureList(bool isDark, Color primary) {
    bool isChild = widget.ageRange == '10-14';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(children: [
        if (isChild) ...[
          _featTile(0, Icons.videogame_asset_outlined, "Learn with Fun", "Videos and games for you", primary, isDark, () {}),
          _featTile(1, Icons.extension_outlined, "Health Quiz", "Test your knowledge & win!", primary, isDark, () {}),
        ] else ...[
          _featTile(0, Icons.analytics_outlined, "Risk Assessment", "Private health screening", primary, isDark, () {
           Navigator.push(context, MaterialPageRoute( builder: (context) => PreAssessmentCounselingPage(ageRange: widget.ageRange), ),);}),
          _featTile(1, Icons.medical_services_outlined, "Ask a Professional", "Direct expert health advice", primary, isDark, () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => HealthProfessionalsPage(ageRange: widget.ageRange)));
          }),
          _featTile(2, Icons.forum_outlined, "Community Chat", "Safe peer discussion space", primary, isDark, () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => CommunityChatPage(ageRange: widget.ageRange)));
          }),
        ],
      ]),
    );
  }

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
          transform: Matrix4.identity()..translate(isHovered ? 8.0 : 0.0),
          decoration: BoxDecoration(
            color: isHovered 
                ? (isDark ? primary.withOpacity(0.2) : const Color(0xFFEDF2F7)) 
                : (isDark ? const Color(0xFF161D2C) : Colors.white),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: isHovered ? primary.withOpacity(0.4) : Colors.transparent, width: 1.5),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
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
            Icon(Icons.arrow_forward_ios, size: 14, color: isHovered ? primary : primary.withOpacity(0.3)),
          ]),
        ),
      ),
    );
  }

 void _handleModuleTap(int index) {
  HapticFeedback.mediumImpact();
  
  if (index == 0) {
    // We navigate to the single Unified Page and pass the ageRange
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => HIVDescriptionPage(ageRange: widget.ageRange),
      ),
    );
  }
}

  void _triggerSOS() {
    HapticFeedback.heavyImpact();
    setState(() => _isSendingSOS = true);
    Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isSendingSOS = false);
    });
  }
}
