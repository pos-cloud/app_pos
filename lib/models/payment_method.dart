import 'article.dart'; // Asegúrate de tener este modelo importado

class PaymentMethod {
  final String id;
  final int order;
  final int code;
  final String name;
  final double discount;
  final Article discountArticle;
  final double surcharge;
  final Article surchargeArticle;
  final double commission;
  final Article commissionArticle;
  final double administrativeExpense;
  final Article administrativeExpenseArticle;
  final double otherExpense;
  final Article otherExpenseArticle;
  final bool isCurrentAccount;
  final int expirationDays;
  final bool acceptReturned;
  final bool inputAndOutput;
  final bool checkDetail;
  final bool checkPerson;
  final bool cardDetail;
  final bool allowToFinance;
  final bool payFirstQuota;
  final bool cashBoxImpact;
  final bool bankReconciliation;

  PaymentMethod({
    required this.id,
    required this.order,
    required this.code,
    required this.name,
    required this.discount,
    required this.discountArticle,
    required this.surcharge,
    required this.surchargeArticle,
    required this.commission,
    required this.commissionArticle,
    required this.administrativeExpense,
    required this.administrativeExpenseArticle,
    required this.otherExpense,
    required this.otherExpenseArticle,
    required this.isCurrentAccount,
    required this.expirationDays,
    required this.acceptReturned,
    required this.inputAndOutput,
    required this.checkDetail,
    required this.checkPerson,
    required this.cardDetail,
    required this.allowToFinance,
    required this.payFirstQuota,
    required this.cashBoxImpact,
    required this.bankReconciliation,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['_id'] ?? '',
      order: json['order'] ?? 1,
      code: json['code'] ?? 1,
      name: json['name'] ?? '',
      discount: (json['discount'] ?? 0.0).toDouble(),
      discountArticle: Article.fromJson(json['discountArticle'] ?? {}),
      surcharge: (json['surcharge'] ?? 0.0).toDouble(),
      surchargeArticle: Article.fromJson(json['surchargeArticle'] ?? {}),
      commission: (json['commission'] ?? 0.0).toDouble(),
      commissionArticle: Article.fromJson(json['commissionArticle'] ?? {}),
      administrativeExpense: (json['administrativeExpense'] ?? 0.0).toDouble(),
      administrativeExpenseArticle:
          Article.fromJson(json['administrativeExpenseArticle'] ?? {}),
      otherExpense: (json['otherExpense'] ?? 0.0).toDouble(),
      otherExpenseArticle: Article.fromJson(json['otherExpenseArticle'] ?? {}),
      isCurrentAccount: json['isCurrentAccount'] ?? false,
      expirationDays: json['expirationDays'] ?? 30,
      acceptReturned: json['acceptReturned'] ?? false,
      inputAndOutput: json['inputAndOutput'] ?? false,
      checkDetail: json['checkDetail'] ?? false,
      checkPerson: json['checkPerson'] ?? false,
      cardDetail: json['cardDetail'] ?? false,
      allowToFinance: json['allowToFinance'] ?? false,
      payFirstQuota: json['payFirstQuota'] ?? false,
      cashBoxImpact: json['cashBoxImpact'] ?? false,
      bankReconciliation: json['bankReconciliation'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'order': order,
      'code': code,
      'name': name,
      'discount': discount,
      'discountArticle': discountArticle.toJson(),
      'surcharge': surcharge,
      'surchargeArticle': surchargeArticle.toJson(),
      'commission': commission,
      'commissionArticle': commissionArticle.toJson(),
      'administrativeExpense': administrativeExpense,
      'administrativeExpenseArticle': administrativeExpenseArticle.toJson(),
      'otherExpense': otherExpense,
      'otherExpenseArticle': otherExpenseArticle.toJson(),
      'isCurrentAccount': isCurrentAccount,
      'expirationDays': expirationDays,
      'acceptReturned': acceptReturned,
      'inputAndOutput': inputAndOutput,
      'checkDetail': checkDetail,
      'checkPerson': checkPerson,
      'cardDetail': cardDetail,
      'allowToFinance': allowToFinance,
      'payFirstQuota': payFirstQuota,
      'cashBoxImpact': cashBoxImpact,
      'bankReconciliation': bankReconciliation,
    };
  }
}
