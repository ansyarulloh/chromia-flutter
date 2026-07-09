import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.dark,
        foregroundColor: AppColors.textLight,
        title: const Text('Pusat Bantuan', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: Column(
        children: [
          // --- HEADER GELAP MELENGKUNG (Sesuai Request UI) ---
          Container(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.dark,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Layanan Pelanggan Chromia', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                SizedBox(height: 8),
                Text(
                  'Kami Siap\nMembantu Anda',
                  style: TextStyle(color: AppColors.primary, fontSize: 32, fontWeight: FontWeight.w900, height: 1.2),
                ),
              ],
            ),
          ),

          // --- KONTEN BAWAH (Scrollable) ---
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'FAQ (Pertanyaan Umum)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 16),
                  
                  // --- DAFTAR FAQ ---
                  _buildFaqItem(
                    'Bagaimana cara memindai warna?',
                    'Sangat mudah! Buka menu Scan (ikon kuning di tengah bawah), arahkan kamera agar benda yang ingin dicek berada tepat di tengah layar, lalu tekan tombol "Ambil Foto". Tunggu beberapa detik, dan AI kami akan menyebutkan warnanya.',
                  ),
                  _buildFaqItem(
                    'Mengapa aplikasi ini membutuhkan internet?',
                    'Chromia menggunakan teknologi cerdas Google Gemini AI yang berada di cloud (server) untuk mendeteksi warna dengan akurasi sangat tinggi. Oleh karena itu, koneksi internet yang stabil diperlukan.',
                  ),
                  _buildFaqItem(
                    'Bagaimana cara berlangganan Premium?',
                    'Masuk ke tab Upgrade (ikon bintang), lalu pilih paket yang Anda inginkan (1 Bulan, 6 Bulan, atau 1 Tahun). Tekan "Mulai Member Premium" dan ikuti petunjuk pembayarannya.',
                  ),

                  const SizedBox(height: 40),

                  // --- KONTAK CUSTOMER SERVICE ---
                  const Text(
                    'Hubungi Kami',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Jangan ragu menghubungi tim kami. Kami siap membantu Anda 24/7.',
                    style: TextStyle(color: AppColors.textMuted, height: 1.5, fontSize: 13),
                  ),
                  const SizedBox(height: 24),

                  // Menggunakan perpaduan Hitam (AppColors.dark) dan Hijau Muda (AppColors.primary)
                  _buildContactCard(
                    icon: Icons.chat_bubble,
                    title: 'WhatsApp',
                    subtitle: '+62 812-3456-7890',
                  ),
                  const SizedBox(height: 12),
                  _buildContactCard(
                    icon: Icons.email,
                    title: 'Email Support',
                    subtitle: 'support@chromia.id',
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dark.withOpacity(0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: AppColors.dark, 
          collapsedIconColor: AppColors.dark,
          title: Text(
            question,
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 14),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                answer,
                style: const TextStyle(color: AppColors.textMuted, height: 1.5, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({required IconData icon, required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.dark, // Background hitam elegan
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15), // Efek transparan hijau muda
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 28), // Ikon warna hijau muda
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16)), // Judul hijau muda
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)), // Teks putih
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.arrow_forward_ios, color: AppColors.dark, size: 14), // Ikon panah
          ),
        ],
      ),
    );
  }
}
