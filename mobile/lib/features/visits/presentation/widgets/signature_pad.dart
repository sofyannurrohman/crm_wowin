import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SignaturePad extends StatefulWidget {
  final Function(Uint8List? signature) onChanged;

  const SignaturePad({super.key, required this.onChanged});

  @override
  State<SignaturePad> createState() => _SignaturePadState();
}

class _SignaturePadState extends State<SignaturePad> {
  late SignatureController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
      onDrawEnd: () async {
        final signature = await _controller.toPngBytes();
        widget.onChanged(signature);
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tanda Tangan Pelanggan',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF374151)),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Signature(
                controller: _controller,
                height: 150,
                backgroundColor: Colors.grey.shade50,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        _controller.clear();
                        widget.onChanged(null);
                      },
                      icon: const Icon(LucideIcons.eraser, size: 14),
                      label: const Text('Hapus', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
