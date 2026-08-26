import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class MathOcrService {
  static const String _groqChatUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _groqModelsUrl = 'https://api.groq.com/openai/v1/models';
  static const String _ocrSpaceUrl = 'https://api.ocr.space/parse/image';

  /// Primary multi-stage math recognizer from image
  static Future<String> recognizeMath({
    required String imagePath,
    String? groqApiKey,
    String? geminiApiKey,
  }) async {
    final file = File(imagePath);
    if (!await file.exists()) {
      throw Exception('Image file not found at $imagePath');
    }

    final bytes = await file.readAsBytes();
    final base64Image = base64Encode(bytes);
    final isPng = imagePath.toLowerCase().endsWith('.png');
    final mimeType = isPng ? 'image/png' : 'image/jpeg';

    // 1. Try Groq Vision if key is available
    if (groqApiKey != null && groqApiKey.trim().isNotEmpty) {
      final text = await _tryGroqVision(groqApiKey.trim(), mimeType, base64Image);
      if (text != null && text.trim().isNotEmpty) {
        return _cleanMathText(text);
      }
    }

    // 2. Try Gemini Vision if key is available
    if (geminiApiKey != null && geminiApiKey.trim().isNotEmpty) {
      final text = await _tryGeminiVision(geminiApiKey.trim(), mimeType, base64Image);
      if (text != null && text.trim().isNotEmpty) {
        return _cleanMathText(text);
      }
    }

    // 3. Try OCR.space Math Engine (Engine 2 handles numbers & math symbols)
    final ocrText = await _tryOcrSpace(imagePath);
    if (ocrText != null && ocrText.trim().isNotEmpty) {
      return _cleanMathText(ocrText);
    }

    // If nothing detected, return empty string (NEVER return a fake preset equation)
    return '';
  }

  static Future<String?> _tryGroqVision(String apiKey, String mimeType, String base64Image) async {
    // Determine candidate models
    final candidateModels = <String>[
      'qwen/qwen3.6-27b',
      'qwen/qwen3.8-27b',
      'meta-llama/llama-4-scout-vision',
      'llama-3.2-11b-vision-preview',
      'llama-3.2-90b-vision-preview',
      'openai/gpt-oss-120b',
    ];

    // Attempt to discover dynamic vision models from Groq
    try {
      final modelsRes = await http.get(
        Uri.parse(_groqModelsUrl),
        headers: {'Authorization': 'Bearer $apiKey'},
      ).timeout(const Duration(seconds: 4));

      if (modelsRes.statusCode == 200) {
        final modelsData = jsonDecode(modelsRes.body);
        final list = modelsData['data'] as List<dynamic>? ?? [];
        for (final m in list) {
          final id = (m['id'] as String? ?? '').toLowerCase();
          if (id.contains('vision') || id.contains('vl') || id.contains('qwen3')) {
            if (!candidateModels.contains(m['id'])) {
              candidateModels.insert(0, m['id'] as String);
            }
          }
        }
      }
    } catch (_) {}

    const prompt = 'Extract ONLY the raw mathematical question or equation from this image. '
        'Do NOT include explanations, greetings, or backticks. '
        'Output only the clean math equation (e.g. 2x + 5 = 15 or x^2 - 4 = 0 or sin(30) + cos(60)).';

    for (final model in candidateModels) {
      try {
        final response = await http.post(
          Uri.parse(_groqChatUrl),
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': model,
            'messages': [
              {
                'role': 'user',
                'content': [
                  {'type': 'text', 'text': prompt},
                  {
                    'type': 'image_url',
                    'image_url': {'url': 'data:$mimeType;base64,$base64Image'}
                  }
                ]
              }
            ],
            'temperature': 0.1,
            'max_tokens': 200,
          }),
        ).timeout(const Duration(seconds: 12));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final choices = data['choices'] as List<dynamic>?;
          if (choices != null && choices.isNotEmpty) {
            final content = choices[0]['message']?['content'] as String? ?? '';
            final trimmed = content.trim();
            if (trimmed.isNotEmpty) {
              debugPrint('✓ Groq Vision model "$model" recognized: $trimmed');
              return trimmed;
            }
          }
        } else {
          debugPrint('Groq model "$model" returned status ${response.statusCode}');
        }
      } catch (e) {
        debugPrint('Groq model "$model" error: $e');
      }
    }
    return null;
  }

  static Future<String?> _tryGeminiVision(String apiKey, String mimeType, String base64Image) async {
    final geminiModels = ['gemini-1.5-flash', 'gemini-2.0-flash', 'gemini-1.5-pro'];

    for (final model in geminiModels) {
      try {
        final url = 'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey';
        final response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {
                    'text': 'Extract ONLY the raw mathematical question or equation from this image. Do not include markdown or explanations.'
                  },
                  {
                    'inlineData': {
                      'mimeType': mimeType,
                      'data': base64Image,
                    }
                  }
                ]
              }
            ],
            'generationConfig': {
              'temperature': 0.1,
              'maxOutputTokens': 200,
            }
          }),
        ).timeout(const Duration(seconds: 12));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final candidates = data['candidates'] as List<dynamic>?;
          if (candidates != null && candidates.isNotEmpty) {
            final parts = candidates[0]['content']?['parts'] as List<dynamic>?;
            if (parts != null && parts.isNotEmpty) {
              final text = parts[0]['text'] as String? ?? '';
              if (text.trim().isNotEmpty) return text.trim();
            }
          }
        }
      } catch (_) {}
    }
    return null;
  }

  static Future<String?> _tryOcrSpace(String imagePath) async {
    try {
      final uri = Uri.parse(_ocrSpaceUrl);
      final request = http.MultipartRequest('POST', uri)
        ..fields['apikey'] = 'K87899142388957' // Free public OCR.space engine key
        ..fields['language'] = 'eng'
        ..fields['isOverlayRequired'] = 'false'
        ..fields['detectOrientation'] = 'true'
        ..fields['scale'] = 'true'
        ..fields['isTable'] = 'false'
        ..fields['OCREngine'] = '2' // Engine 2 is optimized for numbers, handwriting & equations
        ..files.add(await http.MultipartFile.fromPath('file', imagePath));

      final streamedRes = await request.send().timeout(const Duration(seconds: 15));
      final response = await http.Response.fromStream(streamedRes);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final parsedResults = data['ParsedResults'] as List<dynamic>?;
        if (parsedResults != null && parsedResults.isNotEmpty) {
          final parsedText = parsedResults[0]['ParsedText'] as String? ?? '';
          final trimmed = parsedText.trim();
          if (trimmed.isNotEmpty) {
            debugPrint('✓ OCR.space recognized: $trimmed');
            return trimmed;
          }
        }
      }
    } catch (e) {
      debugPrint('OCR.space error: $e');
    }
    return null;
  }

  static String _cleanMathText(String text) {
    return text
        .replaceAll('```latex', '')
        .replaceAll('```json', '')
        .replaceAll('```math', '')
        .replaceAll('```', '')
        .replaceAll(r'\[', '')
        .replaceAll(r'\]', '')
        .replaceAll(r'\(', '')
        .replaceAll(r'\)', '')
        .replaceAll(r'$', '')
        .replaceAll('\r\n', '\n')
        .trim();
  }
}
