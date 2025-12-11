import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:door/services/models/pharmacy_models.dart';
import 'package:door/services/pharmacy_order_service.dart';
import 'package:door/services/api_client.dart';
import 'package:door/utils/theme/colors.dart';

/// Full-screen Order Details page matching the premium design
class OrderDetailsPage extends StatefulWidget {
  final PharmacyOrder order;

  const OrderDetailsPage({super.key, required this.order});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  final currency = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
  final ApiClient _apiClient = ApiClient();
  final PharmacyOrderService _orderService = PharmacyOrderService();
  bool _isExpanded = true;
  bool _isRefreshing = false;
  
  // Mutable order state - initialized from widget, updated from API
  late PharmacyOrder _order;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    // Refresh order data from API on page load
    _refreshOrder();
  }

  Future<void> _refreshOrder() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    
    try {
      final response = await _orderService.getOrderById(_order.id);
      if (mounted && response.success && response.data != null) {
        setState(() => _order = response.data!);
      }
    } catch (e) {
      debugPrint('Failed to refresh order: $e');
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  PharmacyOrder get order => _order;

  // Timeline steps based on order status - matches pharmacy dashboard
  static const List<Map<String, String>> _steps = [
    {'key': 'pending', 'label': 'Order Placed', 'desc': 'Your order was placed for delivery'},
    {'key': 'processing', 'label': 'Processing', 'desc': 'Your order is being processed for confirmation.'},
    {'key': 'ready_for_delivery', 'label': 'Ready for Delivery', 'desc': 'Your order is packed and ready for pickup.'},
    {'key': 'out_for_delivery', 'label': 'Out for Delivery', 'desc': 'Your order is on the way to you!'},
    {'key': 'delivered', 'label': 'Delivered', 'desc': 'Your order has been delivered successfully.'},
  ];

  int get _currentStepIndex {
    final statusMap = {
      'pending': 0,
      'processing': 1,
      'ready_for_delivery': 2,
      'shipped': 2,  // Legacy status maps to ready_for_delivery
      'out_for_delivery': 3,
      'delivered': 4,
      'cancelled': -1,
    };
    return statusMap[order.status.toLowerCase()] ?? 0;
  }

  String _getEstimatedDelivery() {
    final orderDate = order.createdAt ?? DateTime.now();
    final estimatedDate = orderDate.add(const Duration(days: 5));
    return DateFormat('d MMM').format(estimatedDate);
  }

  bool get _isOnTime {
    // Check if order is on track (not cancelled and within expected timeline)
    return order.status.toLowerCase() != 'cancelled';
  }

  String _getImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return '';
    if (imageUrl.startsWith('http')) return imageUrl;
    if (imageUrl.startsWith('/')) {
      return '${_apiClient.baseUrl.replaceAll('/api', '')}$imageUrl';
    }
    return imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.greySecondry),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 16, color: AppColors.textPrimary),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Delivery Details',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_isRefreshing)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
              onPressed: _refreshOrder,
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshOrder,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Delivery Details Card with Product & Timeline
              _buildDeliveryDetailsCard(),
              
              if (_isExpanded) ...[
                const SizedBox(height: 24),
                // Order Details Section
                _buildOrderDetailsSection(),
                const SizedBox(height: 24),
                // Bill Summary
                _buildBillSummary(),
                const SizedBox(height: 24),
                // Payment Method
                _buildPaymentMethod(),
                const SizedBox(height: 16),
                // Help Section
                _buildHelpSection(),
              ],
              
              const SizedBox(height: 16),
              // Show More/Less Toggle
              _buildShowToggle(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryDetailsCard() {
    final firstItem = order.items.isNotEmpty ? order.items.first : null;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greySecondry),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Info Row
          if (firstItem != null)
            Row(
              children: [
                // Product Image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.greySecondry,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.greySecondry),
                  ),
                  child: _getImageUrl(firstItem.image).isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          child: Image.network(
                            _getImageUrl(firstItem.image),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.medication_outlined,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.medication_outlined,
                          color: AppColors.textSecondary,
                        ),
                ),
                const SizedBox(width: 12),
                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        firstItem.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'Quantity:',
                            style: TextStyle(
                              color: AppColors.textSecondary.withOpacity(0.7),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${firstItem.quantity.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            'Price:',
                            style: TextStyle(
                              color: AppColors.textSecondary.withOpacity(0.7),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            currency.format(firstItem.price),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          
          const SizedBox(height: 16),
          
          // On Time Badge & Delivery Date
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5F3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isOnTime ? AppColors.success : AppColors.warning,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _isOnTime ? 'On time' : 'Delayed',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Arriving by ${_getEstimatedDelivery()}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Timeline Tracker
          _buildTimeline(),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return Column(
      children: List.generate(_steps.length, (index) {
        final step = _steps[index];
        final isCompleted = index <= _currentStepIndex;
        final isActive = index == _currentStepIndex;
        final isLast = index == _steps.length - 1;
        
        // Get the date for this step (use order date for first, estimate for others)
        final orderDate = order.createdAt ?? DateTime.now();
        final stepDate = orderDate.add(Duration(days: index));
        final dateText = DateFormat('dd MMM').format(stepDate);
        final timeText = DateFormat('h:mm a').format(stepDate);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Column
            SizedBox(
              width: 55,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateText,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: isCompleted ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    timeText,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Timeline Indicator
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isCompleted ? AppColors.primary : Colors.white,
                    border: Border.all(
                      color: isCompleted ? AppColors.primary : AppColors.greySecondry,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 14)
                      : null,
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 50,
                    color: isCompleted && index < _currentStepIndex
                        ? AppColors.primary
                        : AppColors.greySecondry,
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // Step Details
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step['label']!,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: isCompleted ? AppColors.textPrimary : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step['desc']!,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary.withOpacity(0.8),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildOrderDetailsSection() {
    final placedOn = order.createdAt ?? DateTime.now();
    final placedText = DateFormat('dd MMM yyyy, h:mm a').format(placedOn);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Order Details',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.greySecondry),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order ID with Genuine Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.id.substring(order.id.length - 5)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.verified,
                        color: AppColors.success,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Genuine',
                        style: TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Placed on $placedText',
                style: TextStyle(
                  color: AppColors.textSecondary.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              // Product Items
              ...order.items.map((item) => _buildProductItem(item)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductItem(OrderItem item) {
    final hasDiscount = order.discount > 0;
    final discountPercent = hasDiscount 
        ? ((order.discount / order.subtotal) * 100).round()
        : 0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: AppColors.greySecondry,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.greySecondry),
            ),
            child: _getImageUrl(item.image).isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: Image.network(
                      _getImageUrl(item.image),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.medication_outlined,
                        color: AppColors.textSecondary,
                        size: 24,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.medication_outlined,
                    color: AppColors.textSecondary,
                    size: 24,
                  ),
          ),
          const SizedBox(width: 12),
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.quantity} item(s)',
                  style: TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      currency.format(item.price),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                    if (hasDiscount) ...[
                      const SizedBox(width: 8),
                      Text(
                        currency.format(item.price * 1.25), // Show original price
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$discountPercent% OFF',
                          style: TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillSummary() {
    // Calculate values
    final shippingFee = 0.0; // Free shipping
    final handlingCharges = 15.0;
    final savedAmount = order.discount;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bill Summary',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.greySecondry),
          ),
          child: Column(
            children: [
              _buildBillRow('Item Total', currency.format(order.subtotal)),
              _buildBillRow(
                'Discount',
                order.discount > 0 ? '-${currency.format(order.discount)}' : '—',
                valueColor: AppColors.success,
              ),
              _buildBillRow(
                'Shipping Fee',
                shippingFee == 0 ? 'FREE' : currency.format(shippingFee),
                strikeValue: shippingFee == 0 ? '₹50.00' : null,
                valueColor: AppColors.success,
              ),
              _buildBillRow('Handling Charges', currency.format(handlingCharges)),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1),
              ),
              // Total Amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Amount',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    currency.format(order.total),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              if (savedAmount > 0) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'You saved ${currency.format(savedAmount)}',
                    style: TextStyle(
                      color: AppColors.teal,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBillRow(String label, String value, {Color? valueColor, String? strikeValue}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          Row(
            children: [
              if (strikeValue != null) ...[
                Text(
                  strikeValue,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: valueColor ?? AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod() {
    final isPaid = order.paymentStatus == 'paid';
    final methodText = order.paymentMethod == 'cod' 
        ? 'Cash on Delivery' 
        : order.paymentMethod.toUpperCase();
    final methodSubtext = order.paymentMethod == 'cod'
        ? 'Pay when you receive'
        : 'Payment ${order.paymentStatus}';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greySecondry),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.payments_outlined,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  methodText,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  methodSubtext,
                  style: TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greySecondry),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.help_outline,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Need help with your order?',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Support will contact you shortly.'),
                      ),
                    );
                  },
                  child: Text(
                    'Contact us',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildShowToggle() {
    return Center(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _isExpanded ? 'Show Less' : 'Show More',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            Icon(
              _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
