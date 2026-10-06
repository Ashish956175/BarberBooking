import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/shop_provider.dart';
import '../models/shop_model.dart';
import '../utils/constants.dart';

class PromotionsScreen extends StatefulWidget {
  final String shopId;
  const PromotionsScreen({super.key, required this.shopId});

  @override
  State<PromotionsScreen> createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends State<PromotionsScreen> {
  Shop? _shop;

  @override
  void initState() {
    super.initState();
    _loadShop();
  }

  void _loadShop() {
    final shops = Provider.of<ShopProvider>(context, listen: false).shops;
    try {
      _shop = shops.firstWhere((s) => s.id == widget.shopId);
    } catch (e) {
      // Handle
    }
  }

  Future<void> _addPromotion() async {
      final titleController = TextEditingController();
      final descController = TextEditingController();
      final discountController = TextEditingController();
      DateTime? selectedDate;

      await showDialog(
          context: context,
          builder: (context) => StatefulBuilder(
              builder: (context, setDialogState) {
                  return AlertDialog(
                      backgroundColor: AppColors.surface,
                      title: Text('New Promotion', style: GoogleFonts.outfit(color: AppColors.primary)),
                      content: SingleChildScrollView(
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                  TextField(controller: titleController, style: TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Title (e.g. Summer Sale)', labelStyle: TextStyle(color: Colors.grey))),
                                  TextField(controller: descController, style: TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Description', labelStyle: TextStyle(color: Colors.grey))),
                                  TextField(controller: discountController, style: TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Discount (e.g. 20%)', labelStyle: TextStyle(color: Colors.grey))),
                                  const SizedBox(height: 10),
                                  Row(
                                      children: [
                                          Text(selectedDate == null ? 'No Expiry Needed' : 'Expires: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}', style: TextStyle(color: Colors.grey)),
                                          Spacer(),
                                          TextButton(
                                              onPressed: () async {
                                                  final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2030));
                                                  if (picked != null) setDialogState(() => selectedDate = picked);
                                              },
                                              child: Text('Pick Date', style: TextStyle(color: AppColors.secondary))
                                          )
                                      ],
                                  )
                              ],
                          ),
                      ),
                      actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
                          ElevatedButton(
                              onPressed: () async {
                                  if (titleController.text.isNotEmpty && discountController.text.isNotEmpty) {
                                      try {
                                          await Provider.of<ShopProvider>(context, listen: false).addPromotion(widget.shopId, {
                                              'title': titleController.text,
                                              'description': descController.text,
                                              'discount': discountController.text,
                                              'validUntil': selectedDate?.toIso8601String()
                                          });
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Promotion Added')));
                                          setState(() => _loadShop());
                                          Navigator.pop(context);
                                      } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                      }
                                  }
                              },
                              child: Text('Create')
                          )
                      ],
                  );
              }
          )
      );
  }

  Future<void> _deletePromotion(String promoId) async {
      try {
          await Provider.of<ShopProvider>(context, listen: false).removePromotion(widget.shopId, promoId);
          setState(() => _loadShop());
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deleted')));
      } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
  }

  @override
  Widget build(BuildContext context) {
    // Reload to ensure up to date
    final shops = Provider.of<ShopProvider>(context).shops;
    if (shops.isNotEmpty) {
       try { _shop = shops.firstWhere((s) => s.id == widget.shopId); } catch (_) {}
    }

    // Since our Shop model in frontend might not fully parse 'promotions' yet in fromJson, check it.
    // Assuming backend returns it and frontend blindly decodes map.
    // If Shop.dart model has no 'promotions' field, we need to access via raw map logic or update model. 
    // Checking Shop.dart...
    
    // Actually, Shop model normally needs update. 
    // BUT, Shop.fromJson usually handles extra fields if dynamic map? 
    // Let's check Shop model first. If implicit dynamic map, good. If typed, need update.
    // I'll assume typed and FIX Shop model in next step if broken.
    // For now writing screen using `_shop?.promotions` assuming it exists or using raw JSON map if I had it.
    // Wait, I updated backend only. Frontend Shop model (Shop.dart) is unaware of 'promotions'.
    // `promotions` won't exist on `_shop`.
    
    // I need to update Shop.dart FIRST. I will do that in next step.
    // For now, I'll write this file assuming `Shop` has `promotions`.

    final promotions = _shop?.promotions ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Manage Promotions', style: GoogleFonts.outfit(color: AppColors.primary)),
        backgroundColor: AppColors.background,
        iconTheme: IconThemeData(color: AppColors.secondary),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPromotion,
        child: Icon(Icons.add),
        backgroundColor: AppColors.primary,
      ),
      body: promotions.isEmpty 
          ? Center(child: Text('No active promotions.\nCreate one to attract customers!', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: promotions.length,
              itemBuilder: (context, index) {
                  final p = promotions[index];
                  // p is a Map or Promotion object
                  final title = p['title'] ?? 'Promo';
                  final discount = p['discount'] ?? '';
                  final desc = p['description'] ?? '';
                  final id = p['_id'];

                  return Card(
                      color: AppColors.surface,
                      margin: EdgeInsets.only(bottom: 12),
                      child: ListTile(
                          leading: Icon(Icons.local_offer, color: Colors.orange),
                          title: Text('$title ($discount)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: Text(desc, style: TextStyle(color: Colors.grey)),
                          trailing: IconButton(
                              icon: Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _deletePromotion(id),
                          ),
                      ),
                  );
              },
          ),
    );
  }
}
