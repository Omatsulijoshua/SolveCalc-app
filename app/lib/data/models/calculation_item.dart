import 'package:intl/intl.dart';

class CalculationItem {
  final String id;
  final String expression;
  final String result;
  final String angleMode;
  final DateTime timestamp;
  final bool isFavorite;

  const CalculationItem({
    required this.id,
    required this.expression,
    required this.result,
    required this.angleMode,
    required this.timestamp,
    this.isFavorite = false,
  });

  String get formattedTime => DateFormat('MMM d, h:mm a').format(timestamp);

  Map<String, dynamic> toJson() => {
        'id': id,
        'expression': expression,
        'result': result,
        'angleMode': angleMode,
        'timestamp': timestamp.toIso8601String(),
        'isFavorite': isFavorite,
      };

  factory CalculationItem.fromJson(Map<String, dynamic> json) => CalculationItem(
        id: json['id'] as String? ?? '',
        expression: json['expression'] as String? ?? '',
        result: json['result'] as String? ?? '',
        angleMode: json['angleMode'] as String? ?? 'DEG',
        timestamp: json['timestamp'] != null
            ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
            : DateTime.now(),
        isFavorite: json['isFavorite'] as bool? ?? false,
      );

  CalculationItem copyWith({
    String? id,
    String? expression,
    String? result,
    String? angleMode,
    DateTime? timestamp,
    bool? isFavorite,
  }) =>
      CalculationItem(
        id: id ?? this.id,
        expression: expression ?? this.expression,
        result: result ?? this.result,
        angleMode: angleMode ?? this.angleMode,
        timestamp: timestamp ?? this.timestamp,
        isFavorite: isFavorite ?? this.isFavorite,
      );
}
