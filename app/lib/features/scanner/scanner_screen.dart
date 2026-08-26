import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/theme_controller.dart';
import '../../presentation/providers/solver_provider.dart';
import '../settings/groq_setup_screen.dart';
import 'question_confirmation_screen.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isScanning = false;

  Future<void> _pickImage(ImageSource source) async {
    setState(() => _isScanning = true);
    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 88,
      );

      if (photo != null && mounted) {
        // Run AI OCR recognition using multi-stage MathOcrService
        final recognizedText = await ref
            .read(solverProvider.notifier)
            .processImageAndRecognize(photo.path);

        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => QuestionConfirmationScreen(
                imagePath: photo.path,
                initialQuestion: recognizedText,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Camera error: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }

  void _openManualEditor() {
    ref.read(solverProvider.notifier).setRecognizedQuestion('');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const QuestionConfirmationScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeControllerProvider);
    final storage = ref.watch(storageServiceProvider);
    final hasGroqKey = storage.getGroqApiKey() != null && storage.getGroqApiKey()!.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Scan Math Question',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note, color: Colors.white),
            tooltip: 'Type Question Manually',
            onPressed: _openManualEditor,
          ),
          IconButton(
            icon: Icon(
              Icons.bolt,
              color: hasGroqKey ? const Color(0xFF10B981) : Colors.amber,
            ),
            tooltip: hasGroqKey ? 'Groq AI Active' : 'Setup Groq AI Key',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const GroqSetupScreen()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background / Scanner Viewfinder
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Viewfinder Frame
                Container(
                  width: MediaQuery.of(context).size.width * 0.86,
                  height: MediaQuery.of(context).size.width * 0.58,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: hasGroqKey ? const Color(0xFF10B981) : const Color(0xFF38BDF8),
                      width: 2.5,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Scanner Aim Laser
                      Container(
                        height: 2,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: (hasGroqKey ? const Color(0xFF10B981) : const Color(0xFF38BDF8)).withAlpha(220),
                          boxShadow: [
                            BoxShadow(
                              color: hasGroqKey ? const Color(0xFF10B981) : const Color(0xFF38BDF8),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(140),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Align math equation within frame',
                          style: TextStyle(
                            color: Colors.white.withAlpha(220),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (!hasGroqKey) ...[
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const GroqSetupScreen()),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 30),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.amber.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.withAlpha(80)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bolt, color: Colors.amber, size: 16),
                          SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Tip: Tap to add a free Groq API key for 10x faster AI Vision',
                              style: TextStyle(
                                color: Colors.amber,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  const Text(
                    '⚡ Powered by Groq Ultra-Fast AI Vision',
                    style: TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),

          if (_isScanning)
            Container(
              color: Colors.black87,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: hasGroqKey ? const Color(0xFF10B981) : theme.primaryColor,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'AI is recognizing mathematical equation...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Bottom Controls (Camera & Gallery buttons)
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Gallery button
                IconButton.filledTonal(
                  iconSize: 28,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white24,
                    padding: const EdgeInsets.all(16),
                  ),
                  icon: const Icon(Icons.photo_library_outlined, color: Colors.white),
                  onPressed: () => _pickImage(ImageSource.gallery),
                ),

                // Shutter / Capture Button
                GestureDetector(
                  onTap: () => _pickImage(ImageSource.camera),
                  child: Container(
                    width: 76,
                    height: 76,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: hasGroqKey ? const Color(0xFF10B981) : const Color(0xFF38BDF8),
                        width: 4,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: hasGroqKey ? const Color(0xFF10B981) : const Color(0xFF38BDF8),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ),

                // Manual type button
                IconButton.filledTonal(
                  iconSize: 28,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white24,
                    padding: const EdgeInsets.all(16),
                  ),
                  icon: const Icon(Icons.keyboard, color: Colors.white),
                  onPressed: _openManualEditor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
