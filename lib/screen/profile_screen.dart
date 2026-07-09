import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import 'setting_screen.dart';
import 'login_screen.dart';
import 'help_center_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  String _userName = 'Pengguna';
  String _userEmail = '';
  String _avatarUrl = '';
  int _remainingScans = 0;
  bool _isPremium = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse('http://10.125.36.208:3000/api/user/status'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        setState(() {
          _userName = data['name'] ?? 'Pengguna';
          _userEmail = data['email'] ?? '';
          _avatarUrl = data['avatar_url'] ?? '';
          _remainingScans = data['remaining_scans'] ?? 0;
          _isPremium = data['is_premium'] ?? false;
        });
      }
    } catch (e) {
      print("Error fetching user data in Profile: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String tipeAkunText = _isPremium ? "Premium (Unlimited)" : "Gratis (Sisa $_remainingScans/5)";
    Color statusColor = _isPremium ? AppColors.primary : Colors.amber;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : RefreshIndicator(
                onRefresh: _fetchUserData,
                color: AppColors.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
                  child: Column(
                    children: [
                      // --- 1. FOTO PROFIL ---
                      Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey.shade300,
                              backgroundImage: _avatarUrl.isNotEmpty ? NetworkImage(_avatarUrl) : null,
                              child: _avatarUrl.isEmpty
                                  ? const Icon(Icons.person, size: 50, color: Colors.white)
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.dark,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.background, width: 2),
                                ),
                                child: const Icon(Icons.camera_alt, color: AppColors.primary, size: 18),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // --- 2. NAMA DAN STATUS ---
                      Text(
                        _userName,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark),
                      ),
                      if (_userEmail.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            _userEmail,
                            style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
                          ),
                        ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: statusColor.withOpacity(0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.workspace_premium, color: statusColor, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              "Tipe Akun: $tipeAkunText",
                              style: TextStyle(fontWeight: FontWeight.bold, color: statusColor, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      // --- 3. MENU LIST ---
                      _buildMenuTile(Icons.settings_rounded, "Pengaturan", () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SettingsScreen()),
                        );
                      }),
                      _buildMenuTile(Icons.help_outline_rounded, "Pusat Bantuan", () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const HelpCenterScreen()),
                        );
                      }),
                      _buildMenuTile(Icons.info_outline_rounded, "Tentang Chromia", () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: AppColors.background,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              title: const Row(
                                children: [
                                  Icon(Icons.info_outline, color: AppColors.primary),
                                  SizedBox(width: 12),
                                  Text('Tentang Chromia', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
                                ],
                              ),
                              content: const Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Chromia adalah aplikasi asisten penglihatan cerdas yang dirancang khusus untuk membantu penyandang buta warna (Color Vision Deficiency).',
                                    style: TextStyle(color: AppColors.textMuted, height: 1.5),
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'Dengan kekuatan Google Gemini AI, Chromia mampu mendeteksi dan mengidentifikasi warna benda apa pun secara real-time hanya melalui jepretan kamera.',
                                    style: TextStyle(color: AppColors.textMuted, height: 1.5),
                                  ),
                                  SizedBox(height: 24),
                                  Divider(),
                                  SizedBox(height: 12),
                                  Text(
                                    'Hak Cipta & Paten Terdaftar',
                                    style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  Text(
                                    '© 2 Juli 2026. Hak paten teknologi dilindungi oleh undang-undang.',
                                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Tutup', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            );
                          },
                        );
                      }),

                      const SizedBox(height: 24),

                      // --- 4. LOGOUT ---
                      _buildMenuTile(Icons.logout_rounded, "Keluar", () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: AppColors.background,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              title: const Text('Keluar dari Akun', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
                              content: const Text('Apakah Anda yakin ingin keluar?', style: TextStyle(color: AppColors.textMuted)),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Batal', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: () async {
                                    final prefs = await SharedPreferences.getInstance();
                                    await prefs.remove('token');

                                    if (!context.mounted) return;

                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                                      (route) => false,
                                    );
                                  },
                                  child: const Text('Ya, Keluar', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ],
                            );
                          },
                        );
                      }, isLogout: true),
                      
                      const SizedBox(height: 100), // Spasi navbar
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, VoidCallback onTap, {bool isLogout = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isLogout ? Colors.red.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: isLogout ? Colors.red : AppColors.dark),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: isLogout ? Colors.red : AppColors.textDark)),
        trailing: isLogout ? null : const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }
}