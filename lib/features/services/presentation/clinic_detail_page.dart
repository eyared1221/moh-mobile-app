import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for Clipboard
import '../../../shared/models/clinic_model.dart';
import '../../../shared/widgets/top_header.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import 'start_journey_page.dart';

class ClinicDetailPage extends StatelessWidget {
  final Clinic clinic;
  final String ageRange;

  const ClinicDetailPage({super.key, required this.clinic, required this.ageRange});

  // Function to handle the copy logic
  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    
    // Show a clean, modern snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF005C8F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1C1E);
    final subTextColor = isDark ? Colors.white70 : Colors.grey[600];
    const primaryBlue = Color(0xFF005C8F);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      bottomNavigationBar: AppBottomNav(ageRange: ageRange, currentIndex: 1),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : primaryBlue),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(child: TopHeader(showBack: false)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(clinic.name, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: textColor)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: primaryBlue),
                        const SizedBox(width: 4),
                        Text(clinic.address, style: TextStyle(color: subTextColor, fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset(clinic.imageUrl, height: 220, width: double.infinity, fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 24),

                    Text('About Facility', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                    const SizedBox(height: 8),
                    Text(
                      "${clinic.description} This facility offers comprehensive youth-friendly healthcare. Our mission is to provide accessible, confidential, and professional medical support to the community.",
                      style: TextStyle(fontSize: 15, color: subTextColor, height: 1.5),
                    ),
                    
                    const SizedBox(height: 20),

                    // CONTACT LINKS CARD WITH COPY FEATURE
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          _buildContactTile(
                            context,
                            Icons.phone_rounded, 
                            "Phone", 
                            "+251 911 00 00 00", 
                            Colors.green, 
                            isDark
                          ),
                          Divider(height: 1, indent: 60, color: isDark ? Colors.white10 : Colors.grey.shade100),
                          _buildContactTile(
                            context,
                            Icons.language_rounded, 
                            "Website", 
                            "www.health.gov.et", 
                            primaryBlue, 
                            isDark
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    Text('Services Offered', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8, runSpacing: 10,
                      children: clinic.services.map((s) => _buildChip(s, isDark)).toList(),
                    ),
                    const SizedBox(height: 32),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StartJourneyPage(clinic: clinic))),
                        icon: const Icon(Icons.directions_outlined, color: Colors.white),
                        label: const Text('GET DIRECTIONS', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactTile(BuildContext context, IconData icon, String label, String value, Color color, bool isDark) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
      subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      trailing: const Icon(Icons.copy_rounded, size: 18, color: Colors.grey), // Changed icon to "copy"
      onTap: () => _copyToClipboard(context, value, label), // Trigger copy on tap
    );
  }

  Widget _buildChip(String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF005C8F).withOpacity(0.1)),
      ),
      child: Text(label, style: const TextStyle(color: Color(0xFF005C8F), fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }
}