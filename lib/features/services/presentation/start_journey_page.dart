import 'package:flutter/material.dart';
import '../../../shared/models/clinic_model.dart';

class StartJourneyPage extends StatelessWidget {
  final Clinic clinic;

  const StartJourneyPage({
    super.key,
    required this.clinic,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final panelColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      body: Stack(
        children: [
          // 1. MOCK MAP BACKGROUND
          Container(
            color: const Color(0xFFE5E7EB), // Map gray color
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              children: [
                // Mock Map Grid Lines (just for visual effect)
                Positioned(top: 100, left: 0, right: 0, child: Divider(color: Colors.grey[300], thickness: 2)),
                Positioned(top: 300, left: 0, right: 0, child: Divider(color: Colors.grey[300], thickness: 2)),
                Positioned(left: 100, top: 0, bottom: 0, child: VerticalDivider(color: Colors.grey[300], thickness: 2)),
                
                // Clinic Location Marker (Center)
                const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                       Icon(Icons.location_on, size: 50, color: Colors.redAccent),
                    ],
                  ),
                ),
                
                // User Location Marker (Bottom Left)
                Positioned(
                  bottom: 350,
                  left: 40,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        border: Border.all(color: Colors.white, width: 2),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),

          // 2. BACK BUTTON (Floating)
          Positioned(
            top: 50,
            left: 16,
            child: CircleAvatar(
              backgroundColor: panelColor,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: textColor),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // 3. BOTTOM LOCATION PANEL
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: panelColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Route Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("22 min", style: TextStyle(color: Colors.green[700], fontSize: 24, fontWeight: FontWeight.bold)),
                          Text("12 km • Fastest route", style: TextStyle(color: isDark ? Colors.white60 : Colors.grey[600], fontSize: 14)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text("Heavy Traffic", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),

                  // Locations
                  _buildLocationRow(Icons.my_location, "Your Location", "Current Location", isDark),
                  const SizedBox(height: 16), // Dotted line would go here
                  _buildLocationRow(Icons.location_on, clinic.name, clinic.address, isDark, isDest: true),
                  
                  const SizedBox(height: 30),

                  // Start Navigation Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF005C8F),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        // Placeholder for backend navigation logic
                        ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text("Navigation starting... (Backend Pending)"))
                        );
                      },
                      icon: const Icon(Icons.navigation, color: Colors.white),
                      label: const Text("Start Navigation", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow(IconData icon, String title, String subtitle, bool isDark, {bool isDest = false}) {
    return Row(
      children: [
        Icon(icon, color: isDest ? Colors.redAccent : Colors.blue, size: 28),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
            Text(subtitle, style: TextStyle(fontSize: 13, color: isDark ? Colors.white54 : Colors.grey)),
          ],
        )
      ],
    );
  }
}