import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb

class AppConstants {
    // If Web, use localhost. If Android Emulator, use 10.0.2.2
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5000/api';
    } else {
      return 'http://localhost:5000/api';
    }
  }

  static String fixImageUrl(String? url) {
      if (url == null || url.isEmpty) return 'https://via.placeholder.com/150';
      
      print('DEBUG: Fixing URL: $url'); // Debug log

      // Handle Relative Paths (The Fix)
      if (!url.startsWith('http')) {
          String root = baseUrl.replaceAll('/api', '');
          if (!url.startsWith('/')) url = '/$url';
          print('DEBUG: Fixed Relative URL: $root$url');
          return '$root$url';
      }

      // Handle Legacy Localhost
      if (url.startsWith('http://localhost') || url.startsWith('http://127.0.0.1')) {
          String root = baseUrl.replaceAll('/api', '');
          String path = Uri.parse(url).path; 
          print('DEBUG: Fixed Localhost URL: $root$path');
          return '$root$path';
      }
      return url;
  }
}

class AppColors {
  // Royal Noir & Liquid Gold Palette
  static const Color background = Color(0xFF0F0F0F); // Ultra-deep Charcoal
  static const Color surface = Color(0xFF1A1A1A); // Darker Surface
  static const Color primary = Color(0xFFD4AF37); // Classic Gold
  static const Color secondary = Color(0xFFC0C0C0); // Platinum
  static const Color accent = Color(0xFFC5A028); 
  static const Color error = Color(0xFFCF6679);
  
  static const Color onPrimary = Color(0xFF000000); 
  static const Color onBackground = Color(0xFFF0F0F0);
  static const Color onSurface = Color(0xFFE0E0E0);
  
  // Luxury Gradients
  static const LinearGradient liquidGold = LinearGradient(
    colors: [
      Color(0xFFD4AF37), // Gold
      Color(0xFFF1D06E), // Light Gold
      Color(0xFFD4AF37), // Back to Gold
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.1, 0.5, 0.9],
  );

  static const LinearGradient royalDark = LinearGradient(
    colors: [Color(0xFF0F0F0F), Color(0xFF1C1C1C)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color(0x1AFFFFFF), // 10% White
      Color(0x0DFFFFFF), // 5% White
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
