import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

import 'razorpay_checkout_models.dart';

@JS('doorspitalRazorpay')
external _DoorspitalRazorpayBridge? get _bridge;

@JS()
@staticInterop
class _DoorspitalRazorpayBridge {}

extension _DoorspitalRazorpayBridgeExtension on _DoorspitalRazorpayBridge {
  external void open(
    JSString optionsJson,
    JSFunction onSuccess,
    JSFunction onError,
  );
}

Future<RazorpayCheckoutSuccess> openRazorpayCheckout(
  RazorpayCheckoutRequest request,
) {
  final completer = Completer<RazorpayCheckoutSuccess>();
  final bridge = _bridge;

  if (bridge == null) {
    throw const RazorpayCheckoutException(
      'Razorpay checkout bridge is not loaded. Confirm the web script is present.',
    );
  }

  bridge.open(
    jsonEncode(request.toJson()).toJS,
    ((JSString payload) {
      if (completer.isCompleted) {
        return;
      }

      final data = jsonDecode(payload.toDart) as Map<String, dynamic>;
      completer.complete(
        RazorpayCheckoutSuccess(
          paymentId: data['razorpay_payment_id'] as String,
          orderId: data['razorpay_order_id'] as String,
          signature: data['razorpay_signature'] as String,
        ),
      );
    }).toJS,
    ((JSString payload) {
      if (completer.isCompleted) {
        return;
      }

      final payloadText = payload.toDart;
      final data = payloadText.isEmpty
          ? const <String, dynamic>{}
          : jsonDecode(payloadText) as Map<String, dynamic>;
      final error = data['error'];
      final message = error is Map && error['description'] is String
          ? error['description'] as String
          : data['message'] as String? ??
                data['type'] as String? ??
                'Payment failed';

      completer.completeError(RazorpayCheckoutException(message));
    }).toJS,
  );

  return completer.future;
}
