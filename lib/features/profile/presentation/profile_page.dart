import 'dart:io' show File;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/widgets/top_header.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../../../core/theme/theme_notifier.dart';
import 'package:yegna_health/features/auth/presentation/signin_screen.dart';

const _kPrimary = Color(0xFF0072C6);

class ProfilePage extends StatefulWidget {
  final String ageRange;
  final String? userName;
  final String? language;

  const ProfilePage({
    super.key,
    required this.ageRange,
    this.userName,
    this.language,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _GuestProfileGate extends StatelessWidget {
  const _GuestProfileGate();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryBlue = Color(0xFF005C8F);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const TopHeader(showThemeToggle: true),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161D2C) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.25 : 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_outline, size: 44, color: isDark ? Colors.white70 : primaryBlue),
                const SizedBox(height: 10),
                Text(
                  "Sign in to access your profile",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Sign in to save your info and personalize your experience.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.4,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignInScreen())),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text("SIGN IN", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _userNameController;
  bool _isEditing = false;
  late String _selectedLanguage;
  bool _isLoggedIn = true;
  bool _authChecked = false;
  
  Uint8List? _webImage;
  XFile? _mobileImage;

  final List<String> _languages = ['English', 'Amharic'];

  @override
  void initState() {
    super.initState();
    // Initialize with the passed name, or a default
    _userNameController = TextEditingController(text: widget.userName ?? 'User Name');
    _selectedLanguage = widget.language ?? 'English';
    _loadSavedData();
    _loadAuthStatus();
  }

  // FRONTEND LOGIC: Load data from phone storage
  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userNameController.text = prefs.getString('userName') ?? _userNameController.text;
      _selectedLanguage = prefs.getString('language') ?? _selectedLanguage;
    });
  }

  Future<void> _loadAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      _authChecked = true;
    });
  }

  // FRONTEND LOGIC: Save data to phone storage
  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _userNameController.text);
    await prefs.setString('language', _selectedLanguage);
    
    setState(() => _isEditing = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile Updated Successfully!"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _userNameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (image != null) {
      if (kIsWeb) {
        _webImage = await image.readAsBytes();
      } else {
        _mobileImage = image;
      }
      setState(() {});
    }
  }

  ImageProvider? _profileImage() {
    if (kIsWeb && _webImage != null) return MemoryImage(_webImage!);
    if (!kIsWeb && _mobileImage != null) return FileImage(File(_mobileImage!.path));
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (!_authChecked) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isLoggedIn) {
      return const _GuestProfileGate();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 90,
        title: Row(
          children: [
            const Expanded(child: TopHeader(showThemeToggle: false)),
            const SizedBox(width: 12),
            _buildLogoutButton(context),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildProfileAvatar(isDark),
                  const SizedBox(height: 20),
                  _buildNameSection(textColor),
                  const SizedBox(height: 16),
                  _buildEditButton(),
                  const SizedBox(height: 30),
                  
                  // Section 1: Core Info
                  _buildSectionCard(context, child: Column(
                    children: [
                      _infoRow(context, 'Account Age Range', widget.ageRange, Icons.calendar_today_rounded),
                      _customDivider(context),
                      _languageDropdown(context),
                    ],
                  )),

                  const SizedBox(height: 16),

                  // Section 2: Appearance
                  _buildSectionCard(context, child: _buildThemeToggle(context)),

                  const SizedBox(height: 16),

                  // Section 3: Privacy & Support
                  _buildSectionCard(context, child: Column(
                    children: [
                      _settingTile(context, Icons.security_rounded, 'Privacy & Security'),
                      _customDivider(context),
                      _settingTile(context, Icons.notifications_none_rounded, 'Notifications'),
                      _customDivider(context),
                      _settingTile(context, Icons.help_outline_rounded, 'Help & Support'),
                    ],
                  )),
                  
                  const SizedBox(height: 30),
                  Text("Version 1.0.0", style: TextStyle(color: Colors.grey.withOpacity(0.5), fontSize: 12)),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        ageRange: widget.ageRange,
        currentIndex: 3,
      ),
    );
  }

  // --- UI COMPONENT METHODS ---

  Widget _buildLogoutButton(BuildContext context) {
    return InkWell(
      onTap: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', false);
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
        ),
        child: const Row(
          children: [
            Icon(Icons.power_settings_new_rounded, color: Colors.redAccent, size: 20),
            SizedBox(width: 8),
            Text("Logout", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(bool isDark) {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _kPrimary, width: 2.5),
              ),
              child: CircleAvatar(
                radius: 65,
                backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.grey[200],
                backgroundImage: _profileImage(),
                child: _profileImage() == null
                    ? Icon(Icons.person_rounded, size: 70, color: _kPrimary.withOpacity(0.3))
                    : null,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _kPrimary,
                shape: BoxShape.circle,
                border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 3),
              ),
              child: const Icon(Icons.camera_alt_rounded, size: 20, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameSection(Color textColor) {
    if (_isEditing) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50),
        child: TextField(
          controller: _userNameController,
          textAlign: TextAlign.center,
          autofocus: true,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
          decoration: const InputDecoration(hintText: "Full Name"),
        ),
      );
    }
    return Text(
      _userNameController.text,
      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: textColor),
    );
  }

  Widget _buildEditButton() {
    return SizedBox(
      width: 170,
      child: ElevatedButton.icon(
        onPressed: () {
          if (_isEditing) {
            _saveProfile(); // Frontend Logic: Save to storage
          } else {
            setState(() => _isEditing = true);
          }
        },
        icon: Icon(_isEditing ? Icons.check_circle_outline : Icons.edit_note_rounded),
        label: Text(_isEditing ? "SAVE" : "EDIT PROFILE"),
        style: ElevatedButton.styleFrom(
          backgroundColor: _isEditing ? Colors.green : _kPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        final currentIsDark = mode == ThemeMode.dark || 
                             (mode == ThemeMode.system && Theme.of(context).brightness == Brightness.dark);
        return SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: const Text("Dark Appearance", style: TextStyle(fontWeight: FontWeight.bold)),
          secondary: Icon(currentIsDark ? Icons.bedtime_rounded : Icons.wb_sunny_rounded, 
                         color: currentIsDark ? Colors.amber : Colors.orange),
          value: currentIsDark,
          onChanged: (_) => toggleTheme(),
        );
      },
    );
  }

  // --- UTILITY WIDGETS ---

  Widget _buildSectionCard(BuildContext context, {required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: child,
    );
  }

  Widget _infoRow(BuildContext context, String title, String value, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(icon, color: _kPrimary, size: 22),
        const SizedBox(width: 15),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black87)),
        ]),
      ],
    );
  }

  Widget _languageDropdown(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        const Icon(Icons.translate_rounded, color: _kPrimary, size: 22),
        const SizedBox(width: 15),
        Expanded(
          child: DropdownButton<String>(
            value: _selectedLanguage,
            isExpanded: true,
            dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            underline: const SizedBox(),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black87),
            items: _languages.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
            onChanged: (v) { if (v != null) setState(() => _selectedLanguage = v); },
          ),
        ),
      ],
    );
  }

  Widget _settingTile(BuildContext context, IconData icon, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: isDark ? Colors.white70 : Colors.black54),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
      onTap: () {},
    );
  }

  Widget _customDivider(BuildContext context) {
    return Divider(height: 20, color: Theme.of(context).dividerColor.withOpacity(0.1));
  }
}
