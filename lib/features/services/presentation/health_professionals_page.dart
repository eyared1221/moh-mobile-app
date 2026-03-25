import 'package:flutter/material.dart';
import '../../../shared/widgets/top_header.dart';
import '../../../shared/widgets/app_bottom_nav.dart';

class HealthProfessionalsPage extends StatefulWidget {
  final String ageRange;

  const HealthProfessionalsPage({
    super.key,
    required this.ageRange,
  });

  @override
  State<HealthProfessionalsPage> createState() =>
      _HealthProfessionalsPageState();
}

class _HealthProfessionalsPageState extends State<HealthProfessionalsPage> {
  String searchQuery = '';
  final _searchController = TextEditingController();

  final List<Map<String, dynamic>> doctors = [
    {
      'name': 'Dr. Sara Mekonnen',
      'image': 'assets/images/doc0.png',
      'specialties': ['HIV', 'SRH'],
      'experience': '2+ years experience in counseling',
      'availability': 'Mon–Fri | 9:00–12:00',
    },
    {
      'name': 'Dr. Daniel Tesfaye',
      'image': 'assets/images/doctor2.png',
      'specialties': ['GBV', 'Mental Health'],
      'experience': '4+ years experience in counseling',
      'availability': 'Tue–Sat | 1:00–4:00',
    },
    {
      'name': 'Dr. Hana Alemu',
      'image': 'assets/images/doctor3.png',
      'specialties': ['Hepatitis', 'HIV'],
      'experience': '3+ years experience in counseling',
      'availability': 'Mon–Thu | 10:00–1:00',
    },
    {
      'name': 'Dr. Yohannes Bekele',
      'image': 'assets/images/doctor4.png',
      'specialties': ['Drug Effects', 'Addiction'],
      'experience': '5+ years experience in counseling',
      'availability': 'Wed–Sun | 2:00–6:00',
    },
    {
      'name': 'Dr. Selamawit Kebede',
      'image': 'assets/images/doctor5.png',
      'specialties': ['SRH', 'GBV'],
      'experience': '2+ years experience in counseling',
      'availability': 'Mon–Fri | 8:00–11:00',
    },
    {
      'name': 'Dr. Abebe Girma',
      'image': 'assets/images/badb.png',
      'specialties': ['HIV', 'Community Health'],
      'experience': '6+ years experience in counseling',
      'availability': 'Sat–Sun | 9:00–1:00',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredDoctors = doctors.where((doctor) {
      final name = doctor['name'].toLowerCase();
      final specialties =
          (doctor['specialties'] as List).join(' ').toLowerCase();
      final query = searchQuery.toLowerCase();

      return name.contains(query) || specialties.contains(query);
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: TopHeader(showBack: true),
            ),

            // Search bar with focus styling
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Focus(
                onFocusChange: (_) => setState(() {}),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() {
                    searchQuery = value;
                  }),
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search doctors or professionals',
                    hintStyle: const TextStyle(fontSize: 13),
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: Colors.white,
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF005C8F),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: filteredDoctors.isEmpty
                  ? const Center(
                      child: Text(
                        'No doctors found',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: filteredDoctors.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.78,
                      ),
                      itemBuilder: (context, index) {
                        return _animatedDoctorCard(
                            filteredDoctors[index], index);
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        ageRange: widget.ageRange,
        currentIndex: 1,
      ),
    );
  }

  // Slower fade + scale animation for noticeable effect
  Widget _animatedDoctorCard(Map<String, dynamic> doctor, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.7, end: 1),
      duration: Duration(milliseconds: 700 + index * 150),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(scale: value, child: child),
        );
      },
      child: _doctorCard(doctor),
    );
  }

  Widget _doctorCard(Map<String, dynamic> doctor) {
    return Card(
      elevation: 6,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundImage: AssetImage(doctor['image']),
            ),
            const SizedBox(height: 10),
            Text(
              doctor['name'],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              doctor['experience'],
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              alignment: WrapAlignment.center,
              children: (doctor['specialties'] as List)
                  .map<Widget>(
                    (s) => Chip(
                      label: Text(
                        s,
                        style: const TextStyle(fontSize: 11, color: Colors.black87),
                      ),
                      backgroundColor: Colors.grey.shade300,
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 0),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 6),
            Text(
              doctor['availability'],
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.video_call, size: 18),
                label: const Text(
                  'Book Meeting',
                  style: TextStyle(fontSize: 13),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: const Color(0xFF005C8F),
                ),
                onPressed: () => _showEmailDialog(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmailDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Enter your email'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(hintText: 'example@email.com'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // 🔗 Send to backend
              Navigator.pop(context);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
