import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plantify/apps/router/router.dart';
import 'package:plantify/apps/router/router_name.dart';
import 'package:plantify/models/plants_model.dart';
import 'package:plantify/provider/search_vm.dart';
import 'package:plantify/services/identify_service.dart';
import 'package:plantify/services/plants_service.dart';
import 'package:plantify/services/user_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math_64.dart' show Matrix4;
import 'dart:math' as math;

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
  PlantModel? _recognizedPlant;

  String? _imagePath;
  bool _uploading = false; // tránh bấm nhiều lần
  final String _token = UserService.getToken();

  bool get _isFrontCamera =>
      _controller?.description.lensDirection == CameraLensDirection.front;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SearchVm>(context, listen: false).getPlanItems();
    });
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() => _isInitialized = false);
        return;
      }

      final selectedCamera = _cameras[_selectedCameraIndex];
      _controller = CameraController(
        selectedCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await _controller!.initialize();

      if (!mounted) return;
      setState(() => _isInitialized = true);
    } catch (e) {
      setState(() => _isInitialized = false);
    }
  }

  // Preview camera full màn hình
  Widget _buildFullScreenPreview() {
    final c = _controller!;
    return Center(
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity(),
        child: CameraPreview(c),
      ),
    );
  }

  // Ảnh đã chụp full màn hình
  Widget _buildFullScreenCapturedImage() {
  final img = Image.file(File(_imagePath!));
  final needMirror = _isFrontCamera; // nếu bạn thấy vẫn đúng bên, đặt = false
  final child = FittedBox(
    fit: BoxFit.contain,
    child: img,
  );
  return SizedBox.expand(
    child: Container(
      color: Colors.black,
      child: needMirror
          ? Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(math.pi), // mirror captured
              child: child,
            )
          : child,
    ),
  );
}



  Future<void> _captureImage() async {
    final c = _controller;
    if (c == null || !c.value.isInitialized || c.value.isTakingPicture) return;

    final file = await c.takePicture();
    if (!mounted) return;
    setState(() => _imagePath = file.path);
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _imagePath = image.path);
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    await _controller?.dispose();
    setState(() => _isInitialized = false);
    await _initializeCamera();
  }

  void _clearImage() {
    setState(() => _imagePath = null);
  }

  Future<void> _sendSeed() async {
    if (_imagePath == null || _uploading) return;

    setState(() => _uploading = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('⏫ Đang tải ảnh...')),
    );

    try {
      final res =
          await IdentifyService().sendSeedImage(File(_imagePath!), _token);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (res != '') {
        String? plantId;
        plantId = res;

        if (plantId.isNotEmpty) {
          final plant = PlantsService().getPlantById(plantId);
          if (plant != null) {
            setState(() => _recognizedPlant = plant);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('✅ Nhận diện: ${plant.name}')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('⚠️ Không tìm thấy thông tin cây theo ID.')),
            );
          }
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('❌ Chưa nhận diện được')));
        }
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('❌ gửi thất bại')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('❌ Lỗi: $e')));
      // print(e);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = _imagePath != null;
    final locale = Localizations.localeOf(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: !_isInitialized
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  // Preview / Captured
                  Positioned.fill(
                    child: hasImage
                        ? _buildFullScreenCapturedImage()
                        : _buildFullScreenPreview(),
                  ),

                  // Gradient top
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    height: 120,
                    child: IgnorePointer(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black54, Colors.transparent],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Bottom controls
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: 24,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Gallery / Delete
                        CircleAvatar(
                          backgroundColor: Colors.white24,
                          child: IconButton(
                            icon: Icon(
                              hasImage ? Icons.delete_outline : Icons.photo,
                              color: Colors.white,
                            ),
                            onPressed:
                                hasImage ? _clearImage : _pickFromGallery,
                          ),
                        ),

                        // Shutter (khi chưa chụp)
                        GestureDetector(
                          onTap: hasImage ? null : _captureImage,
                          child: Container(
                            width: 78,
                            height: 78,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 5),
                              color: hasImage
                                  ? Colors.white24
                                  : Colors.transparent,
                            ),
                            child: hasImage
                                ? const Center(
                                    child: Icon(Icons.check,
                                        color: Colors.white, size: 36),
                                  )
                                : null,
                          ),
                        ),

                        // Switch camera
                        CircleAvatar(
                          backgroundColor: Colors.white24,
                          child: IconButton(
                            icon: const Icon(Icons.cameraswitch,
                                color: Colors.white),
                            onPressed: _switchCamera,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Khi đã chụp: Retake & Use
                  if (hasImage)
                    Positioned(
                      bottom: 120,
                      left: 24,
                      right: 24,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.white24,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                            ),
                            onPressed: _uploading
                                ? null
                                : () {
                                    setState(() {
                                      _recognizedPlant = null;
                                      _clearImage(); // <-- GỌI HÀM
                                    });
                                  },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retake'),
                          ),
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.green.withOpacity(0.5),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                            ),
                            onPressed: _uploading ? null : _sendSeed,
                            icon: _uploading
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.send),
                            label: Text(_uploading ? 'Uploading...' : 'Use'),
                          ),
                        ],
                      ),
                    ),
                  if (_recognizedPlant != null)
                    Positioned(
                      bottom: 180,
                      right: 20,
                      left: 20,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 12),
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          elevation: 6,
                          shadowColor: Colors.black45,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                          final p = _recognizedPlant!;
                          context.goNamed(RouterName.detailPlant, extra: p);
                          setState(() {
                            _recognizedPlant = null;
                            _clearImage(); // <-- GỌI HÀM
                          });
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.eco,
                                size: 22, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              'Đây là ${_recognizedPlant!.name}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.arrow_forward_ios,
                                size: 16, color: Colors.white70),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
