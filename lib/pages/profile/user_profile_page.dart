import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plantify/models/user_model.dart';
import 'package:plantify/services/user_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final _picker = ImagePicker();

  UserModel? _user;
  File? _localAvatar; // ảnh chọn từ máy
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _user = UserService.hiveGetUser();
    if (_user != null) {
      _nameCtl.text = _user!.name;
      _emailCtl.text = _user!.email;
    }
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _emailCtl.dispose();
    super.dispose();
  }

  ImageProvider? _avatarProvider() {
    if (_localAvatar != null) {
      return FileImage(_localAvatar!);
    }
    final url = _user?.imageUrl;
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http')) return NetworkImage(url);
    return FileImage(File(url)); // hỗ trợ lưu path local
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;

    if (_user == null) {
      return Scaffold(
        appBar: AppBar(title: Text(local.profile)), // Đa ngữ
        body: Center(child: Text(local.noUserInfo)), // Đa ngữ
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(local.profile), // Đa ngữ
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Avatar + nút đổi ảnh
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 56,
                      backgroundImage: _avatarProvider(),
                      child: _avatarProvider() == null
                          ? const Icon(Icons.person, size: 48)
                          : null,
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _pickAvatar,
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Tên
                TextFormField(
                  controller: _nameCtl,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: local.displayName, // Đa ngữ
                    prefixIcon: const Icon(Icons.person_outline),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? local.nameRequired : null, // Đa ngữ
                ),
                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: _emailCtl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: local.email, // Đa ngữ
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) {
                    final t = v?.trim() ?? '';
                    if (t.isEmpty) return local.emailRequired; // Đa ngữ
                    final ok = RegExp(r'^[\w\.\-]+@[\w\-]+\.[\w\.\-]+$').hasMatch(t);
                    return ok ? null : local.emailInvalid; // Đa ngữ
                  },
                ),

                const SizedBox(height: 24),

                // Nút lưu phía dưới (nếu bạn muốn cả trên AppBar và dưới)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(local.saveChanges), // Đa ngữ
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _pickAvatar() {
    final local = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(local.pickFromGallery), // Đa ngữ
              onTap: () async {
                Navigator.pop(context);
                final x = await _picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 85,
                  maxWidth: 2000,
                );
                if (x != null) setState(() => _localAvatar = File(x.path));
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(local.takePhoto), // Đa ngữ
              onTap: () async {
                Navigator.pop(context);
                final x = await _picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 85,
                  maxWidth: 2000,
                );
                if (x != null) setState(() => _localAvatar = File(x.path));
              },
            ),
            if (_localAvatar != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: Text(local.deleteImage, style: const TextStyle(color: Colors.red)), // Đa ngữ
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _localAvatar = null);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final local = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final updated = await UserService().updateProfileWithOptionalAvatar(
        current: _user!,                          // user hiện tại trong Hive
        name: _nameCtl.text.trim(),
        email: _emailCtl.text.trim(),
        newAvatar: _localAvatar,                  // File?; null nếu không đổi ảnh
      );

      if (!mounted) return;
      setState(() {
        _user = updated;
        _localAvatar = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(local.profileUpdateSuccess)),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      print(  'Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${local.saveError}: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
