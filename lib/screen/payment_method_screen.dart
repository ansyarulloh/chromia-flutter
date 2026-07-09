import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PaymentMethodScreen extends StatefulWidget {
  final String planName;
  final String planPrice;

  const PaymentMethodScreen({
    super.key,
    required this.planName,
    required this.planPrice,
  });

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  String? _selectedMethod;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.dark,
        foregroundColor: AppColors.textLight,
        title: const Text('Pilih Pembayaran', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: Column(
        children: [
          // --- RINGKASAN ORDER ---
          Container(
            padding: const EdgeInsets.all(24),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.dark,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Pembayaran', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                const SizedBox(height: 8),
                Text(
                  widget.planPrice,
                  style: const TextStyle(color: AppColors.primary, fontSize: 32, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.workspace_premium, color: AppColors.primary, size: 16),
                    const SizedBox(width: 8),
                    Text('Paket Premium: ${widget.planName}', style: const TextStyle(color: AppColors.textLight, fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),

          // --- LIST METODE PEMBAYARAN ---
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Transfer Bank (Virtual Account)', style: TextStyle(color: AppColors.textDark, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildPaymentOption('BCA', Icons.account_balance, Colors.blue.shade800),
                  _buildPaymentOption('Mandiri', Icons.account_balance, Colors.orange.shade700),
                  _buildPaymentOption('BRI', Icons.account_balance, Colors.blue.shade900),
                  _buildPaymentOption('BNI', Icons.account_balance, Colors.teal.shade700),
                  _buildPaymentOption('CIMB Niaga', Icons.account_balance, Colors.red.shade800),
                  _buildPaymentOption('Danamon', Icons.account_balance, Colors.orange.shade900),
                  _buildPaymentOption('Bank Jago', Icons.account_balance, Colors.deepOrange),
                  
                  const SizedBox(height: 32),
                  
                  const Text('E-Wallet', style: TextStyle(color: AppColors.textDark, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildPaymentOption('GoPay', Icons.account_balance_wallet, Colors.blue),
                  _buildPaymentOption('ShopeePay', Icons.account_balance_wallet, Colors.deepOrange.shade400),
                  _buildPaymentOption('OVO', Icons.account_balance_wallet, Colors.purple),
                  _buildPaymentOption('DANA', Icons.account_balance_wallet, Colors.blue.shade600),
                ],
              ),
            ),
          ),

          // --- TOMBOL BAYAR ---
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), offset: const Offset(0, -4), blurRadius: 10)],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedMethod != null ? AppColors.primary : Colors.grey.shade300,
                  foregroundColor: _selectedMethod != null ? AppColors.dark : Colors.grey.shade600,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _selectedMethod != null
                    ? () {
                        // Nanti dihubungkan ke API Payment Gateway (misal Midtrans)
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Memproses pembayaran via $_selectedMethod...')),
                        );
                      }
                    : null,
                child: const Text('Lanjutkan Pembayaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String name, IconData icon, Color color) {
    bool isSelected = _selectedMethod == name;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = name;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 24)
            else
              Icon(Icons.radio_button_unchecked, color: Colors.grey.shade300, size: 24),
          ],
        ),
      ),
    );
  }
}
