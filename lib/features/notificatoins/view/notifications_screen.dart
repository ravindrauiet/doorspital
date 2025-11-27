import 'package:door/features/components/custom_appbar.dart';
import 'package:door/services/models/notification_models.dart';
import 'package:door/services/notification_service.dart';
import 'package:door/utils/images/images.dart';
import 'package:door/utils/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  final List<NotificationItem> _notifications = [];
  final ScrollController _scrollController = ScrollController();

  static const int _pageSize = 20;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _page = 1;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchNotifications(refresh: true);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchNotifications({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _isLoading = true;
        _error = null;
        _page = 1;
        _hasMore = true;
      });
    } else if (!_hasMore || _isLoadingMore) {
      return;
    }

    final pageToLoad = refresh ? 1 : _page;

    try {
      final response = await _notificationService.getNotifications(
        page: pageToLoad,
        limit: _pageSize,
      );

      if (!mounted) return;

      if (response.success && response.data != null) {
        setState(() {
          if (refresh) {
            _notifications
              ..clear()
              ..addAll(response.data!.notifications);
          } else {
            _notifications.addAll(response.data!.notifications);
          }

          final pagination = response.data!.pagination;
          if (pagination != null) {
            _hasMore = pagination.page < pagination.totalPages;
            _page = pagination.page + 1;
          } else {
            _hasMore = response.data!.notifications.length >= _pageSize;
            _page = pageToLoad + 1;
          }
        });
      } else {
        setState(() {
          _error = response.message ?? 'Unable to load notifications.';
          if (refresh) {
            _notifications.clear();
          }
          _hasMore = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Error loading notifications: $e';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        if (refresh) {
          _isLoading = false;
        } else {
          _isLoadingMore = false;
        }
      });
    }
  }

  Future<void> _handleRefresh() => _fetchNotifications(refresh: true);

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 120 &&
        !_isLoading &&
        !_isLoadingMore &&
        _hasMore) {
      setState(() => _isLoadingMore = true);
      _fetchNotifications();
    }
  }

  Future<void> _markAsRead(NotificationItem item) async {
    if (item.isRead) return;

    final response = await _notificationService.markAsRead(item.id);
    if (!mounted) return;

    if (response.success) {
      setState(() {
        final index = _notifications.indexWhere((n) => n.id == item.id);
        if (index != -1) {
          _notifications[index] = _notifications[index].copyWith(
            isRead: true,
            readAt: DateTime.now(),
          );
        }
      });
    } else {
      _showSnack(response.message ?? 'Failed to update notification.');
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Notifications'),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _notifications.isEmpty) {
      return RefreshIndicator(
        onRefresh: _handleRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          children: [
            Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _fetchNotifications(refresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_notifications.isEmpty) {
      return RefreshIndicator(
        onRefresh: _handleRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          children: [
            Image.asset(
              Images.noData,
              height: MediaQuery.of(context).size.height * 0.3,
            ),
            const SizedBox(height: 16),
            const Text(
              'No notifications yet',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'You will see updates from appointments, orders, and support here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _notifications.length + (_isLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index >= _notifications.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final notification = _notifications[index];
          return _NotificationTile(
            notification: notification,
            onMarkRead: () => _markAsRead(notification),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.onMarkRead,
  });

  final NotificationItem notification;
  final VoidCallback onMarkRead;

  IconData _iconForType(String? type) {
    switch (type) {
      case 'appointment':
        return Icons.schedule_outlined;
      case 'pharmacy':
        return Icons.local_pharmacy_outlined;
      case 'order':
        return Icons.receipt_long_outlined;
      case 'support':
        return Icons.support_agent_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _colorForType(String? type) {
    switch (type) {
      case 'appointment':
        return AppColors.primary;
      case 'pharmacy':
        return AppColors.teal;
      case 'order':
        return Colors.deepPurple;
      case 'support':
        return Colors.orange;
      default:
        return AppColors.grey;
    }
  }

  String _formatTimestamp(DateTime? date) {
    if (date == null) return '';
    return DateFormat('MMM d, yyyy • hh:mm a').format(date.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final accent = _colorForType(notification.type);
    final isUnread = !notification.isRead;

    return Card(
      elevation: isUnread ? 2 : 0,
      color: isUnread
          ? AppColors.white
          : AppColors.greySecondry.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Icon(_iconForType(notification.type), color: accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontWeight: isUnread
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          if (notification.type != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: accent.withOpacity(0.16),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                notification.type!.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: accent,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification.body,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (notification.data.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: notification.data.entries
                              .take(3)
                              .map(
                                (entry) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.greySecondry.withOpacity(
                                      0.4,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${entry.key}: ${entry.value}',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatTimestamp(notification.createdAt),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const Spacer(),
                          if (notification.isRead)
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.teal,
                              size: 18,
                            )
                          else
                            TextButton.icon(
                              onPressed: onMarkRead,
                              icon: const Icon(
                                Icons.mark_email_read_outlined,
                                size: 18,
                              ),
                              label: const Text('Mark as read'),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                padding: EdgeInsets.zero,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
