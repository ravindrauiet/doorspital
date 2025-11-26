// lib/payment_page.dart
import 'package:flutter/material.dart';
// FontFeature

enum PaymentMethod { card, paypal, axisBank }

class PaymentPage extends StatefulWidget {
  const PaymentPage({
    super.key,
    this.amount, // secondary (only if fee isn't provided)
    this.currency = '₹', // default currency
    this.patientName,
    this.doctorName,
    this.dateLabel,
    this.timeLabel,
    this.doctorFeePerHour, // ✅ PRIMARY source for price
  });

  final num? amount;
  final String currency;
  final String? patientName;
  final String? doctorName;
  final String? dateLabel;
  final String? timeLabel;
  final num? doctorFeePerHour;

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final PageController _cardController = PageController(viewportFraction: .82);
  PaymentMethod _method = PaymentMethod.card;

  Map<String, dynamic> _readRouteArgs() {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args == null) return const {};
    if (args is num) return {'amount': args};
    if (args is Map) return args.map((k, v) => MapEntry(k.toString(), v));
    return const {};
  }

  /// Prefer fee keys over generic amount keys
  num? _pickAmountFromArgs(Map<String, dynamic> m) {
    const keysInPriorityOrder = [
      'feePerHour',
      'doctorFeePerHour',
      'amount',
      'payAmount',
      'total',
      'price',
    ];
    for (final k in keysInPriorityOrder) {
      final v = m[k];
      if (v is num) return v;
      if (v is String) {
        final p = num.tryParse(v);
        if (p != null) return p;
      }
    }
    return null;
  }

  String? _pickCurrencyFromArgs(Map<String, dynamic> m) {
    const keys = ['currency', 'currencySymbol'];
    for (final k in keys) {
      final v = m[k];
      if (v is String && v.trim().isNotEmpty) return v.trim();
    }
    return null;
  }

  String _formatCurrency(num value, String currency) {
    final isInt = value == value.roundToDouble();
    final formatted = isInt
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);
    return '$currency$formatted';
  }

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Resolve everything safely each build (no late fields).
    final args = _readRouteArgs();
    final argAmount = _pickAmountFromArgs(args);
    final argCurrency = _pickCurrencyFromArgs(args);

    // ✅ Prefer the fee coming from PlaceAppointmentPage
    final effectiveAmount =
        widget.doctorFeePerHour ?? argAmount ?? widget.amount ?? 0;

    final effectiveCurrency =
        (widget.currency == '\$' || widget.currency.isEmpty)
        ? '₹'
        : widget.currency;

    final doctorName =
        widget.doctorName ?? (args['doctorName'] as String?) ?? '—';
    final patientName =
        widget.patientName ?? (args['patientName'] as String?) ?? '—';
    final dateLabel = widget.dateLabel ?? (args['dateLabel'] as String?) ?? '—';
    final timeLabel = widget.timeLabel ?? (args['timeLabel'] as String?) ?? '—';

    final formattedAmount = _formatCurrency(effectiveAmount, effectiveCurrency);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Patient Payment'),
        centerTitle: false,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: [
            _BookingSummary(
              doctorName: doctorName,
              patientName: patientName,
              dateLabel: dateLabel,
              timeLabel: timeLabel,
              amount: effectiveAmount,
              currency: effectiveCurrency,
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                _networkBadge(),
                const SizedBox(width: 8),
                const Text(
                  'Credit/Debit Card',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Radio<PaymentMethod>(
                  value: PaymentMethod.card,
                  groupValue: _method,
                  onChanged: (v) => setState(() => _method = v!),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 10),

            SizedBox(
              height: 180,
              child: PageView(
                controller: _cardController,
                children: const [
                  _VisaCard(
                    label: 'VISA',
                    number: '6277 7654 2527 4778',
                    holder: 'JAMOLE B.',
                    expiry: '02/30',
                    gradient: [Color(0xFF7B42F6), Color(0xFFB01EFF)],
                  ),
                  _VisaCard(
                    label: 'VISA',
                    number: '6277 7654 2527 4778',
                    holder: 'JAMOLE B.',
                    expiry: '02/30',
                    gradient: [Color(0xFFE8EDF7), Color(0xFFF7FAFF)],
                    light: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Add New Card tapped')),
                );
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add New Card'),
            ),
            const SizedBox(height: 12),

            _PaymentRadioTile(
              icon: Icons.account_balance_wallet_outlined,
              brandColor: Colors.blue.shade700,
              title: 'Paypal',
              value: PaymentMethod.paypal,
              groupValue: _method,
              onChanged: (v) => setState(() => _method = v!),
            ),
            const SizedBox(height: 8),

            _PaymentRadioTile(
              icon: Icons.account_balance_outlined,
              brandColor: const Color(0xFFD32F2F),
              title: 'Axis Bank',
              value: PaymentMethod.axisBank,
              groupValue: _method,
              onChanged: (v) => setState(() => _method = v!),
            ),
          ],
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: () {
              final methodName = {
                PaymentMethod.card: 'Card',
                PaymentMethod.paypal: 'PayPal',
                PaymentMethod.axisBank: 'Axis Bank',
              }[_method];
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Payment successful: $formattedAmount via $methodName',
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D4FE3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: Text(
              'Pay $formattedAmount',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _networkBadge() {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: const BoxDecoration(
            color: Color(0xFFFF5A5A),
            shape: BoxShape.circle,
          ),
        ),
        Transform.translate(
          offset: const Offset(-6, 0),
          child: Container(
            width: 16,
            height: 16,
            decoration: const BoxDecoration(
              color: Color(0xFFFFB84D),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}

/* ------------------------------- SUMMARY ------------------------------- */

class _BookingSummary extends StatelessWidget {
  const _BookingSummary({
    this.doctorName,
    this.patientName,
    this.dateLabel,
    this.timeLabel,
    required this.amount,
    this.currency = '₹',
  });

  final String? doctorName;
  final String? patientName;
  final String? dateLabel;
  final String? timeLabel;
  final num amount;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final entries = <_SummaryEntry>[
      if (_has(doctorName)) _SummaryEntry('Doctor', doctorName!.trim()),
      if (_has(patientName)) _SummaryEntry('Patient', patientName!.trim()),
      if (_has(dateLabel)) _SummaryEntry('Date', dateLabel!.trim()),
      if (_has(timeLabel)) _SummaryEntry('Time', timeLabel!.trim()),
      _SummaryEntry('Amount', _formatAmount()),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE1E7EF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Booking Summary',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          for (final e in entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(
                    e.label,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    e.value,
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  bool _has(String? v) => (v ?? '').trim().isNotEmpty;

  String _formatAmount() {
    final isInt = amount == amount.roundToDouble();
    final value = isInt ? amount.toStringAsFixed(0) : amount.toStringAsFixed(2);
    return '$currency$value';
  }
}

class _SummaryEntry {
  const _SummaryEntry(this.label, this.value);
  final String label;
  final String value;
}

/* --------------------------- METHOD TILE + CARD -------------------------- */

class _PaymentRadioTile extends StatelessWidget {
  const _PaymentRadioTile({
    required this.icon,
    required this.brandColor,
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  final IconData icon;
  final Color brandColor;
  final String title;
  final PaymentMethod value;
  final PaymentMethod groupValue;
  final ValueChanged<PaymentMethod?> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: brandColor),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            Radio<PaymentMethod>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}

/* --------------------------------- CARD --------------------------------- */

class _VisaCard extends StatelessWidget {
  const _VisaCard({
    required this.label,
    required this.number,
    required this.holder,
    required this.expiry,
    required this.gradient,
    this.light = false,
  });

  final String label;
  final String number;
  final String holder;
  final String expiry;
  final List<Color> gradient;
  final bool light;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  color: light ? Colors.black87 : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.credit_card,
                color: light ? Colors.black45 : Colors.white70,
              ),
            ],
          ),
          const Spacer(),
          Text(
            number,
            style: TextStyle(
              color: light ? Colors.black87 : Colors.white,
              fontSize: 18,
              letterSpacing: 2,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _kv('Cardholder name', holder, light),
              const Spacer(),
              _kv('Expiry date', expiry, light),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v, bool light) {
    final base = light ? Colors.black87 : Colors.white;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(k, style: TextStyle(color: base.withOpacity(.75), fontSize: 11)),
        const SizedBox(height: 2),
        Text(
          v,
          style: TextStyle(
            color: base,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
