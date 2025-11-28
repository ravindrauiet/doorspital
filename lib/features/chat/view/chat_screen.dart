import 'dart:async';

import 'package:door/features/chat/components/chat_body.dart';
import 'package:door/features/chat/components/chat_input_bar.dart';
import 'package:door/services/api_client.dart';
import 'package:door/services/chat_service.dart';
import 'package:door/services/models/chat_models.dart';
import 'package:door/utils/images/images.dart';
import 'package:door/utils/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ChatScreenArgs {
  final ChatRoom? room;
  final String? appointmentId;

  ChatScreenArgs({this.room, this.appointmentId});
}

class ChatScreen extends StatefulWidget {
  final ChatScreenArgs? args;

  const ChatScreen({super.key, this.args});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _chatService = ChatService();
  final _apiClient = ApiClient();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  ChatRoom? _room;
  List<ChatMessage> _messages = [];
  String? _nextCursor;
  bool _hasMore = false;

  bool _loadingRoom = true;
  bool _loadingMessages = false;
  bool _loadingMore = false;
  bool _sending = false;
  String? _error;
  Map<String, dynamic>? _currentUser;
  Timer? _pollingTimer;
  bool _isPolling = false;
  Timer? _timeMonitorTimer;
  bool _chatEnabled = true;
  bool _oneMinuteWarningShown = false;
  bool _isPreSession = false;
  String? _timeStatusMessage;
  Duration? _timeRemaining;

  @override
  void initState() {
    super.initState();
    _room = widget.args?.room;
    _initialize();
  }

  Future<void> _initialize() async {
    final user = await _apiClient.getUserData();
    if (!mounted) return;
    setState(() {
      _currentUser = user;
    });

    if (_room != null) {
      // Check if appointment has started
      if (!_checkAppointmentTime()) {
        return;
      }
      setState(() {
        _loadingRoom = false;
      });
      await _loadMessages();
      _markRoomRead();
      _startPolling();
      _startTimeMonitoring();
    } else if (widget.args?.appointmentId != null) {
      await _createRoomFromAppointment(widget.args!.appointmentId!);
    } else {
      setState(() {
        _loadingRoom = false;
        _error = 'No conversation selected.';
      });
    }
  }

  bool _checkAppointmentTime() {
    final appointment = _room?.appointment;
    if (appointment == null) return true; // No appointment, allow chat

    final now = DateTime.now();
    final startTime = appointment.startTime.toLocal();
    final endTime = appointment.endTime.toLocal();

    if (now.isBefore(startTime)) {
      final timeUntilStart = startTime.difference(now);
      final minutes = timeUntilStart.inMinutes;
      final hours = timeUntilStart.inHours;

      String message;
      if (hours > 0) {
        message =
            'Chat will open in $hours hour${hours > 1 ? 's' : ''} and $minutes minute${minutes != 1 ? 's' : ''}';
      } else {
        message = 'Chat will open in $minutes minute${minutes != 1 ? 's' : ''}';
      }

      setState(() {
        _loadingRoom = false;
        _error = message;
        _chatEnabled = false;
      });
      return false;
    }

    if (now.isAfter(endTime)) {
      setState(() {
        _loadingRoom = false;
        _error = 'Appointment time has ended. Chat is now closed.';
        _chatEnabled = false;
        _timeStatusMessage = 'Appointment ended';
      });
      return false;
    }

    return true;
  }

  Future<void> _createRoomFromAppointment(String appointmentId) async {
    setState(() {
      _loadingRoom = true;
      _error = null;
    });
    final response = await _chatService.createOrGetRoom(appointmentId);
    if (!mounted) return;

    if (response.success && response.data != null) {
      setState(() {
        _room = response.data!;
        _loadingRoom = false;
      });

      // Check if appointment has started
      if (!_checkAppointmentTime()) {
        return;
      }

      await _loadMessages();
      _markRoomRead();
      _startPolling();
      _startTimeMonitoring();
    } else {
      setState(() {
        _loadingRoom = false;
        _error = response.message ?? 'Unable to open chat';
      });
    }
  }

  Future<void> _loadMessages({bool loadMore = false}) async {
    if (_room == null) return;
    if (loadMore) {
      if (_loadingMore || _nextCursor == null) return;
      setState(() {
        _loadingMore = true;
      });
    } else {
      setState(() {
        _loadingMessages = true;
      });
    }

    final response = await _chatService.getMessages(
      _room!.id,
      cursor: loadMore ? _nextCursor : null,
    );

    if (!mounted) return;

    if (response.success && response.data != null) {
      final fetched = response.data!.messages.reversed.toList();
      setState(() {
        if (loadMore) {
          _messages = [...fetched, ..._messages];
        } else {
          _messages = fetched;
        }
        _nextCursor = response.data!.nextCursor;
        _hasMore = response.data!.nextCursor != null;
        _loadingMessages = false;
        _loadingMore = false;
      });
      if (!loadMore) {
        _scrollToBottom();
      }
      if (!loadMore) {
        _startPolling();
      }
    } else {
      setState(() {
        _error = response.message ?? 'Failed to load messages';
        _loadingMessages = false;
        _loadingMore = false;
      });
    }
  }

  Future<void> _handleSend(String text) async {
    if (_room == null || !_chatEnabled) return;

    setState(() {
      _sending = true;
    });

    final response = await _chatService.sendMessage(_room!.id, text);
    if (!mounted) return;

    setState(() {
      _sending = false;
    });

    if (response.success && response.data != null) {
      _messageController.clear();
      setState(() {
        _messages = [..._messages, response.data!];
        _hasMore = _nextCursor != null;
      });
      _scrollToBottom();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message ?? 'Failed to send message')),
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _markRoomRead() async {
    if (_room == null) return;
    await _chatService.markRoomRead(_room!.id);
  }

  String get _participantName {
    final isDoctor =
        (_currentUser?['role'] as String?)?.toLowerCase() == 'doctor';
    if (isDoctor) {
      return _room?.patient?.name ??
          _room?.patient?.email ??
          'Patient ${_room?.patient?.id.substring(0, 4) ?? ''}';
    }
    return _room?.doctorUser?.name ??
        _room?.doctorUser?.email ??
        _room?.doctor?.specialization ??
        'Doctor';
  }

  String get _subTitle {
    final appointment = _room?.appointment;
    if (appointment == null) return '';
    return DateFormat('MMM d, hh:mm a').format(appointment.startTime.toLocal());
  }

  void _startPolling() {
    if (_pollingTimer != null || _room == null) return;
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (_) async {
      await _refreshMessagesSilently();
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _isPolling = false;
  }

  void _startTimeMonitoring() {
    if (_timeMonitorTimer != null || _room == null) return;

    _timeMonitorTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _checkAppointmentEndTime();
    });

    // Check immediately
    _checkAppointmentEndTime();
  }

  void _stopTimeMonitoring() {
    _timeMonitorTimer?.cancel();
    _timeMonitorTimer = null;
  }

  void _checkAppointmentEndTime() {
    if (!mounted || _room == null) return;

    final appointment = _room!.appointment;
    if (appointment == null) return;

    final now = DateTime.now();
    final startTime = appointment.startTime.toLocal();
    final endTime = appointment.endTime.toLocal();

    // Chat isn't available before the appointment starts
    if (now.isBefore(startTime)) {
      final diff = startTime.difference(now);
      setState(() {
        _chatEnabled = false;
        _isPreSession = true;
        _timeRemaining = diff;
        _timeStatusMessage = 'Chat opens in';
      });
      return;
    }

    // Chat ends once the appointment window is over
    if (!now.isBefore(endTime)) {
      setState(() {
        _chatEnabled = false;
        _isPreSession = false;
        _timeRemaining = null;
        _timeStatusMessage = 'Appointment time has ended. Chat is now closed.';
      });
      _stopTimeMonitoring();
      _stopPolling();
      return;
    }

    final timeUntilEnd = endTime.difference(now);

    setState(() {
      _chatEnabled = true;
      _isPreSession = false;
      _timeRemaining = timeUntilEnd;
      _timeStatusMessage = 'Time left in this session';
    });

    if (timeUntilEnd.inSeconds <= 60 && !_oneMinuteWarningShown) {
      _showOneMinuteWarning();
      setState(() {
        _oneMinuteWarningShown = true;
      });
    } else if (timeUntilEnd.inSeconds > 60 && _oneMinuteWarningShown) {
      setState(() {
        _oneMinuteWarningShown = false;
      });
    }
  }

  void _showOneMinuteWarning() {
    if (!mounted) return;

    // Create a system message-like notification in the chat
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.access_time, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '⚠️ Only 1 minute left in your appointment',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _refreshMessagesSilently() async {
    if (!mounted || _room == null || _isPolling) return;
    _isPolling = true;
    final response = await _chatService.getMessages(_room!.id, limit: 30);
    if (!mounted) {
      _isPolling = false;
      return;
    }
    if (response.success && response.data != null) {
      final latest = response.data!.messages.reversed.toList();
      final newestId = latest.isNotEmpty ? latest.last.id : null;
      final currentNewestId = _messages.isNotEmpty ? _messages.last.id : null;
      setState(() {
        _messages = latest;
        _nextCursor = response.data!.nextCursor;
        _hasMore = response.data!.nextCursor != null;
      });
      if (newestId != null && newestId != currentNewestId) {
        _scrollToBottom();
      }
    }
    _isPolling = false;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _stopPolling();
    _stopTimeMonitoring();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        elevation: 0.5,
        iconTheme: const IconThemeData(color: AppColors.black),
        backgroundColor: AppColors.white,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage(Images.doctor),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _participantName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                  if (_subTitle.isNotEmpty)
                    Text(
                      _subTitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            splashRadius: 15,
            icon: const Icon(Icons.call_outlined, color: AppColors.primary),
            onPressed: () {},
          ),
          IconButton(
            splashRadius: 15,
            icon: const Icon(Icons.videocam_outlined, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: _loadingRoom
            ? const Center(child: CircularProgressIndicator())
            : _room == null
            ? Center(
                child: Text(
                  _error ?? 'No chat available',
                  style: const TextStyle(color: Colors.black54),
                ),
              )
            : Column(
                children: [
                  if (_timeStatusMessage != null)
                    _SessionStatusBanner(
                      message: _timeStatusMessage!,
                      isActive: _chatEnabled,
                      isFinalMinute:
                          _timeRemaining != null &&
                          _timeRemaining!.inSeconds <= 60,
                      isWaiting: _isPreSession,
                      countdownText: _timeRemaining != null
                          ? _countdownDigits(_timeRemaining!)
                          : null,
                    ),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(Images.chatBackground),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: ChatBody(
                        messages: _messages,
                        currentUserId: _currentUser?['id']?.toString(),
                        scrollController: _scrollController,
                        isLoading: _loadingMessages && _messages.isEmpty,
                        onLoadMore: _hasMore
                            ? () => _loadMessages(loadMore: true)
                            : null,
                      ),
                    ),
                  ),
                  ChatInputBar(
                    controller: _messageController,
                    onSend: _handleSend,
                    isSending: _sending,
                    enabled: _chatEnabled && !_loadingMessages && _room != null,
                  ),
                ],
              ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inSeconds <= 0) return '0s';

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return minutes == 0
          ? '${hours}h'
          : '${hours}h ${minutes.toString().padLeft(2, '0')}m';
    }

    if (duration.inMinutes >= 1) {
      return seconds == 0
          ? '${duration.inMinutes}m'
          : '${duration.inMinutes}m ${seconds.toString().padLeft(2, '0')}s';
    }

    return '${seconds.toString().padLeft(2, '0')}s';
  }

  String _countdownDigits(Duration duration) {
    final totalSeconds = duration.inSeconds;
    if (totalSeconds <= 0) return '00:00';

    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    }

    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class _SessionStatusBanner extends StatelessWidget {
  final String message;
  final bool isActive;
  final bool isFinalMinute;
  final bool isWaiting;
  final String? countdownText;

  const _SessionStatusBanner({
    required this.message,
    required this.isActive,
    required this.isFinalMinute,
    required this.isWaiting,
    this.countdownText,
  });

  @override
  Widget build(BuildContext context) {
    final Color accent;
    final IconData icon;

    if (!isActive) {
      accent = isWaiting ? Colors.orange : Colors.redAccent;
      icon = isWaiting ? Icons.access_time : Icons.lock_clock;
    } else {
      accent = isFinalMinute ? Colors.orange : AppColors.primary;
      icon = isFinalMinute ? Icons.timelapse : Icons.access_time;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: accent.withOpacity(0.12),
      child: Row(
        children: [
          Icon(icon, color: accent, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          if (countdownText != null)
            Text(
              countdownText!,
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
        ],
      ),
    );
  }
}
