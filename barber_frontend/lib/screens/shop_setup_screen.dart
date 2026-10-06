import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart'; // Ensure geolocator is in pubspec
import '../providers/shop_provider.dart';
import '../utils/constants.dart';
import 'dart:io';

class ShopSetupScreen extends StatefulWidget {
  const ShopSetupScreen({super.key});

  @override
  State<ShopSetupScreen> createState() => _ShopSetupScreenState();
}

class _ShopSetupScreenState extends State<ShopSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  
  // Location
  double? _lat;
  double? _lng;
  String _locationStatus = "Location not set";

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
           throw 'Location permissions are denied';
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
         throw 'Location permissions are permanently denied.';
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _lat = position.latitude;
        _lng = position.longitude;
        _locationStatus = "Lat: ${_lat!.toStringAsFixed(4)}, Lng: ${_lng!.toStringAsFixed(4)}";
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Location Acquired!")));

    } catch (e) {
      // Fallback for emulator/disabled services
      setState(() {
          _lat = 18.5204;
          _lng = 73.8567;
          _locationStatus = "Default: Pune (GPS Disabled)";
          _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('GPS Error: $e. Using Default Location.')));
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please upload a cover image')));
        return;
    }
    // Location is optional now (Defaults to 0,0 if not set)
    double finalLat = _lat ?? 0.0;
    double finalLng = _lng ?? 0.0;

    setState(() => _isLoading = true);

    try {
      // 1. Upload Image
      final shopProvider = Provider.of<ShopProvider>(context, listen: false);
      String imageUrl = await shopProvider.uploadImage(_imageFile!.path);

      // 2. Create Shop
      await shopProvider.createShop({
        'name': _nameController.text,
        'address': _addressController.text,
        'description': _descriptionController.text,
        'coordinates': [finalLng, finalLat], // GeoJSON order: [lng, lat]
        'images': [imageUrl], // as array
        'openingHours': {
            'Mon-Fri': '9:00 AM - 9:00 PM', // Default
            'Sat-Sun': '10:00 AM - 8:00 PM'
        }
      });

      if (!mounted) return;
      // Success -> Go to Dashboard
      Navigator.pushReplacementNamed(context, '/barber-dashboard');
      
    } catch (e) {
       setState(() => _isLoading = false);
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Setup Your Shop', style: GoogleFonts.outfit(color: AppColors.onBackground)),
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false, // No back button
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, Partner! 🤝',
                style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 8),
              Text(
                'Let\'s get your shop on the map. Fill in the details below.',
                style: TextStyle(color: AppColors.secondary),
              ),
              const SizedBox(height: 30),

              // Image Picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withOpacity(0.5)),
                    image: _imageFile != null 
                        ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                        : null
                  ),
                  child: _imageFile == null 
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, size: 40, color: AppColors.secondary),
                            const SizedBox(height: 8),
                            Text('Upload Cover Photo', style: TextStyle(color: AppColors.secondary)),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 24),

              // Fields
              _buildTextField('Shop Name', _nameController, Icons.store),
              const SizedBox(height: 16),
              _buildTextField('Address', _addressController, Icons.location_on),
              const SizedBox(height: 16),
              _buildTextField('Description', _descriptionController, Icons.description, maxLines: 3),
              const SizedBox(height: 24),

              // Location Status
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.map, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _locationStatus,
                        style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _getCurrentLocation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary.withOpacity(0.2),
                        foregroundColor: AppColors.primary,
                        elevation: 0
                      ),
                      child: const Text('Locate Me'),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: Colors.grey,
                  ),
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.black) 
                      : const Text('CREATE SHOP', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: AppColors.onSurface),
      maxLines: maxLines,
      validator: (val) => val!.isEmpty ? 'Required' : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.secondary),
        prefixIcon: Icon(icon, color: AppColors.secondary),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}
