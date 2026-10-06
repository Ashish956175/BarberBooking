import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import '../models/appointment_model.dart';
import '../models/shop_model.dart';
import '../providers/appointment_provider.dart';
import '../providers/shop_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import 'shop_setup_screen.dart';
import 'barber_services_screen.dart';
import 'analytics_screen.dart';
import 'my_team_screen.dart';
import 'reviews_screen.dart';
import 'manage_gallery_screen.dart';
import 'promotions_screen.dart';

class BarberDashboardScreen extends StatefulWidget {
  const BarberDashboardScreen({super.key});

  @override
  State<BarberDashboardScreen> createState() => _BarberDashboardScreenState();
}

class _BarberDashboardScreenState extends State<BarberDashboardScreen> {
  bool _isLoading = true;
  String? _shopId;
  Shop? _myShop;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadData());
  }

  Future<void> _loadData() async {
    try {
      print('🔄 Loading barber dashboard data...');
      final shopProvider = Provider.of<ShopProvider>(context, listen: false);
      
      // Add timeout to prevent infinite loading
      await shopProvider.fetchMyShops().timeout(
        Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timed out after 10 seconds');
        },
      );
      
      print('✅ My Shops fetched: ${shopProvider.shops.length}');

      // Auto-select first shop for demo (in production, filter by owner)
      if (shopProvider.shops.isNotEmpty) {
         if (mounted) {
           setState(() {
               _myShop = shopProvider.shops[0];
               _shopId = _myShop!.id;
           });
         }
         print('✅ Selected shop: ${_myShop!.name} (ID: $_shopId)');
         
         try {
           await Provider.of<AppointmentProvider>(context, listen: false)
               .fetchShopAppointments(_shopId!)
               .timeout(Duration(seconds: 10));
           print('✅ Appointments loaded');
         } catch (e) {
           print('⚠️ Error loading appointments: $e');
           // Continue even if appointments fail
         }
      } else {
        print('⚠️ No shops found for this barber. Redirecting to setup...');
        if (mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
                 Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ShopSetupScreen()));
            });
        }
      }

      if (mounted) {
        setState(() => _isLoading = false);
        print('✅ Dashboard loaded successfully');
      }
    } catch (e) {
      print('❌ Error loading dashboard: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          )
        );
      }
    }
  }

  Future<void> _updateStatus(String appointmentId, String status) async {
    try {
          await Provider.of<AppointmentProvider>(context, listen: false)
              .updateAppointmentStatus(appointmentId, status);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Appointment $status')));
      } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
  }

  // --- Gallery Logic ---
  Future<void> _addGalleryImage() async {
      if (kIsWeb) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image upload is not supported on web. Please use Android/iOS app.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          )
        );
        return;
      }

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null || _shopId == null) return;

      try {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Uploading...')));
          final url = await Provider.of<ShopProvider>(context, listen: false).uploadImage(image.path);
          await Provider.of<ShopProvider>(context, listen: false).addGalleryImage(_shopId!, url);
          setState(() { _myShop = Provider.of<ShopProvider>(context, listen: false).shops.firstWhere((s) => s.id == _shopId); }); // Refresh local
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to Gallery!')));
      } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
  }

  // --- Employee Logic ---
  Future<void> _addEmployee() async {
      if (kIsWeb) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Employee photo upload is not supported on web. Please use Android/iOS app.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          )
        );
        return;
      }

      final nameController = TextEditingController();
      final roleController = TextEditingController(); 
      String? uploadedUrl;
      
      await showDialog(
          context: context,
          builder: (context) => StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                  backgroundColor: AppColors.surface,
                  title: Text('Add Employee', style: TextStyle(color: AppColors.primary)),
                  content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                          TextField(controller: nameController, style: TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Name', labelStyle: TextStyle(color: Colors.grey))),
                          TextField(controller: roleController, style: TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Role', labelStyle: TextStyle(color: Colors.grey))),
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
                              label: Text(uploadedUrl == null ? 'Upload Photo' : (uploadedUrl!.startsWith('http') ? 'Uploaded!' : uploadedUrl!))
                          )
                      ],
                  ),
                  actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                      ElevatedButton(
                          onPressed: () async {
                              if (nameController.text.isNotEmpty && uploadedUrl != null && uploadedUrl!.startsWith('http')) {
                                  await Provider.of<ShopProvider>(context, listen: false).addEmployee(_shopId!, nameController.text, roleController.text, uploadedUrl!);
                                  setState(() { _myShop = Provider.of<ShopProvider>(context, listen: false).shops.firstWhere((s) => s.id == _shopId); });
                                  Navigator.pop(context);
                              }
                          },
                          child: const Text('Add'),
                      )
                  ],
              );
            }
          )
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Barber Dashboard', style: GoogleFonts.outfit(color: AppColors.primary)),
        backgroundColor: AppColors.background,
        iconTheme: IconThemeData(color: AppColors.secondary),
      ),
      drawer: _buildDrawer(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() => _isLoading = true);
          _loadData();
        },
        child: Icon(Icons.refresh),
        tooltip: 'Reload Data',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _shopId == null
              ? Center(child: Text('No Shop Found'))
              : SingleChildScrollView(
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_myShop!.status != 'approved')
                    Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        color: _myShop!.status == 'rejected' ? Colors.red : Colors.orange,
                        child: Text(
                            _myShop!.status == 'rejected' 
                                ? '⚠️ Shop Rejected. Please contact admin.' 
                                : '⏳ Verification Pending. Shop is hidden.',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                        ),
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Upcoming Appointments', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    _buildAppointmentList(),

                    const Divider(color: Colors.white24),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                              Text('Employees', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                              IconButton(onPressed: _addEmployee, icon: Icon(Icons.add_circle, color: AppColors.primary))
                          ],
                      ),
                    ),
                    _buildEmployeeList(),

                    const Divider(color: Colors.white24),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text('Gallery', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    _buildGalleryGrid(),
                    
                    const SizedBox(height: 50),
                  ],
                ),
              ),
    );
  }

  Widget _buildAppointmentList() {
      final allAppointments = Provider.of<AppointmentProvider>(context).shopAppointments;
      final appointments = allAppointments.where((a) => a.status == 'pending' || a.status == 'confirmed').toList();
      
      if (appointments.isEmpty) return const Padding(padding: EdgeInsets.all(16), child: Text("No pending active appointments", style: TextStyle(color: Colors.grey)));
      
      return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: appointments.length,
          itemBuilder: (context, index) {
              final appt = appointments[index];
              return Card(
                  color: AppColors.surface,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                      title: Text(appt.serviceName, style: TextStyle(color: Colors.white)),
                      subtitle: Row(
                        children: [
                          Text(appt.status.toUpperCase(), style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          if (appt.paymentAmount != null && appt.paymentAmount! > 0)
                             Container(
                               padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                               decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                               child: Text('PAID ₹${appt.paymentAmount}', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold))
                             )
                        ],
                      ),
                      trailing: appt.status == 'pending' 
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                                IconButton(
                                  icon: const Icon(Icons.check_circle_outline, color: Colors.green), 
                                  onPressed: () => _updateStatus(appt.id, 'confirmed'),
                                  tooltip: 'Approve',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.cancel_outlined, color: Colors.red), 
                                  onPressed: () => _updateStatus(appt.id, 'cancelled'),
                                  tooltip: 'Reject',
                                ),
                            ],
                        ) 
                        : (appt.status == 'confirmed'
                            ? IconButton(
                                icon: const Icon(Icons.task_alt, color: Colors.blue), 
                                onPressed: () => _updateStatus(appt.id, 'completed'),
                                tooltip: 'Mark Completed',
                              )
                            : null),
                  ),
              );
          },
      );
  }

  Widget _buildEmployeeList() {
      final employees = _myShop?.employees ?? [];
      return SizedBox(
          height: 120,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: employees.length,
              itemBuilder: (context, index) {
                  final emp = employees[index]; 
                  return Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 12),
                      child: Column(
                          children: [
                              CircleAvatar(
                                  radius: 30,
                                  backgroundImage: NetworkImage(AppConstants.fixImageUrl(emp['image'])),
                              ),
                              const SizedBox(height: 8),
                              Text(emp['name'] ?? '', style: const TextStyle(color: Colors.white), overflow: TextOverflow.ellipsis),
                              Text(emp['role'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 10), overflow: TextOverflow.ellipsis),
                          ],
                      ),
                  );
              },
          ),
      );
  }

  Widget _buildGalleryGrid() {
      final images = _myShop?.images ?? [];
      return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
          itemCount: images.length,
          itemBuilder: (context, index) {
              return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(AppConstants.fixImageUrl(images[index]), fit: BoxFit.cover),
              );
          },
      );
  }

  Widget _buildDrawer(BuildContext context) {
      return Drawer(
          backgroundColor: AppColors.surface,
          child: ListView(
              children: [
                  const DrawerHeader(child: Center(child: Icon(Icons.cut, size: 50, color: AppColors.primary))),
                  ListTile(
                      leading: Icon(Icons.content_cut, color: AppColors.primary),
                      title: const Text('Manage Services', style: TextStyle(color: Colors.white)),
                      onTap: () {
                          Navigator.pop(context);
                          if (_shopId != null) {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => BarberServicesScreen(shopId: _shopId!)));
                          } else {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Shop not loaded')));
                          }
                      },
                  ),
                  ListTile(
                      leading: Icon(Icons.store, color: AppColors.primary),
                      title: const Text('Edit Shop Profile', style: TextStyle(color: Colors.white)),
                      onTap: () { Navigator.pop(context); Navigator.pushNamed(context, '/barber-shop'); },
                  ),
                  ListTile(
                      leading: Icon(Icons.photo_library, color: AppColors.primary),
                      title: const Text('Manage Gallery', style: TextStyle(color: Colors.white)),
                      onTap: () {
                          Navigator.pop(context);
                          if (_shopId != null) {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ManageGalleryScreen(shopId: _shopId!)));
                          }
                      },
                  ),
                  const Divider(color: Colors.white24),
                  
                  // Feature Placeholders
                  ListTile(
                      leading: Icon(Icons.analytics_outlined, color: AppColors.secondary),
                      title: const Text('Analytics', style: TextStyle(color: Colors.white)),
                      onTap: () {
                          Navigator.pop(context);
                          if (_shopId != null) {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => AnalyticsScreen(shopId: _shopId!)));
                          } else {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Shop not loaded')));
                          }
                      },
                  ),
                  ListTile(
                      leading: Icon(Icons.people_outline, color: AppColors.secondary),
                      title: const Text('My Team', style: TextStyle(color: Colors.white)),
                      onTap: () {
                          Navigator.pop(context);
                          if (_shopId != null) {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => MyTeamScreen(shopId: _shopId!)));
                          } else {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Shop not loaded')));
                          }
                      },
                  ),
                  ListTile(
                      leading: Icon(Icons.campaign_outlined, color: AppColors.secondary),
                      title: const Text('Promotions', style: TextStyle(color: Colors.white)),
                      onTap: () {
                          Navigator.pop(context);
                          if (_shopId != null) {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => PromotionsScreen(shopId: _shopId!)));
                          }
                      },
                  ),
                  ListTile(
                      leading: Icon(Icons.reviews_outlined, color: AppColors.secondary),
                      title: const Text('Reviews', style: TextStyle(color: Colors.white)),
                      onTap: () {
                          Navigator.pop(context);
                          if (_shopId != null) {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ReviewsScreen(shopId: _shopId!)));
                          } else {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Shop not loaded')));
                          }
                      },
                  ),
                  ListTile(
                      leading: Icon(Icons.settings_outlined, color: AppColors.secondary),
                      title: const Text('Settings', style: TextStyle(color: Colors.white)),
                      onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/profile-edit');
                      },
                  ),
                  
                  ListTile(
                      leading: Icon(Icons.help_outline, color: AppColors.secondary),
                      title: const Text('Help & Support', style: TextStyle(color: Colors.white)),
                      onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/support');
                      },
                  ),
                  const Divider(color: Colors.white24),
                  ListTile(
                      leading: Icon(Icons.logout, color: Colors.red),
                      title: const Text('Logout', style: TextStyle(color: Colors.red)),
                      onTap: () {
                          Provider.of<AuthProvider>(context, listen: false).logout();
                          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                      },
                  ),
              ],
          ),
      );
  }
}
