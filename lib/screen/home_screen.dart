import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomeScreen extends StatefulWidget {
  final Function(int) onNavigate;

  const HomeScreen({super.key, required this.onNavigate});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  String _userName = 'Pengguna';
  int _remainingScans = 0;
  bool _isPremium = false;
  List<dynamic> _historyList = [];

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
          _remainingScans = data['remaining_scans'] ?? 0;
          _isPremium = data['is_premium'] ?? false;
          _historyList = data['history'] ?? [];
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return Colors.grey;
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    try {
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _fetchUserData,
        color: AppColors.primary,
        child: Column(
          children: [
            // --- 1. HEADER (Latar Belakang Gelap Melengkung) ---
            Container(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
              decoration: const BoxDecoration(
                color: AppColors.dark,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Halo, ${_userName.split(' ')[0]}! 👋', style: const TextStyle(color: AppColors.textLight, fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      const Text('Siap eksplorasi warna hari ini?', style: TextStyle(color: AppColors.primary, fontSize: 14)),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      widget.onNavigate(3); // Arahkan ke Profil
                    },
                    child: const CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white10,
                      child: Icon(Icons.person, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),

            // --- 2. TOMBOL SCAN (Efek Floating) ---
            Transform.translate(
              offset: const Offset(0, -30),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 65,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.dark,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 8,
                    ),
                    onPressed: () {
                      widget.onNavigate(1); // Arahkan ke Halaman Scan
                    },
                    icon: const Icon(Icons.document_scanner_outlined, size: 28),
                    label: const Text('Scan Warna Sekarang', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),

            // --- 3. KONTEN (Scrollable List) ---
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(), // Biar selalu bisa di pull-to-refresh
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
                    child: Column(
                      children: [
                        // Card Kuota
                        _buildQuotaCard(),
                        const SizedBox(height: 32),
                        
                        // Header Riwayat
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Riwayat Terakhir', style: TextStyle(color: AppColors.textDark, fontSize: 18, fontWeight: FontWeight.bold)),
                            TextButton(onPressed: () {}, child: const Text('Lihat Semua', style: TextStyle(color: AppColors.textMuted))),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // List Riwayat Dinamis
                        if (_historyList.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text("Belum ada riwayat scan.", style: TextStyle(color: AppColors.textMuted)),
                          )
                        else
                          ..._historyList.map((item) {
                            // Hitung waktu relatif
                            DateTime createdAt = DateTime.parse(item['created_at']);
                            String timeAgo = timeago.format(createdAt, locale: 'id');

                            return _buildHistoryCard(
                              item['color_name'] ?? 'Tidak diketahui',
                              item['hex_code'] ?? '#808080',
                              _parseColor(item['hex_code']),
                              timeAgo.toUpperCase(),
                            );
                          }),
                          
                          const SizedBox(height: 100), // Spasi untuk bottom navbar
                      ],
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BANTUAN ---
  Widget _buildQuotaCard() {
    String kuotaText = _isPremium ? 'Unlimited' : '$_remainingScans / 5';
    String planText = _isPremium ? 'Premium' : 'Free Plan';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Sisa Kuota Scan', style: TextStyle(color: AppColors.textDark, fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(kuotaText, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.dark)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), 
                    decoration: BoxDecoration(
                      color: _isPremium ? Colors.amber.withOpacity(0.2) : AppColors.primary.withOpacity(0.2), 
                      borderRadius: BorderRadius.circular(8)
                    ), 
                    child: Text(planText, style: TextStyle(color: _isPremium ? Colors.amber.shade700 : AppColors.dark, fontSize: 12, fontWeight: FontWeight.bold))
                  ),
                ],
              ),
            ],
          ),
          if (!_isPremium)
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.dark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), 
              onPressed: () { widget.onNavigate(2); }, // Ke Upgrade
              child: const Text('Upgrade', style: TextStyle(fontWeight: FontWeight.bold))
            ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(String name, String hex, Color color, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Row(
        children: [
          Container(width: 48, height: 48, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12))),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: AppColors.textDark, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(hex, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
              ],
            ),
          ),
          Text(time, style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}