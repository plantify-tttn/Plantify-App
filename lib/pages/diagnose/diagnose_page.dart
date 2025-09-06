import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/chat_message.dart';
import '../../provider/diagnose_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DiagnosePage extends StatefulWidget {
  const DiagnosePage({super.key});

  @override
  State<DiagnosePage> createState() => _DiagnosePageState();
}

class _DiagnosePageState extends State<DiagnosePage> {
  final _textCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _scrollToBottom() async {
    await Future.delayed(const Duration(milliseconds: 50));
    if (!_scrollCtrl.hasClients) return;
    _scrollCtrl.animateTo(
      _scrollCtrl.position.maxScrollExtent + 120,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Future<void> _sendText() async {
    final vm = context.read<DiagnoseProvider>();
    await vm.sendText(_textCtrl.text);
    _textCtrl.clear();
    await _scrollToBottom();
  }

  Future<void> _takePhoto() async {
    final vm = context.read<DiagnoseProvider>();
    final picker = ImagePicker();
    final x = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
      imageQuality: 90,
    );
    if (x == null) return;
    await vm.sendImage(File(x.path));
    await _scrollToBottom();
  }

  Future<void> _pickGallery() async {
    final vm = context.read<DiagnoseProvider>();
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (x == null) return;
    await vm.sendImage(File(x.path));
    await _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DiagnoseProvider>();
    final local = AppLocalizations.of(context)!;
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    return Scaffold(
      backgroundColor: const Color(0xff0b0f14),
      appBar: AppBar(
        title: Text(
          local.plantDiagnose
        ),
        backgroundColor: const Color(0xff0b0f14),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: vm.sending ? null : vm.clear,
            icon: const Icon(Icons.delete_sweep_rounded),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _ChatList(messages: vm.messages, controller: _scrollCtrl)),
          const Divider(height: 1),
          _InputBar(
            controller: _textCtrl,
            sending: vm.sending,
            onSendText: _sendText,
            onTakePhoto: _takePhoto,
            onPickGallery: _pickGallery,
          ),
          SafeArea(top: false, child: SizedBox(height: 4)),
        ],
      ),
    );
  }
}

class _ChatList extends StatelessWidget {
  final List<ChatMessage> messages;
  final ScrollController controller;
  const _ChatList({required this.messages, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      itemCount: messages.length,
      itemBuilder: (context, i) {
        final m = messages[i];
        return Align(
          alignment: m.isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: _Bubble(message: m),
          ),
        );
      },
    );
  }
}

class _Bubble extends StatelessWidget {
  final ChatMessage message;
  const _Bubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final bg = isUser ? const Color(0xff156a3a) : const Color(0xff1b2430);
    final sending = context.watch<DiagnoseProvider>().sending;

    Widget mainChild;
    if (message.image != null) {
      mainChild = ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => Dialog(
                backgroundColor: Colors.black,
                insetPadding: EdgeInsets.zero,
                child: InteractiveViewer(
                  child: Image.file(message.image!, fit: BoxFit.contain),
                ),
              ),
            );
          },
          child: Image.file(
            message.image!,
            fit: BoxFit.cover,
            width: MediaQuery.of(context).size.width * 0.56,
            height: MediaQuery.of(context).size.width * 0.56,
          ),
        ),
      );
    } else {
      // Text + optional quick replies
      final textWidget = SelectableText(
        message.text ?? '',
        style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
      );

      final hasOptions = (message.options?.isNotEmpty ?? false);

      if (hasOptions && !isUser) {
        final optionsWrap = Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 6,
            children: message.options!
                .map(
                  (opt) => ActionChip(
                    label: Text(
                      opt,
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: const Color(0xff263141),
                    onPressed: sending
                        ? null
                        : () {
                            // gửi option như một câu hỏi mới
                            context.read<DiagnoseProvider>().sendText(opt);
                          },
                  ),
                )
                .toList(),
          ),
        );

        mainChild = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [textWidget, optionsWrap],
        );
      } else {
        mainChild = textWidget;
      }
    }

    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
      padding: message.image == null
          ? const EdgeInsets.symmetric(horizontal: 12, vertical: 10)
          : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: message.image == null ? bg : Colors.transparent,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(14),
          topRight: const Radius.circular(14),
          bottomLeft: Radius.circular(isUser ? 14 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 14),
        ),
      ),
      child: mainChild,
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSendText;
  final VoidCallback onTakePhoto;
  final VoidCallback onPickGallery;

  const _InputBar({
    required this.controller,
    required this.sending,
    required this.onSendText,
    required this.onTakePhoto,
    required this.onPickGallery,
  });

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final hint = local.enterAskorTake;
    return Container(
      color: const Color(0xff0f151d),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        children: [
          _IconBtn(
            icon: Icons.photo_camera,
            tooltip: local.takePhoto,
            onTap: sending ? null : onTakePhoto,
          ),
          const SizedBox(width: 6),
          _IconBtn(
            icon: Icons.photo,
            tooltip: local.choosePhoto,
            onTap: sending ? null : onPickGallery,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xff1b2430),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xff263141), width: 1),
              ),
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => sending ? null : onSendText(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _IconBtn(
            icon: sending ? Icons.hourglass_top_rounded : Icons.send,
            tooltip: local.send,
            onTap: sending ? null : onSendText,
            activeColor: const Color(0xff2ecc71),
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final Color? activeColor;

  const _IconBtn({
    required this.icon,
    required this.tooltip,
    this.onTap,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = onTap == null ? Colors.white24 : (activeColor ?? Colors.white);
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onTap,
        radius: 24,
        child: CircleAvatar(
          backgroundColor: Colors.white12,
          child: Icon(icon, color: color),
        ),
      ),
    );
  }
}
