import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with SingleTickerProviderStateMixin {
  File? _selectedImage;
  bool _isLoading = false;
  String? _detectedColor;
  int? _remainingScans;
  String? _errorMessage;

  final ImagePicker _picker = ImagePicker();

  late AnimationController _scanAnimationController;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _scanAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanAnimationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scanAnimationController.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 30, // Kompresi kualitas gambar jadi 30%
        maxWidth: 800,    // Batasi lebar maksimal biar enteng
        maxHeight: 800,   // Batasi tinggi maksimal
      );
      if (photo != null) {
        setState(() {
          _selectedImage = File(photo.path);
          _detectedColor = null;
          _errorMessage = null;
        });
        await _uploadAndAnalyzeImage();
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Gagal membuka kamera: $e";
      });
    }
  }

  Future<void> _uploadAndAnalyzeImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _detectedColor = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://10.125.36.208:3000/api/scan'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath(
        'image', 
        _selectedImage!.path,
        contentType: MediaType('image', 'jpeg'), // Paksa format JPEG biar Gemini nggak bingung
      ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _detectedColor = data['data']['color'];
            _remainingScans = data['data']['remaining_scans'];
          });
        } else {
          setState(() {
            _errorMessage = data['message'] ?? 'Gagal menganalisis gambar';
          });
        }
      } else if (response.statusCode == 403) {
        var data = jsonDecode(response.body);
        setState(() {
          _errorMessage = data['message'] ?? 'Kuota habis.';
        });
      } else {
        setState(() {
          _errorMessage = 'Terjadi kesalahan pada server (Status: ${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal terhubung ke server: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Scan Warna', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.dark,
        foregroundColor: AppColors.textLight,
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Preview Gambar
                      Container(
                        width: double.infinity,
                        height: 300,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: _selectedImage != null
                              ? Stack(
                                  children: [
                                    Positioned.fill(
                                      child: Image.file(_selectedImage!, fit: BoxFit.cover),
                                    ),
                                    if (_isLoading)
                                      AnimatedBuilder(
                                        animation: _scanAnimation,
                                        builder: (context, child) {
                                          return Positioned(
                                            top: _scanAnimation.value * 280, 
                                            left: 0,
                                            right: 0,
                                            child: Container(
                                              height: 4,
                                              decoration: BoxDecoration(
                                                color: AppColors.primary,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: AppColors.primary.withOpacity(0.8),
                                                    blurRadius: 15,
                                                    spreadRadius: 5,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    if (_isLoading)
                                      Positioned.fill(
                                        child: Container(color: Colors.black.withOpacity(0.3)), // Darken image while scanning
                                      ),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.camera_alt_outlined, size: 64, color: AppColors.textMuted.withOpacity(0.5)),
                                    const SizedBox(height: 16),
                                    const Text('Belum ada gambar', style: TextStyle(color: AppColors.textMuted)),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Status & Hasil Analisis
                      if (_isLoading)
                        Column(
                          children: [
                            const SizedBox(height: 16),
                            AnimatedBuilder(
                              animation: _scanAnimationController,
                              builder: (context, child) {
                                return Opacity(
                                  opacity: 0.5 + (_scanAnimationController.value * 0.5),
                                  child: const Text('Gambar Anda sedang diproses...', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
                                );
                              },
                            ),
                          ],
                        )
                      else if (_errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        )
                      else if (_detectedColor != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.primary, width: 2),
                          ),
                          child: Column(
                            children: [
                              const Text('Warna Terdeteksi:', style: TextStyle(color: AppColors.textDark, fontSize: 16)),
                              const SizedBox(height: 8),
                              Text(_detectedColor!, style: const TextStyle(color: AppColors.dark, fontSize: 32, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                              if (_remainingScans != null) ...[
                                const SizedBox(height: 12),
                                Text('Sisa kuota: $_remainingScans', style: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
                              ]
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Teks Edukasi / Tips
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tips: Pastikan benda yang ingin di-scan berada tepat di tengah-tengah kamera.',
                      style: TextStyle(color: AppColors.textMuted.withOpacity(0.8), fontSize: 13, fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
            
            // Tombol Kamera
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 120), // Padding bawah dilebihkan untuk BottomNavBar
              child: SizedBox(
                width: double.infinity,
                height: 65,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.dark,
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 8,
                  ),
                  onPressed: _isLoading ? null : _takePicture,
                  icon: const Icon(Icons.camera, size: 28),
                  label: const Text('Ambil Foto', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
