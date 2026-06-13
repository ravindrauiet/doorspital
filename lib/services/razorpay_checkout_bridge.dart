import 'razorpay_checkout_models.dart';
import 'razorpay_checkout_bridge_stub.dart'
    if (dart.library.io) 'razorpay_checkout_bridge_mobile.dart'
    if (dart.library.html) 'razorpay_checkout_bridge_web.dart'
    as bridge;

export 'razorpay_checkout_models.dart';

Future<RazorpayCheckoutSuccess> openRazorpayCheckout(
  RazorpayCheckoutRequest request,
) {
  return bridge.openRazorpayCheckout(request);
}
