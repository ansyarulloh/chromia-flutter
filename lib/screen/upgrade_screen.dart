import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'payment_method_screen.dart';

class UpgradeScreen extends StatefulWidget {
  const UpgradeScreen({super.key});

  @override
  State<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends State<UpgradeScreen> {
  // Indeks paket yang dipilih (default 2 = Paket 6 Bulan yang Populer)
  int _selectedIndex = 2;

  final List<Map<String, dynamic>> _plans = [
    {
      'title': '1 Bulan',
      'price': 'Rp 50.000',
      'duration': '/ Bulan',
      'desc': 'Langganan bulanan fleksibel. Batalkan kapan saja tanpa biaya tersembunyi. Sangat cocok untuk sekadar mencoba fitur Premium.',
      'popular': false,
    },
    {
      'title': '3 Bulan',
      'price': 'Rp 140.000',
      'duration': '/ 3 Bln',
      'desc': 'Lebih hemat! Pilihan cerdas untuk penggunaan rutin harian Anda.',
      'popular': false,
    },
    {
      'title': '6 Bulan',
      'price': 'Rp 260.000',
      'duration': '/ 6 Bln',
      'desc': 'Paket paling diminati! Nikmati akses tanpa batas selama setengah tahun penuh.',
      'popular': true,
    },
    {
      'title': '12 Bulan',
      'price': 'Rp 450.000',
      'duration': '/ 1 Tahun',
      'desc': '🔥 SUPER HEMAT! Harga terbaik untuk komitmen jangka panjang. Bayar sekali dan lupakan batasan selamanya.',
      'popular': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
          child: Column(
            children: [
              // --- 1. ICON CROWN ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.dark,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.workspace_premium_rounded, color: AppColors.primary, size: 48),
              ),
              const SizedBox(height: 32),

              // --- 2. JUDUL ---
              const Text(
                "Warna Tanpa Batas\ndengan Premium",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 32),

              // --- 3. LIST FITUR UMUM ---
              _buildFeatureItem("Pemindaian warna sepuasnya", "Scan ribuan warna setiap hari tanpa limit."),
              _buildFeatureItem("Simpan riwayat selamanya", "Koleksi warna favorit Anda aman di cloud Chromia."),
              
              const SizedBox(height: 32),

              // --- 4. PILIHAN PAKET (Klik-able) ---
              Wrap(
                spacing: 12,
                runSpacing: 32, // Jarak vertikal besar agar label POPULER tidak tertimpa
                children: List.generate(_plans.length, (index) {
                  return SizedBox(
                    width: (MediaQuery.of(context).size.width - 48 - 12) / 2, // 2 items per baris (dikurangi padding layar dan spacing)
                    child: _buildPlanOption(index),
                  );
                }),
              ),
              const SizedBox(height: 24),

              // --- 5. DESKRIPSI PAKET TERPILIH DINAMIS ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Tentang Paket ${_plans[_selectedIndex]['title']}:",
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _plans[_selectedIndex]['desc'],
                      style: const TextStyle(color: AppColors.textMuted, height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // --- 6. TOMBOL AKSI ---
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.dark, 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                  ),
                  onPressed: () {
                    // Pindah ke Halaman Pembayaran
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentMethodScreen(
                          planName: _plans[_selectedIndex]['title'],
                          planPrice: _plans[_selectedIndex]['price'],
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "Mulai Member Premium →", 
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
                  ),
                ),
              ),
              
              const SizedBox(height: 100), 
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET BANTUAN ---

  Widget _buildFeatureItem(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.primary, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
                Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanOption(int index) {
    bool isSelected = _selectedIndex == index;
    bool isPopular = _plans[index]['popular'];

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.dark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.dark : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: AppColors.primary.withOpacity(0.5), blurRadius: 8, offset: const Offset(0, 4))]
              : [],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _plans[index]['title'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _plans[index]['price'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: isSelected ? AppColors.primary : AppColors.textDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  _plans[index]['duration'],
                  style: TextStyle(
                    fontSize: 11,
                    color: isSelected ? Colors.white70 : AppColors.textMuted,
                  ),
                ),
              ],
            ),
            
            // Label Popular
            if (isPopular)
              Positioned(
                top: -26,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "POPULER",
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.dark),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}