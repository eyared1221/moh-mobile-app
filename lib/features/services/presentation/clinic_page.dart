import 'package:flutter/material.dart';
import '../../../shared/models/clinic_model.dart';
import '../../../shared/data/clinic_data.dart';
import '../../../shared/widgets/top_header.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../../../shared/widgets/clinic_info_card.dart';
import 'clinic_detail_page.dart';
import 'start_journey_page.dart';

class ClinicPage extends StatefulWidget {
  final String ageRange;
  const ClinicPage({super.key, required this.ageRange});

  @override
  State<ClinicPage> createState() => _ClinicPageState();
}

class _ClinicPageState extends State<ClinicPage> {
  String _selectedService = 'All';
  String _search = '';
  final List<String> services = ['All', 'HIV', 'SRH', 'GBV', 'Hepatitis', 'Drug Risk'];

  List<Clinic> get filteredClinics => clinicList.where((c) {
    final matchesService = _selectedService == 'All' || c.services.contains(_selectedService);
    final matchesSearch = c.name.toLowerCase().contains(_search.toLowerCase());
    return matchesService && matchesSearch;
  }).toList();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryBlue = Color(0xFF005C8F);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // --- CONSISTENT BACK NAVIGATION HEADER ---
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new, 
                      color: isDark ? Colors.white : primaryBlue,
                      size: 22,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: TopHeader(showBack: false),
                  ),
                ],
              ),
            ),
            
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged: (v) => setState(() => _search = v),
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  hintText: 'Search clinics...',
                  prefixIcon: const Icon(Icons.search, color: primaryBlue),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: isDark ? Colors.transparent : Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: primaryBlue, width: 2),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            
            // Filters (ChoiceChips)
            SizedBox(
              height: 40,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: services.length,
                itemBuilder: (context, i) {
                  final active = services[i] == _selectedService;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(services[i]),
                      selected: active,
                      onSelected: (_) => setState(() => _selectedService = services[i]),
                      selectedColor: primaryBlue,
                      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.grey.shade200,
                      labelStyle: TextStyle(
                        color: active ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  );
                },
              ),
            ),

            // Clinic Cards List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: filteredClinics.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, i) {
                  return TweenAnimationBuilder(
                    duration: Duration(milliseconds: 350 + (i * 100)),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, double value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 30 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: ClinicInfoCard(
                      clinic: filteredClinics[i],
                      onInfo: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ClinicDetailPage(clinic: filteredClinics[i], ageRange: widget.ageRange))),
                      onDirection: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StartJourneyPage(clinic: filteredClinics[i]))),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(ageRange: widget.ageRange, currentIndex: 1),
    );
  }
}