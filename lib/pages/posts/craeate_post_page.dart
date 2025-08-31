import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:plantify/apps/router/router.dart';
import 'package:plantify/provider/post_provider.dart';
import 'package:plantify/services/post_service.dart';
import 'package:plantify/services/user_service.dart';
import 'package:plantify/theme/color.dart';
import 'package:provider/provider.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _contentController = TextEditingController();
  final _picker = ImagePicker();
  final int _maxChars = 500;
  File? _imageFile;
  bool _submitting = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 2000,
    );
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _takePhoto() async {
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 2000,
    );
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  void _showImageSourceSheet() {
    final local = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Wrap(
            runSpacing: 8,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(local.pickFromGallery), // Đa ngữ
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: Text(local.takePhoto), // Đa ngữ
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
              if (_imageFile != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: Text(local.deleteImage, style: const TextStyle(color: Colors.red)), // Đa ngữ
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _imageFile = null);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitPost() async {
  final local = AppLocalizations.of(context)!;
  final content = _contentController.text.trim();

  if (content.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(local.emptyPostContent)),
    );
    return;
  }

  setState(() => _submitting = true);

  try {
    //🟢 Gọi API tạo post
    final token = UserService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Missing token');
    }
    if (_imageFile != null) {
      context.read<PostProvider>().craetePost(content: content, image: _imageFile!);
      // await PostService().createPost(
      //   content: content,
      //   image: _imageFile!,
      //   token: token,
      // );
      if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    local.postSuccess,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating, // nổi lên trên, không dính sát mép dưới
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            duration: const Duration(seconds: 2), // tự ẩn sau 2s
            elevation: 4,
          ),
        );

        _contentController.clear();
        setState(() => _imageFile = null);
        context.pop();
    } else{
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Bạn chưa chọn ảnh',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color.fromARGB(255, 160, 67, 67),
            behavior: SnackBarBehavior.floating, // nổi lên trên, không dính sát mép dưới
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            duration: const Duration(seconds: 2), // tự ẩn sau 2s
            elevation: 4,
          ),
        );
    }
    //print("✅ Post created: $res");

    

  } catch (e) {
    if (!mounted) return;
  //  print(  '❌ Error creating post: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${local.postError}: $e')),
    );
  } finally {
    if (mounted) setState(() => _submitting = false);
  }
}


  bool get _canSubmit =>
      _contentController.text.trim().isNotEmpty && !_submitting;

  @override
  Widget build(BuildContext context) {
    final remain = _maxChars - _contentController.text.characters.length;
    final local = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
          tooltip: local.back, // Đa ngữ
        ),
        title: Text(local.createPost), // Đa ngữ
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Card nhập nội dung
                Card(
                  color: Colors.green[50],
                  elevation: 1.5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _contentController,
                          minLines: 4,
                          maxLines: null,
                          maxLength: _maxChars,
                          style: TextStyle(
                            color: Color(MyColor.black)
                          ),
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: local.postHint, // Đa ngữ
                            hintStyle: TextStyle(color: Colors.grey[600]),
                            border: InputBorder.none,
                            counterText: '',
                          ),
                        ),
                        Row(
                          children: [
                            const Spacer(),
                            Text(
                              '$remain',
                              style: TextStyle(
                                color: remain < 0
                                    ? Colors.red
                                    : Theme.of(context).textTheme.bodySmall?.color,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Khu vực ảnh
                if (_imageFile != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        AspectRatio(
                          aspectRatio: 4 / 3,
                          child: Image.file(
                            _imageFile!,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
                              onPressed: () => setState(() => _imageFile = null),
                              tooltip: local.deleteImage, // Đa ngữ
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _showImageSourceSheet,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add_photo_alternate_outlined, size: 36),
                          const SizedBox(height: 8),
                          Text(local.addImageOptional), // Đa ngữ
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                // Nút đăng bài
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _canSubmit ? _submitPost : null,
                    style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), backgroundColor: Color(MyColor.pr3)),
                    child: _submitting
                        ? const SizedBox(
                            height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(local.submitPost, style: TextStyle(
                          color: Color(MyColor.white),
                          fontWeight: FontWeight.bold,
                          fontSize: 16
                        ),), // Đa ngữ
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
