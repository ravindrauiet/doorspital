class RazorpayCheckoutRequest {
  const RazorpayCheckoutRequest({
    required this.keyId,
    required this.amount,
    required this.currency,
    required this.orderId,
    required this.name,
    required this.description,
    this.prefillName,
    this.notes = const {},
  });

  final String keyId;
  final int amount;
  final String currency;
  final String orderId;
  final String name;
  final String description;
  final String? prefillName;
  final Map<String, String> notes;

  Map<String, dynamic> toJson() {
    return {
      'key': keyId,
      'amount': amount,
      'currency': currency,
      'name': name,
      'description': description,
      'order_id': orderId,
      'prefill': {
        if (prefillName != null && prefillName!.trim().isNotEmpty)
          'name': prefillName,
      },
      'notes': notes,
      'theme': {'color': '#2D4FE3'},
    };
  }

  Map<String, dynamic> toNativeOptions() {
    return {
      'key': keyId,
      'amount': amount,
      'currency': currency,
      'name': name,
      'description': description,
      'order_id': orderId,
      'prefill': {
        if (prefillName != null && prefillName!.trim().isNotEmpty)
          'name': prefillName,
      },
      'notes': notes,
      'theme': {'color': '#2D4FE3'},
    };
  }
}

class RazorpayCheckoutSuccess {
  const RazorpayCheckoutSuccess({
    required this.paymentId,
    required this.orderId,
    required this.signature,
  });

  final String paymentId;
  final String orderId;
  final String signature;
}

class RazorpayCheckoutException implements Exception {
  const RazorpayCheckoutException(this.message);

  final String message;

  @override
  String toString() => 'RazorpayCheckoutException: $message';
}
