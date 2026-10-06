import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/shop_provider.dart';
import '../models/service_model.dart'; // Ensure this model exists
import '../utils/constants.dart';

class BarberServicesScreen extends StatefulWidget {
  final String shopId;
  const BarberServicesScreen({super.key, required this.shopId});

  @override
  State<BarberServicesScreen> createState() => _BarberServicesScreenState();
}

class _BarberServicesScreenState extends State<BarberServicesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      Provider.of<ShopProvider>(context, listen: false).fetchServices(widget.shopId)
    );
  }

  void _showServiceDialog({Service? service}) {
    final _nameController = TextEditingController(text: service?.name ?? '');
    final _descController = TextEditingController(text: service?.description ?? '');
    final _priceController = TextEditingController(text: service?.price.toString() ?? '');
    final _durationController = TextEditingController(text: service?.duration.toString() ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(service == null ? 'Add Service' : 'Edit Service', style: TextStyle(color: AppColors.primary)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField('Service Name', _nameController),
              const SizedBox(height: 10),
              _buildTextField('Description', _descController, maxLines: 2),
              const SizedBox(height: 10),
              Row(
                children: [
                   Expanded(child: _buildTextField('Price (₹)', _priceController, isNumber: true)),
                   const SizedBox(width: 10),
                   Expanded(child: _buildTextField('Duration (mins)', _durationController, isNumber: true)),
                ],
              )
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text('Cancel', style: TextStyle(color: Colors.grey))
          ),
          ElevatedButton(
            onPressed: () async {
               if (_nameController.text.isEmpty || _priceController.text.isEmpty || _durationController.text.isEmpty) {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill required fields')));
                 return;
               }
               
               try {
                 final data = {
                   'name': _nameController.text,
                   'description': _descController.text,
                   'price': double.tryParse(_priceController.text) ?? 0,
                   'duration': int.tryParse(_durationController.text) ?? 30,
                 };
                 
                 final provider = Provider.of<ShopProvider>(context, listen: false);
                 if (service == null) {
                    await provider.addService(widget.shopId, data);
                 } else {
                    await provider.updateService(service.id, widget.shopId, data);
                 }
                 Navigator.pop(context);
               } catch (e) {
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
               }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.black),
            child: Text(service == null ? 'Add' : 'Update'),
          )
        ],
      ),
    );
  }
  
  void _confirmDelete(String serviceId) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: Text('Delete Service?', style: TextStyle(color: Colors.white)),
            content: Text('Are you sure you want to delete this service?', style: TextStyle(color: Colors.white70)),
            actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: Text('No')),
                TextButton(
                    onPressed: () async {
                        await Provider.of<ShopProvider>(context, listen: false).deleteService(serviceId, widget.shopId);
                        Navigator.pop(context);
                    }, 
                    child: Text('Yes', style: TextStyle(color: Colors.red))
                ),
            ],
        )
      );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false, int maxLines = 1}) {
    return TextField(
      controller: controller,
      style: TextStyle(color: Colors.white),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Manage Services', style: GoogleFonts.outfit(color: AppColors.onBackground)),
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: AppColors.onBackground),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showServiceDialog(),
        backgroundColor: AppColors.primary,
        child: Icon(Icons.add, color: Colors.black),
      ),
      body: Consumer<ShopProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return Center(child: CircularProgressIndicator());
          if (provider.services.isEmpty) return Center(child: Text('No services yet. Add one!', style: TextStyle(color: Colors.white)));
          
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: provider.services.length,
            itemBuilder: (context, index) {
              final service = provider.services[index];
              return Card(
                color: AppColors.surface,
                margin: EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(service.name, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text('${service.duration} mins • ₹${service.price}', style: TextStyle(color: AppColors.primary)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: Icon(Icons.edit, color: Colors.blue), onPressed: () => _showServiceDialog(service: service)),
                      IconButton(icon: Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _confirmDelete(service.id)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
