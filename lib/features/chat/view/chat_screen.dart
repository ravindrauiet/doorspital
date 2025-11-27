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
      setState(() {
        _loadingRoom = false;
      });
      await _loadMessages();
      _markRoomRead();
      _startPolling();
    } else if (widget.args?.appointmentId != null) {
      await _createRoomFromAppointment(widget.args!.appointmentId!);
    } else {
      setState(() {
        _loadingRoom = false;
        _error = 'No conversation selected.';
      });
    }
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
      await _loadMessages();
      _markRoomRead();
      _startPolling();
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
    if (_room == null) return;

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
                    enabled: !_loadingMessages && _room != null,
                  ),
                ],
              ),
      ),
    );
  }
}
