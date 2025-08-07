import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class IdentifyPage extends StatefulWidget {
  const IdentifyPage({super.key});

  @override
  State<IdentifyPage> createState() => _IdentifyPageState();
}

class _IdentifyPageState extends State<IdentifyPage> {
  CameraController? _controller;
  bool _isInitialized = false;
  late List<CameraDescription> _cameras;
  int _selectedCameraIndex = 0;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }


  Future<void> _captureImage() async {
    if (!_controller!.value.isInitialized) return;

    final file = await _controller!.takePicture();
    setState(() {
      _imagePath = file.path;
    });
    // 👉 TODO: Gửi ảnh file.path để phân tích
    // print("Ảnh chụp: ${file.path}");
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
      // print("Ảnh từ thư viện: ${image.path}");
      // 👉 TODO: Gửi ảnh image.path để phân tích
    }
  }
  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    final selectedCamera = _cameras[_selectedCameraIndex];

    _controller = CameraController(selectedCamera, ResolutionPreset.medium);
    await _controller!.initialize();

    if (!mounted) return;
    setState(() {
      _isInitialized = true;
    });
  }
  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return; // Không có camera thứ 2

    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;

    await _controller?.dispose();
    setState(() {
      _isInitialized = false;
    });

    await _initializeCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          !_isInitialized
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  SizedBox.expand(
                    child: _imagePath != null
                        ? Image.file(File(_imagePath!), fit: BoxFit.cover)
                        : CameraPreview(_controller!),
                  ),
                  Positioned(
                    bottom: 60,
                    left: 30,
                    right: 30,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 📁 Nút chọn ảnh từ thư viện
                        IconButton(
                          icon: const Icon(
                            Icons.photo,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: _pickFromGallery,
                        ),

                        // 📸 Nút chụp hình
                        GestureDetector(
                          onTap: _captureImage,
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.switch_camera,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: _switchCamera,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
