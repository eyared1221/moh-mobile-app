import 'package:flutter/material.dart';
import '../models/clinic_model.dart';

class ClinicInfoCard extends StatelessWidget {
  final Clinic clinic;
  final VoidCallback onInfo, onDirection;

  const ClinicInfoCard({super.key, required this.clinic, required this.onInfo, required this.onDirection});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryBlue = Color(0xFF005C8F);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: isDark ? Colors.white10 : Colors.transparent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.local_hospital_rounded, color: primaryBlue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(clinic.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                    Text(clinic.address, style: TextStyle(color: isDark ? Colors.white60 : Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
              Text(clinic.distance, style: const TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon( // Added .icon
                  onPressed: onInfo,
                  icon: const Icon(Icons.info_outline_rounded, size: 18),
                  label: const Text('Details'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryBlue,
                    side: BorderSide(color: primaryBlue.withOpacity(0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon( // Added .icon
                  onPressed: onDirection,
                  icon: const Icon(Icons.directions_rounded, size: 18),
                  label: const Text('Directions'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}