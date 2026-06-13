import 'razorpay_checkout_models.dart';

Future<RazorpayCheckoutSuccess> openRazorpayCheckout(
  RazorpayCheckoutRequest request,
) async {
  throw const RazorpayCheckoutException(
    'Razorpay Standard Web Checkout is not available on this platform.',
  );
}
