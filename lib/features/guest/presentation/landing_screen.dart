import 'package:flutter/material.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../../../shared/widgets/logo_header.dart';
import '../../../shared/widgets/primary_button.dart';
import 'guest_page.dart';



class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  String _selectedLanguage = 'English';
  final List<String> _languages = ['English', 'Amharic'];

  

  Widget _vSpace(double h) => SizedBox(height: h);

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenWidth = mq.size.width;
    final screenHeight = mq.size.height;

    void navigateToGuest(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GuestPage()),
    );
  }

    return Scaffold(
      body: GradientBackground(
        decorAsset: 'assets/images/telescop.png',
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.06,
              vertical: screenHeight * 0.06,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Language selector
                Row(
                  children: [
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(255, 255, 255, 0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedLanguage,
                        underline: const SizedBox(),
                        items: _languages
                            .map(
                              (l) => DropdownMenuItem(value: l, child: Text(l)),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setState(() => _selectedLanguage = v);
                          }
                        },
                      ),
                    ),
                  ],
                ),

                _vSpace(screenHeight * 0.04),

                // Logo & Titles
                LogoHeader(
                  logoAsset: 'assets/images/logo.png',
                  title: 'Yegna Health',
                  subtitle: 'Together for Better Health',
                  logoSize: screenWidth * 0.25,
                  titleFontSize: screenWidth * 0.07,
                  subtitleFontSize: screenWidth * 0.04,
                ),

                _vSpace(screenHeight * 0.12),

                // Main Button
                PrimaryButton(
                  label: 'Start Your Health Journey',
                  width: screenWidth * 0.85,
                  onPressed: () => navigateToGuest(context),
                ),

                _vSpace(screenHeight * 0.04),
              
              ],
            ),
          ),
        ),
      ),
    );
  }
}
