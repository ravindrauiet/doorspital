import 'package:door/features/chat/view/chat_screen.dart';
import 'package:door/features/components/custom_appbar.dart';
import 'package:door/routes/route_constants.dart';
import 'package:door/services/api_client.dart';
import 'package:door/services/appointment_service.dart';
import 'package:door/services/chat_service.dart';
import 'package:door/services/models/appointment_models.dart';
import 'package:door/services/models/chat_models.dart';
import 'package:door/utils/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final _chatService = ChatService();
  final _appointmentService = AppointmentService();
  final _apiClient = ApiClient();

  List<ChatRoom> _rooms = [];
  bool _loading = true;
  bool _refreshing = false;
  String? _error;
  Map<String, dynamic>? _currentUser;
  bool _creatingRoom = false;

  bool get _isDoctor =>
      (_currentUser?['role'] as String?)?.toLowerCase() == 'doctor';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final userData = await _apiClient.getUserData();
    if (!mounted) return;
    setState(() {
      _currentUser = userData;
    });
    await _loadRooms();
  }

  Future<void> _loadRooms() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final response = await _chatService.getRooms();
    if (!mounted) return;

    if (response.success && response.data != null) {
      setState(() {
        _rooms = response.data!;
        _loading = false;
      });
    } else {
      setState(() {
        _error = response.message ?? 'Unable to load chats';
        _loading = false;
      });
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _refreshing = true;
    });
    await _loadRooms();
    if (!mounted) return;
    setState(() {
      _refreshing = false;
    });
  }

  void _openRoom(ChatRoom room) {
    context.pushNamed(
      RouteConstants.chatScreen,
      extra: ChatScreenArgs(room: room),
    );
  }

  Future<void> _startNewChat() async {
    if (_isDoctor) return; // Doctors currently cannot pick appointments

    final appointmentId = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) =>
          _AppointmentPickerSheet(appointmentService: _appointmentService),
    );

    if (appointmentId == null) return;

    setState(() {
      _creatingRoom = true;
    });

    final response = await _chatService.createOrGetRoom(appointmentId);
    if (!mounted) return;

    setState(() {
      _creatingRoom = false;
    });

    if (response.success && response.data != null) {
      _openRoom(response.data!);
      await _refresh();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message ?? 'Failed to start chat')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Chats',
        arrowBack: true,
        actions: [
          if (!_isDoctor)
            IconButton(
              icon: const Icon(Icons.add_comment_outlined),
              onPressed: _creatingRoom ? null : _startNewChat,
            ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: _buildBody(),
        ),
      ),
      floatingActionButton: !_isDoctor
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.chat),
              label: Text(_creatingRoom ? 'Starting...' : 'Start chat'),
              onPressed: _creatingRoom ? null : _startNewChat,
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _loadRooms, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (_rooms.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.chat_bubble_outline,
                  size: 56,
                  color: Colors.grey,
                ),
                const SizedBox(height: 12),
                Text(
                  _isDoctor
                      ? 'No patient conversations yet.'
                      : 'No chats yet. Book or select an appointment to start.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54),
                ),
                if (!_isDoctor) ...[
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _creatingRoom ? null : _startNewChat,
                    child: const Text('Start a chat'),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _rooms.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final room = _rooms[index];
        return _ChatRoomTile(
          room: room,
          isDoctor: _isDoctor,
          onTap: () => _openRoom(room),
        );
      },
    );
  }
}

class _ChatRoomTile extends StatelessWidget {
  final ChatRoom room;
  final bool isDoctor;
  final VoidCallback onTap;

  const _ChatRoomTile({
    required this.room,
    required this.isDoctor,
    required this.onTap,
  });

  String get _displayName {
    if (isDoctor) {
      return room.patient?.name ??
          room.patient?.email ??
          'Patient ${room.patient?.id.substring(0, 4) ?? ''}';
    }
    return room.doctorUser?.name ??
        room.doctorUser?.email ??
        room.doctor?.specialization ??
        'Doctor';
  }

  String get _specialLine {
    if (isDoctor) {
      return room.patient?.email ?? 'Tap to open conversation';
    }
    final doctorCity = room.doctor?.city;
    if (doctorCity != null && doctorCity.isNotEmpty) {
      return '${room.doctor?.specialization ?? 'Doctor'} • $doctorCity';
    }
    return room.doctor?.specialization ?? 'Tap to continue conversation';
  }

  int get _unreadCount =>
      isDoctor ? room.doctorUnreadCount : room.patientUnreadCount;

  String get _timeLabel {
    final date = room.lastMessage?.sentAt ?? room.updatedAt ?? room.createdAt;
    if (date == null) return '';
    final now = DateTime.now();
    if (DateUtils.isSameDay(now, date)) {
      return DateFormat('hh:mm a').format(date);
    }
    return DateFormat('MMM d').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.teal.withOpacity(0.12),
                child: Text(
                  _displayName.isNotEmpty ? _displayName[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.teal,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      room.lastMessage?.text ?? _specialLine,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _timeLabel,
                    style: const TextStyle(fontSize: 11, color: Colors.black45),
                  ),
                  if (_unreadCount > 0) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$_unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppointmentPickerSheet extends StatefulWidget {
  final AppointmentService appointmentService;

  const _AppointmentPickerSheet({required this.appointmentService});

  @override
  State<_AppointmentPickerSheet> createState() =>
      _AppointmentPickerSheetState();
}

class _AppointmentPickerSheetState extends State<_AppointmentPickerSheet> {
  List<Appointment> _appointments = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final response = await widget.appointmentService.getMyAppointments(
      status: 'confirmed',
      limit: 20,
    );
    if (!mounted) return;

    if (response.success && response.data != null) {
      setState(() {
        _appointments = response.data!;
        _loading = false;
      });
    } else {
      setState(() {
        _error =
            response.message ?? 'Unable to load your confirmed appointments';
        _loading = false;
      });
    }
  }

  void _select(Appointment appointment) {
    Navigator.of(context).pop(appointment.id);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            children: [
              Container(
                width: 42,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
              const Text(
                'Select appointment to chat',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _error!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.black54),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: _loadAppointments,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _appointments.isEmpty
                    ? const Center(
                        child: Text(
                          'No confirmed appointments yet.',
                          style: TextStyle(color: Colors.black54),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemBuilder: (context, index) {
                          final appointment = _appointments[index];
                          final doctorSpecialization =
                              appointment.doctor?.specialization ?? 'Doctor';
                          final dateLabel = DateFormat(
                            'MMM d • hh:mm a',
                          ).format(appointment.startTime.toLocal());
                          return Material(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                            child: ListTile(
                              onTap: () => _select(appointment),
                              title: Text(
                                doctorSpecialization,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(dateLabel),
                              trailing: const Icon(
                                Icons.chevron_right,
                                color: Colors.black45,
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemCount: _appointments.length,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
