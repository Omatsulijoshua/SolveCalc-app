import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme_controller.dart';
import '../../core/theme/theme_presets.dart';
import '../../data/services/storage_service.dart';
import '../../domain/ai/groq_solver_service.dart';
import 'package:url_launcher/url_launcher.dart';

class GroqSetupScreen extends ConsumerStatefulWidget {
  const GroqSetupScreen({super.key});

  @override
  ConsumerState<GroqSetupScreen> createState() => _GroqSetupScreenState();
}

class _GroqSetupScreenState extends ConsumerState<GroqSetupScreen> {
  final TextEditingController _keyController = TextEditingController();
  bool _obscureText = true;
  bool _isTesting = false;
  bool _isTestedAndValid = false;
  String? _testErrorMessage;
  late StorageService _storage;

  @override
  void initState() {
    super.initState();
    _storage = ref.read(storageServiceProvider);
    final existingKey = _storage.getGroqApiKey() ?? '';
    _keyController.text = existingKey;
    if (existingKey.isNotEmpty) {
      _isTestedAndValid = true;
    }
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data?.text != null && data!.text!.trim().isNotEmpty) {
        setState(() {
          _keyController.text = data.text!.trim();
          _isTestedAndValid = false;
          _testErrorMessage = null;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Pasted API Key from clipboard!'),
              duration: Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
    } catch (_) {
      // Catch web clipboard restriction
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Click the box below and press Ctrl+V (or long-press) to paste.'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _testApiKey() async {
    final key = _keyController.text.trim();
    if (key.isEmpty) {
      setState(() {
        _testErrorMessage = 'Please paste or enter your Groq API key first.';
        _isTestedAndValid = false;
      });
      return;
    }

    setState(() {
      _isTesting = true;
      _testErrorMessage = null;
    });

    try {
      final isValid = await GroqAIService.testApiKey(key);
      if (isValid && mounted) {
        setState(() {
          _isTesting = false;
          _isTestedAndValid = true;
          _testErrorMessage = null;
        });

        // Show Green Floating Toast
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '✓ Groq API Key verified successfully!\nTap "Save & Activate" to finish setup.',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTesting = false;
          _isTestedAndValid = false;
          _testErrorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  Future<void> _saveApiKey() async {
    final key = _keyController.text.trim();
    if (key.isEmpty) {
      setState(() {
        _testErrorMessage = 'Please enter or paste an API key first.';
      });
      return;
    }

    await _storage.setGroqApiKey(key);
    await _storage.setAiProvider('groq');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✓ Groq AI configuration saved & active!'),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _removeApiKey() async {
    await _storage.setGroqApiKey(null);
    await _storage.setAiProvider('local');
    setState(() {
      _keyController.clear();
      _isTestedAndValid = false;
      _testErrorMessage = null;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Groq API Key removed. Using offline solver.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeControllerProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: theme.backgroundColor,
        appBar: AppBar(
          title: const Text('Setup Groq AI'),
          actions: [
            if (_keyController.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Remove Key',
                onPressed: _removeApiKey,
              ),
          ],
        ),
        // Persistent Sticky Bottom Action Bar ensuring Save button is ALWAYS reachable
        bottomNavigationBar: Container(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            12 + MediaQuery.of(context).padding.bottom,
          ),
          decoration: BoxDecoration(
            color: theme.surfaceColor,
            border: Border(top: BorderSide(color: theme.primaryColor.withAlpha(40))),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(40),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Test Button
              Expanded(
                flex: 2,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.primaryColor,
                    side: BorderSide(color: theme.primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isTesting ? null : _testApiKey,
                  icon: _isTesting
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.network_check, size: 18),
                  label: const Text(
                    'Test Key',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Save Button (Always visible and accessible)
              Expanded(
                flex: 3,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: _isTestedAndValid
                        ? const Color(0xFF10B981)
                        : theme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _saveApiKey,
                  icon: Icon(
                    _isTestedAndValid ? Icons.check_circle : Icons.save,
                    color: theme.equalsTextColor,
                    size: 18,
                  ),
                  label: Text(
                    _isTestedAndValid ? 'Save & Activate' : 'Save Key',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: theme.equalsTextColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: ListView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          children: [
            // Hero Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.primaryColor.withAlpha(220),
                    theme.primaryColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryColor.withAlpha(80),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.auto_awesome, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Unlock Camera Math AI',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Snap any textbook equation or handwritten math to solve in milliseconds with Groq.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withAlpha(230),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Instructions Card
            _sectionTitle('HOW TO GET YOUR FREE API KEY', theme),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.surfaceColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _instructionStep(
                    '1',
                    'Visit Groq Cloud Console',
                    'Open console.groq.com/keys in your browser.',
                    theme,
                  ),
                  const SizedBox(height: 10),
                  _instructionStep(
                    '2',
                    'Create Free Account',
                    'Sign in with Google, GitHub, or email.',
                    theme,
                  ),
                  const SizedBox(height: 10),
                  _instructionStep(
                    '3',
                    'Generate API Key',
                    'Click "Create API Key" and copy the key (starts with "gsk_").',
                    theme,
                  ),
                  const SizedBox(height: 10),
                  _instructionStep(
                    '4',
                    'Paste & Save Below',
                    'Paste the key and tap "Save & Activate".',
                    theme,
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.primaryColor,
                      side: BorderSide(color: theme.primaryColor.withAlpha(120)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('Configure AI', style: TextStyle(fontSize: 12)),
                    onPressed: () async {
                      final Uri url = Uri.parse('https://console.groq.com/keys');
                      try {
                        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                          throw 'Could not launch $url';
                        }
                      } catch (e) {
                        Clipboard.setData(const ClipboardData(text: 'https://console.groq.com/keys'));
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Could not open browser. Copied URL to clipboard!'),
                              duration: Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // API Key Input Section
            _sectionTitle('PASTE YOUR GROQ API KEY', theme),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isTestedAndValid
                      ? const Color(0xFF10B981)
                      : (_testErrorMessage != null
                          ? const Color(0xFFEF4444)
                          : theme.primaryColor.withAlpha(40)),
                  width: _isTestedAndValid ? 2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _keyController,
                    obscureText: _obscureText,
                    enableInteractiveSelection: true,
                    onChanged: (_) {
                      if (_isTestedAndValid || _testErrorMessage != null) {
                        setState(() {
                          _isTestedAndValid = false;
                          _testErrorMessage = null;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'gsk_...',
                      prefixIcon: Icon(Icons.key, color: theme.primaryColor),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              _obscureText ? Icons.visibility_off : Icons.visibility,
                              color: theme.textSecondaryColor,
                            ),
                            onPressed: () => setState(() => _obscureText = !_obscureText),
                          ),
                          IconButton(
                            icon: Icon(Icons.content_paste, color: theme.primaryColor),
                            tooltip: 'Paste from Clipboard',
                            onPressed: _pasteFromClipboard,
                          ),
                        ],
                      ),
                      filled: true,
                      fillColor: theme.backgroundColor.withAlpha(120),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  if (_testErrorMessage != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFEF4444).withAlpha(80)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _testErrorMessage!,
                              style: const TextStyle(
                                color: Color(0xFFEF4444),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  if (_isTestedAndValid) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF10B981).withAlpha(80)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle, color: Color(0xFF10B981), size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '✓ Key verified & working! Click Save & Activate below.',
                              style: TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
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
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, CalculatorThemeConfig theme) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: theme.primaryColor,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _instructionStep(
    String number,
    String title,
    String subtitle,
    CalculatorThemeConfig theme,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: theme.primaryColor.withAlpha(40),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: theme.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: theme.textSecondaryColor,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
