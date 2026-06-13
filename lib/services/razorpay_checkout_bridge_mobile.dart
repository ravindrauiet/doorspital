import 'dart:async';

import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'razorpay_checkout_models.dart';

Future<RazorpayCheckoutSuccess> openRazorpayCheckout(
  RazorpayCheckoutRequest request,
) {
  final completer = Completer<RazorpayCheckoutSuccess>();
  final razorpay = Razorpay();

  void completeSuccess(RazorpayCheckoutSuccess success) {
    if (completer.isCompleted) {
      return;
    }
    completer.complete(success);
  }

  void completeFailure(String message) {
    if (completer.isCompleted) {
      return;
    }
    completer.completeError(RazorpayCheckoutException(message));
  }

  void onPaymentSuccess(PaymentSuccessResponse response) {
    completeSuccess(
      RazorpayCheckoutSuccess(
        paymentId: response.paymentId ?? '',
        orderId: response.orderId ?? request.orderId,
        signature: response.signature ?? '',
      ),
    );
  }

  void onPaymentError(PaymentFailureResponse response) {
    final message = response.message?.toString().trim();
    completeFailure(message?.isNotEmpty == true ? message! : 'Payment failed');
  }

  void onExternalWallet(ExternalWalletResponse response) {
    final wallet = response.walletName?.trim();
    completeFailure(
      wallet == null || wallet.isEmpty
          ? 'External wallet selected'
          : 'External wallet selected: $wallet',
    );
  }

  razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onPaymentSuccess);
  razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onPaymentError);
  razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, onExternalWallet);

  try {
    razorpay.open(request.toNativeOptions());
  } catch (error) {
    completeFailure(error.toString());
  }

  return completer.future.whenComplete(razorpay.clear);
}
