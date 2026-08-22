enum EntitlementStatus {
  pending,
  active,
  revoked,
  refunded,
  expired,
}

class PremiumEntitlement {
  final String userId;
  final String platform; // 'android' | 'ios'
  final String productId; // 'solvecalc_premium_lifetime'
  final String purchaseId;
  final String transactionId;
  final DateTime purchaseDate;
  final EntitlementStatus status;
  final DateTime? verifiedAt;
  final String? originalTransactionId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PremiumEntitlement({
    required this.userId,
    required this.platform,
    required this.productId,
    required this.purchaseId,
    required this.transactionId,
    required this.purchaseDate,
    required this.status,
    this.verifiedAt,
    this.originalTransactionId,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isActive => status == EntitlementStatus.active;

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'platform': platform,
        'productId': productId,
        'purchaseId': purchaseId,
        'transactionId': transactionId,
        'purchaseDate': purchaseDate.toIso8601String(),
        'status': status.name,
        'verifiedAt': verifiedAt?.toIso8601String(),
        'originalTransactionId': originalTransactionId,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory PremiumEntitlement.fromJson(Map<String, dynamic> json) {
    return PremiumEntitlement(
      userId: json['userId'] as String? ?? 'anonymous',
      platform: json['platform'] as String? ?? 'android',
      productId: json['productId'] as String? ?? 'solvecalc_premium_lifetime',
      purchaseId: json['purchaseId'] as String? ?? '',
      transactionId: json['transactionId'] as String? ?? '',
      purchaseDate: json['purchaseDate'] != null
          ? DateTime.parse(json['purchaseDate'] as String)
          : DateTime.now(),
      status: EntitlementStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => EntitlementStatus.active,
      ),
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.parse(json['verifiedAt'] as String)
          : null,
      originalTransactionId: json['originalTransactionId'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }
}
