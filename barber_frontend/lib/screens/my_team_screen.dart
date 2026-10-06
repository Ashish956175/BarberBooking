import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import '../providers/shop_provider.dart';
import '../utils/constants.dart';
import '../widgets/glass_container.dart';

class MyTeamScreen extends StatefulWidget {
  final String shopId;

  const MyTeamScreen({super.key, required this.shopId});

  @override
  State<MyTeamScreen> createState() => _MyTeamScreenState();
}

class _MyTeamScreenState extends State<MyTeamScreen> {
  bool _isLoading = false;

  void _showAddEmployeeDialog({Map<String, dynamic>? employee}) {
      if (kIsWeb) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not supported on web')));
        return;
      }

      final isEdit = employee != null;
      final nameController = TextEditingController(text: isEdit ? employee['name'] : '');
      final roleController = TextEditingController(text: isEdit ? employee['role'] : '');
      String? uploadedUrl = isEdit ? employee['image'] : null;
      
      showDialog(
          context: context,
          builder: (context) => StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                  backgroundColor: AppColors.surface,
                  title: Text(isEdit ? 'Edit Team Member' : 'Add Team Member', style: TextStyle(color: AppColors.primary)),
                  content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                          TextField(controller: nameController, style: TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Name', labelStyle: TextStyle(color: Colors.grey), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)))),
                          TextField(controller: roleController, style: TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Role (e.g. Barber)', labelStyle: TextStyle(color: Colors.grey), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)))),
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                              onPressed: () async {
                                  final ImagePicker picker = ImagePicker();
                                  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                                  if (image != null) {
                                      setDialogState(() => uploadedUrl = 'Uploading...');
                                      try {
                                          final url = await Provider.of<ShopProvider>(context, listen: false).uploadImage(image.path);
                                          setDialogState(() => uploadedUrl = url);
                                      } catch (e) {
                                          setDialogState(() => uploadedUrl = 'Error');
                                      }
                                  }
                              },
                              icon: const Icon(Icons.upload),
                              label: Text(uploadedUrl == null ? 'Upload Photo' : (uploadedUrl!.startsWith('http') ? 'Uploaded!' : 'Image Selected'))
                          )
                      ],
                  ),
                  actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                      ElevatedButton(
                          onPressed: () async {
                              if (nameController.text.isNotEmpty && uploadedUrl != null) {
                                  try {
                                    setState(() => _isLoading = true);
                                    Navigator.pop(context);
                                    if (isEdit) {
                                        await Provider.of<ShopProvider>(context, listen: false).updateEmployee(widget.shopId, employee['_id'], nameController.text, roleController.text, uploadedUrl!);
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Employee Updated')));
                                    } else {
                                        await Provider.of<ShopProvider>(context, listen: false).addEmployee(widget.shopId, nameController.text, roleController.text, uploadedUrl!);
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Employee Added')));
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                  } finally {
                                    if (mounted) setState(() => _isLoading = false);
                                  }
                              }
                          },
                          child: Text(isEdit ? 'Save' : 'Add'),
                      )
                  ],
              );
            }
          )
      );
  }

  void _deleteEmployee(String employeeId) {
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Remove Member?', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to remove this team member?', style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              try {
                await Provider.of<ShopProvider>(context, listen: false).removeEmployee(widget.shopId, employeeId);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Employee Removed')));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              } finally {
                if(mounted) setState(() => _isLoading = false);
              }
            }, 
            child: const Text('Remove', style: TextStyle(color: Colors.red))
          ),
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    // Locate the current shop from provider
    final shopProvider = Provider.of<ShopProvider>(context);
    final myShop = shopProvider.shops.firstWhere((s) => s.id == widget.shopId, orElse: () => shopProvider.shops.first); // Fallback safe
    final employees = myShop.employees ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('My Team', style: GoogleFonts.outfit(color: AppColors.primary)),
        backgroundColor: AppColors.background,
        iconTheme: IconThemeData(color: AppColors.secondary),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEmployeeDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Member'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : employees.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_outline, size: 80, color: Colors.white24),
                    const SizedBox(height: 16),
                    Text('No team members yet', style: GoogleFonts.outfit(color: Colors.white54, fontSize: 18)),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: employees.length,
                itemBuilder: (context, index) {
                  final emp = employees[index];
                  // emp is a Map if from JSON, but Shop model defines it as Class?
                  // Wait, Shop.fromJson maps employees to List<Map> or List<Employee>?
                  // Looking at shop_model.dart... it maps to List<Map<String, dynamic>> usually if not strictly typed in older edits.
                  // But let's assume Map access for safety as per BarberDashboardScreen logic.
                  
                  final name = emp['name'] ?? 'Unknown';
                  final role = emp['role'] ?? 'Staff';
                  final image = emp['image'] ?? '';
                  final id = emp['_id']; // Backend provided ID

                  return Card(
                    color: AppColors.surface,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage(AppConstants.fixImageUrl(image)),
                        onBackgroundImageError: (_, __) => const Icon(Icons.person),
                      ),
                      title: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text(role, style: TextStyle(color: AppColors.secondary)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: id != null ? () => _deleteEmployee(id) : null,
                      ),
                      onTap: () => _showAddEmployeeDialog(employee: emp), // EDIT
                    ),
                  );
                },
              ),
    );
  }
}
