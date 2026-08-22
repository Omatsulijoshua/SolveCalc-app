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

  void _showGroqRequiredSheet(BuildContext context) {
    final theme = ref.read(themeControllerProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.surfaceColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.bolt, color: Colors.amber, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Groq AI Setup Required',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'To snap & recognize questions with your camera',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.backgroundColor.withAlpha(150),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  _benefitRow(Icons.camera_alt, 'Instant Camera Math OCR with Groq Vision', theme),
                  const SizedBox(height: 10),
                  _benefitRow(Icons.auto_awesome, 'Step-by-Step AI solutions & Learn Mode', theme),
                  const SizedBox(height: 10),
                  _benefitRow(Icons.lock_open, '100% Free with your personal Groq key', theme),
                ],
              ),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.bolt, color: Colors.white),
              label: const Text(
                'Set Up Free Groq AI Now',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const GroqSetupScreen()),
                );
              },
            ),
            const SizedBox(height: 10),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: theme.textSecondaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                _openManualEditor();
              },
              child: const Text('Or Type Equation Manually'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _benefitRow(IconData icon, String text, dynamic theme) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF10B981)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final storage = ref.read(storageServiceProvider);
    final hasGroqKey = storage.getGroqApiKey() != null && storage.getGroqApiKey()!.isNotEmpty;

    // Restrict AI Snapping if Groq AI is not setup
    if (!hasGroqKey) {
      _showGroqRequiredSheet(context);
      return;
    }

    setState(() => _isScanning = true);
    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );

      if (photo != null && mounted) {
        // Run AI OCR recognition using Groq Vision
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
          SnackBar(content: Text('Could not process image: ${e.toString()}')),
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
            tooltip: hasGroqKey ? 'Groq AI Active' : 'Setup Groq AI',
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
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: MediaQuery.of(context).size.width * 0.58,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: hasGroqKey ? const Color(0xFF10B981) : Colors.amber.withAlpha(180),
                      width: 2,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (hasGroqKey) ...[
                        // Scanner Aim Laser
                        Container(
                          height: 2,
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withAlpha(200),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0xFF10B981),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Align math equation within frame',
                          style: TextStyle(
                            color: Colors.white.withAlpha(180),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ] else ...[
                        // Locked State inside Viewfinder
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withAlpha(30),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.lock, color: Colors.amber, size: 24),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'AI Camera Snapping is Locked',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Connect your free Groq key to unlock',
                                style: TextStyle(
                                  color: Colors.white.withAlpha(180),
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 10),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const GroqSetupScreen()),
                                  );
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.bolt, color: Colors.black, size: 14),
                                      SizedBox(width: 4),
                                      Text(
                                        'Unlock with Groq AI',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
                          Text(
                            'Tap here to setup free Groq API key',
                            style: TextStyle(
                              color: Colors.amber,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  const Text(
                    '⚡ Powered by Groq Ultra-Fast AI (Llama 3.3 + Vision)',
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
                      'AI is analyzing equation with Groq Vision...',
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
                        color: hasGroqKey ? Colors.white : Colors.amber.withAlpha(200),
                        width: 4,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: hasGroqKey ? const Color(0xFF10B981) : Colors.amber,
                      ),
                      child: Icon(
                        hasGroqKey ? Icons.camera_alt : Icons.lock,
                        color: hasGroqKey ? Colors.white : Colors.black,
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
