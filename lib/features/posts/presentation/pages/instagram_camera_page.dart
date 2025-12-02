import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:mangxahoi/core/providers/auth_provider.dart';
import 'package:mangxahoi/core/providers/posts_provider.dart';

class InstagramCameraPage extends StatefulWidget {
  const InstagramCameraPage({super.key});

  @override
  State<InstagramCameraPage> createState() => _InstagramCameraPageState();
}

class _InstagramCameraPageState extends State<InstagramCameraPage>
    with SingleTickerProviderStateMixin {
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;
  final _captionController = TextEditingController();
  final _locationController = TextEditingController();
  bool _isUploading = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // Filter states
  String _selectedFilter = 'Normal';
  final List<String> _filters = [
    'Normal',
    'Clarendon',
    'Gingham',
    'Moon',
    'Lark',
    'Reyes',
    'Juno',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _captionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        _animationController.forward(from: 0.0);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi chọn ảnh: $e')));
      }
    }
  }

  Future<void> _uploadPost() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng chọn ảnh')));
      return;
    }

    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng đăng nhập')));
      return;
    }

    setState(() => _isUploading = true);

    try {
      final user = authProvider.currentUser!;
      await context.read<PostsProvider>().createPost(
        userId: user.id,
        userName: user.displayName ?? user.email,
        userPhotoUrl: user.photoUrl,
        imagePath: _selectedImage!.path,
        caption: _captionController.text.isNotEmpty
            ? _captionController.text
            : null,
      );

      if (mounted) {
        setState(() {
          _selectedImage = null;
          _captionController.clear();
          _locationController.clear();
          _isUploading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Đã đăng bài thành công!'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _selectedImage == null
            ? _buildCameraSelection()
            : _buildEditScreen(),
      ),
    );
  }

  // Camera selection screen
  Widget _buildCameraSelection() {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Spacer(),
              const Text(
                'Tạo bài viết mới',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              const SizedBox(width: 48),
            ],
          ),
        ),

        // Main content
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white30, width: 3),
                ),
                child: const Icon(
                  Icons.photo_camera,
                  size: 80,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 40),

              // Title
              const Text(
                'Thêm ảnh hoặc video',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 60),

              // Camera button
              _buildActionButton(
                icon: Icons.camera_alt,
                label: 'Chụp ảnh',
                gradient: const LinearGradient(
                  colors: [Color(0xFFE91E63), Color(0xFF9C27B0)],
                ),
                onTap: () => _pickImage(ImageSource.camera),
              ),

              const SizedBox(height: 16),

              // Gallery button
              _buildActionButton(
                icon: Icons.photo_library,
                label: 'Chọn từ thư viện',
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
                ),
                onTap: () => _pickImage(ImageSource.gallery),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: gradient.colors.first.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Edit screen with filters
  Widget _buildEditScreen() {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: const BoxDecoration(color: Color(0xFF1C1C1E)),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _selectedImage = null;
                    _captionController.clear();
                    _locationController.clear();
                  });
                },
              ),
              const Spacer(),
              const Text(
                'Bài viết mới',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _isUploading ? null : _uploadPost,
                child: _isUploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.blue,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Chia sẻ',
                        style: TextStyle(
                          color: Color(0xFF0095F6),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
        ),

        // Image preview with filter
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Image
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.4,
                    ),
                    child: Image.file(
                      _selectedImage!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Filters
                Container(
                  height: 100,
                  color: const Color(0xFF1C1C1E),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    itemCount: _filters.length,
                    itemBuilder: (context, index) {
                      final filter = _filters[index];
                      final isSelected = _selectedFilter == filter;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        },
                        child: Container(
                          width: 70,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF0095F6)
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.file(
                                    _selectedImage!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                filter,
                                style: TextStyle(
                                  color: isSelected
                                      ? const Color(0xFF0095F6)
                                      : Colors.white70,
                                  fontSize: 11,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // User info and caption
                Container(
                  color: const Color(0xFF1C1C1E),
                  padding: const EdgeInsets.all(12),
                  child: Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      final user = authProvider.currentUser;
                      return Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Avatar
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: user?.photoUrl != null
                                    ? NetworkImage(user!.photoUrl!)
                                    : null,
                                child: user?.photoUrl == null
                                    ? const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              // Caption input
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user?.displayName ??
                                          user?.email ??
                                          'User',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: _captionController,
                                      maxLines: 5,
                                      enabled: !_isUploading,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      decoration: const InputDecoration(
                                        hintText: 'Viết chú thích...',
                                        hintStyle: TextStyle(
                                          color: Colors.white54,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const Divider(color: Colors.white24, height: 24),

                          // Location
                          _buildOptionTile(
                            icon: Icons.location_on_outlined,
                            title: 'Thêm vị trí',
                            onTap: () {
                              // Show location picker
                            },
                          ),

                          const Divider(color: Colors.white24, height: 1),

                          // Tag people
                          _buildOptionTile(
                            icon: Icons.person_add_outlined,
                            title: 'Gắn thẻ người khác',
                            onTap: () {
                              // Show people picker
                            },
                          ),

                          const Divider(color: Colors.white24, height: 1),

                          // Add music
                          _buildOptionTile(
                            icon: Icons.music_note_outlined,
                            title: 'Thêm nhạc',
                            onTap: () {
                              // Show music picker
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white54),
      onTap: onTap,
    );
  }
}
