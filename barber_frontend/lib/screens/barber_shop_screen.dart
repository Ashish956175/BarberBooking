import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/shop_provider.dart';
import '../models/shop_model.dart';
import '../utils/constants.dart';

class BarberShopScreen extends StatefulWidget {
  const BarberShopScreen({super.key});

  @override
  State<BarberShopScreen> createState() => _BarberShopScreenState();
}

class _BarberShopScreenState extends State<BarberShopScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _descController = TextEditingController();
  String? _uploadedImageUrl;
  bool _isLoading = false;
  Shop? _existingShop;
  
  // Map Logic
  LatLng _selectedLocation = const LatLng(37.42796133580664, -122.085749655962);

  @override
  void initState() {
    super.initState();
    // Load existing Logic
     Future.microtask(() {
         // Try to load first shop for demo
         final provider = Provider.of<ShopProvider>(context, listen: false);
         if (provider.shops.isNotEmpty) {
             _existingShop = provider.shops[0];
             _nameController.text = _existingShop!.name;
             _addressController.text = _existingShop!.address;
             _descController.text = _existingShop!.description ?? '';
             setState(() {});
         }
     });
  }

  Future<void> _pickImage() async {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
          setState(() => _isLoading = true);
          try {
              final url = await Provider.of<ShopProvider>(context, listen: false).uploadImage(image.path);
              setState(() {
                  _uploadedImageUrl = url;
                  _isLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image Uploaded!')));
          } catch (e) {
               setState(() => _isLoading = false);
               ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload Failed: $e')));
          }
      }
  }

  Future<void> _saveShop() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    final shopData = {
      'name': _nameController.text,
      'address': _addressController.text,
      'description': _descController.text,
      'coordinates': [_selectedLocation.longitude, _selectedLocation.latitude],
      'images': [_uploadedImageUrl ?? 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?ixlib=rb-1.2.1&auto=format&fit=crop&w=1353&q=80'],
       // Preserve existing openingHours
       'openingHours': { 
        "Monday": "9:00 AM - 9:00 PM",
        "Tuesday": "9:00 AM - 9:00 PM",
        "Wednesday": "9:00 AM - 9:00 PM",
        "Thursday": "9:00 AM - 9:00 PM",
        "Friday": "9:00 AM - 9:00 PM",
        "Saturday": "10:00 AM - 8:00 PM",
        "Sunday": "Closed"
      },
    };

    try {
      final shopProvider = Provider.of<ShopProvider>(context, listen: false);
      if (_existingShop != null) {
          await shopProvider.updateShop(_existingShop!.id, shopData);
           if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Shop Updated!')));
      } else {
          await shopProvider.createShop(shopData);
           if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Shop Created!')));
      }
      Navigator.pop(context); 
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Manage Shop Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(_nameController, "Shop Name", Icons.store),
              const SizedBox(height: 16),
              _buildTextField(_addressController, "Address", Icons.location_on),
              const SizedBox(height: 16),
              _buildTextField(_descController, "Description", Icons.description, maxLines: 3),
              const SizedBox(height: 16),
              
              // Image Picker
              InkWell(
                  onTap: _pickImage,
                  child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white24),
                          image: _uploadedImageUrl != null 
                            ? DecorationImage(image: NetworkImage(_uploadedImageUrl!), fit: BoxFit.cover)
                            : null
                      ),
                      child: _uploadedImageUrl == null 
                        ? const Center(child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                                Icon(Icons.add_a_photo, size: 40, color: AppColors.primary),
                                SizedBox(height: 8),
                                Text("Tap to upload Shop Image", style: TextStyle(color: AppColors.secondary))
                            ]
                        ))
                        : null,
                  ),
              ),

              const SizedBox(height: 20),
              const Text("Set Location", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Container(
                  height: 200,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.white24),
                      borderRadius: BorderRadius.circular(12)
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.map_outlined, color: Colors.white54, size: 48),
                        const SizedBox(height: 8),
                        const Text('Map View Unavailable', style: TextStyle(color: Colors.white54)),
                        const SizedBox(height: 4),
                        const Text('(API Key Required)', style: TextStyle(color: Colors.white24, fontSize: 10)),
                        const SizedBox(height: 12),
                        const Text('Location set to Default', style: TextStyle(color: AppColors.primary, fontSize: 12)),
                      ],
                    ),
                  ),
              ),

              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveShop,
                child: _isLoading 
                    ? const CircularProgressIndicator() 
                    : const Text('SAVE SHOP PROFILE'),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: AppColors.onSurface),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        enabledBorder: OutlineInputBorder(
           borderRadius: BorderRadius.circular(12),
           borderSide: BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
           borderRadius: BorderRadius.circular(12),
           borderSide: BorderSide(color: AppColors.primary),
        ),
        labelStyle: TextStyle(color: AppColors.secondary),
      ),
      validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
    );
  }
}

class LatLng {
  final double latitude;
  final double longitude;
  const LatLng(this.latitude, this.longitude);
}
