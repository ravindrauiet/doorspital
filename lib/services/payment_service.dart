import 'package:door/services/api_client.dart';

class PaymentOrder {
  const PaymentOrder({
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.keyId,
  });

  final String orderId;
  final int amount;
  final String currency;
  final String keyId;
}

class RazorpayVerificationPayload {
  const RazorpayVerificationPayload({
    required this.orderId,
    required this.paymentId,
    required this.signature,
  });

  final String orderId;
  final String paymentId;
  final String signature;
}

class PaymentService {
  PaymentService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;
  // Set your live Razorpay public key here if the backend does not return it.
  static const String _frontendKeyId = 'rzp_live_T0itLEk3INlM77';

  Future<PaymentOrder> createOrder({
    required int amountPaise,
    String currency = 'INR',
    required String receipt,
  }) async {
    final response = await _client.post(
      '/create-order',
      includeAuth: false,
      body: {'amount': amountPaise, 'currency': currency, 'receipt': receipt},
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      _client.handleError(response);
    }

    final payload = _client.parseResponse(response);
    final data = (payload['data'] as Map?)?.cast<String, dynamic>() ?? payload;
    final keyId = (data['key_id'] as String?)?.trim();
    final effectiveKeyId = (keyId != null && keyId.isNotEmpty)
        ? keyId
        : _frontendKeyId.trim();

    if (effectiveKeyId.isEmpty ||
        effectiveKeyId == 'PASTE_RAZORPAY_LIVE_KEY_ID_HERE') {
      throw Exception(
        'Razorpay key id is missing. Set it in payment_service.dart or fix the production backend response.',
      );
    }

    return PaymentOrder(
      orderId: data['order_id'] as String,
      amount: (data['amount'] as num).toInt(),
      currency: data['currency'] as String,
      keyId: effectiveKeyId,
    );
  }

  Future<void> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    final response = await _client.post(
      '/verify-payment',
      includeAuth: false,
      body: {
        'razorpay_order_id': razorpayOrderId,
        'razorpay_payment_id': razorpayPaymentId,
        'razorpay_signature': razorpaySignature,
      },
    );

    if (response.statusCode != 200) {
      _client.handleError(response);
    }
  }
}
