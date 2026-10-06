import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/shop_provider.dart';
import '../models/shop_model.dart';
import '../utils/constants.dart';

class ManageGalleryScreen extends StatefulWidget {
  final String shopId;
  const ManageGalleryScreen({super.key, required this.shopId});

  @override
  State<ManageGalleryScreen> createState() => _ManageGalleryScreenState();
}

class _ManageGalleryScreenState extends State<ManageGalleryScreen> {
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
      // Handle error or refetch
    }
  }

  Future<void> _addGalleryImage() async {
      if (kIsWeb) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not supported on web')));
        return;
      }

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      try {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Uploading...')));
          final url = await Provider.of<ShopProvider>(context, listen: false).uploadImage(image.path);
          await Provider.of<ShopProvider>(context, listen: false).addGalleryImage(widget.shopId, url);
          setState(() { _loadShop(); });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to Gallery!')));
      } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
  }

  @override
  Widget build(BuildContext context) {
    // Reload shop from provider to ensure up-to-date image list
    final shops = Provider.of<ShopProvider>(context).shops;
    if (shops.isNotEmpty) {
       try {
         _shop = shops.firstWhere((s) => s.id == widget.shopId);
       } catch (_) {}
    }
    
    final images = _shop?.images ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Manage Gallery', style: GoogleFonts.outfit(color: AppColors.primary)),
        backgroundColor: AppColors.background,
        iconTheme: IconThemeData(color: AppColors.secondary),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addGalleryImage,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_photo_alternate, color: Colors.black),
      ),
      body: Column(
        children: [
           Padding(
             padding: const EdgeInsets.all(16.0),
             child: Text('Drag images to the trash bin to remove them.', style: TextStyle(color: Colors.grey)),
           ),
           Expanded(
             child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
                itemCount: images.length,
                itemBuilder: (context, index) {
                    final imgUrl = images[index];
                    return Draggable<String>(
                        data: imgUrl,
                        feedback: Opacity(
                          opacity: 0.7,
                          child: SizedBox(
                            width: 100, 
                            height: 100, 
                            child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(AppConstants.fixImageUrl(imgUrl), fit: BoxFit.cover))
                          ),
                        ),
                        childWhenDragging: Opacity(opacity: 0.3, child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(AppConstants.fixImageUrl(imgUrl), fit: BoxFit.cover))),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(AppConstants.fixImageUrl(imgUrl), fit: BoxFit.cover),
                        ),
                    );
                },
             ),
           ),

           const SizedBox(height: 20),
           Align(
             alignment: Alignment.bottomCenter,
             child: AnimatedTrashBin(
               onAccept: (imageUrl) async {
                  try {
                      await Provider.of<ShopProvider>(context, listen: false).removeGalleryImage(widget.shopId, images, imageUrl);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image Removed')));
                  } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to remove: $e')));
                  }
               },
             ),
           ),
           const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class AnimatedTrashBin extends StatefulWidget {
  final Function(String) onAccept;
  const AnimatedTrashBin({super.key, required this.onAccept});

  @override
  State<AnimatedTrashBin> createState() => _AnimatedTrashBinState();
}

class _AnimatedTrashBinState extends State<AnimatedTrashBin> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _lidAnimation;
  late Animation<double> _scaleAnimation;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    _lidAnimation = Tween<double>(begin: 0, end: -0.5).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onWillAccept: (data) {
        _controller.forward();
        setState(() => _isHovering = true);
        return true;
      },
      onLeave: (data) {
        _controller.reverse();
        setState(() => _isHovering = false);
      },
      onAccept: (data) {
        _controller.reverse();
        setState(() => _isHovering = false);
        widget.onAccept(data);
      },
      builder: (context, candidateData, rejectedData) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: _isHovering ? Colors.red.withOpacity(0.2) : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Bin Body
                    Positioned(
                      top: 40,
                      child: Container(
                        width: 40,
                        height: 50,
                        decoration: BoxDecoration(
                          color: _isHovering ? Colors.red : Colors.grey,
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Divider(color: Colors.white.withOpacity(0.3), height: 1, indent: 8, endIndent: 8),
                            Divider(color: Colors.white.withOpacity(0.3), height: 1, indent: 8, endIndent: 8),
                          ],
                        ),
                      ),
                    ),
                    // Bin Lid
                    Positioned(
                      top: 32,
                      child: Transform.rotate(
                        angle: _lidAnimation.value,
                        alignment: Alignment.bottomRight, // Pivot point for lid
                        origin: const Offset(15, 0),
                        child: Container(
                          width: 50,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _isHovering ? Colors.red : Colors.grey[700],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Container(
                                width: 20, height: 2, 
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(2))
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
