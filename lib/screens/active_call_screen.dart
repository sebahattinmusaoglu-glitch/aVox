import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/avox_header.dart';
import '../widgets/waveform_painter.dart';
import 'rating_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/match_service.dart';
import '../services/agora_service.dart';

class ActiveCallScreen extends StatefulWidget {
  final String topic;
  final String channelId;
  final String matchedUid;

  const ActiveCallScreen({
    super.key,
    required this.topic,
    required this.channelId,
    required this.matchedUid,
  });

  @override
  State<ActiveCallScreen> createState() => _ActiveCallScreenState();
}

class _ActiveCallScreenState extends State<ActiveCallScreen>
    with SingleTickerProviderStateMixin {
  bool _isMuted = false;
  bool _isSpeaker = false;
  late final AnimationController _waveCtrl;
  late Timer _timer;
  int _elapsed = 0;
  StreamSubscription<DocumentSnapshot>? _sessionSub; 


  String get _shortUid =>
      widget.matchedUid.substring(0, 4).toUpperCase();

@override
void initState() {
  super.initState();
  _waveCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 750),
  )..repeat();

  _timer = Timer.periodic(
    const Duration(seconds: 1),
    (_) { if (mounted) setState(() => _elapsed++); },
  );

  // TODO: Agora.joinChannel(widget.channelId)
  _initSession();
} // ← initState burada kapanıyor

Future<void> _initSession() async {
  await AgoraService.init();   
  await AgoraService.joinChannel(widget.channelId); 

  await MatchService.startSession(widget.channelId);

  _sessionSub = MatchService.listenSession(widget.channelId).listen((snap) {
    if (!snap.exists) return;
    final data = snap.data() as Map<String, dynamic>;
    if (data['status'] == 'ended' && mounted) {
      _navigateToRating();
    }
  });
}

@override
void dispose() {
  _waveCtrl.dispose();
  _timer.cancel();
  _sessionSub?.cancel(); // ← ekle
  AgoraService.dispose();
  // TODO: Agora.leaveChannel()
  super.dispose();
}

  String get _formattedTime {
    final m = (_elapsed ~/ 60).toString().padLeft(2, '0');
    final s = (_elapsed % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

void _endCall() async {
  await MatchService.endSession(widget.channelId);
}

void _navigateToRating() {
  _sessionSub?.cancel();
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => RatingScreen(
        topic: widget.topic,
        userId: _shortUid,
      ),
    ),
  );
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AVoxHeader(badgeText: 'GÜVENLİ HAT'),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 28),
                    _buildTopicSection(),
                    const SizedBox(height: 36),
                    _buildUserCard(),
                    const SizedBox(height: 20),
                    _buildAudioStatus(),
                    const SizedBox(height: 20),
                  ],
                ),
                ),
              ),
            ),
            _buildCallControls(), // ← Expanded dışında, en altta
          ],
        ),
      ),
    );
  }

  Widget _buildTopicSection() {
    return Column(
      children: [
        Text(
          'SESE BAĞLANDI',
          style: GoogleFonts.inter(
            color: AppColors.secondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.5,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '# ${widget.topic}',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _formattedTime,
          style: GoogleFonts.inter(
            color: AppColors.textMuted,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildUserCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildGeometricAvatar(),
          const SizedBox(height: 16),
          Text(
            'USER #$_shortUid',
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

Widget _buildGeometricAvatar() {
  return Container(
    width: 110,
    height: 110,
    decoration: BoxDecoration(
      color: AppColors.secondary.withOpacity(0.12),
      borderRadius: BorderRadius.circular(14),
    ),
    child: CustomPaint(
      painter: _GeometricAvatarPainter(color: AppColors.secondary),
    ),
  );
}

  Widget _buildAudioStatus() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Ses aktarımı yapılıyor...',
          style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13),
        ),
        const SizedBox(width: 8),
        AnimatedBuilder(
          animation: _waveCtrl,
          builder: (_, __) => CustomPaint(
            size: const Size(42, 16),
            painter: WaveformPainter(
              animation: _waveCtrl,
              color: AppColors.textMuted,
              barCount: 5,
              barWidth: 2.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCallControls() {
    return Container(
      padding: const EdgeInsets.fromLTRB(40, 16, 40, 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildControlBtn(
            icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_off_outlined,
            label: 'SESSİZ',
            onTap: () {
              setState(() => _isMuted = !_isMuted);
              AgoraService.muteLocalAudio(_isMuted); // ← ekle
            },
            isActive: _isMuted,
          ),
          _buildEndBtn(),
          _buildControlBtn(
            icon: _isSpeaker ? Icons.volume_up_rounded : Icons.volume_up_outlined,
            label: 'HOPARLÖR',
            onTap: () {
              setState(() => _isSpeaker = !_isSpeaker);
              AgoraService.setLoudspeaker(_isSpeaker); // ← ekle
            },
            isActive: _isSpeaker,
            activeColor: AppColors.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildControlBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isActive,
    Color? activeColor,
  }) {
    final color = activeColor ?? AppColors.textSecondary;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isActive ? color.withOpacity(0.18) : AppColors.card,
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive ? color.withOpacity(0.5) : AppColors.border,
              ),
            ),
            child: Icon(
              icon,
              color: isActive ? color : AppColors.textSecondary,
              size: 22,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              color: AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEndBtn() {
    return GestureDetector(
      onTap: _endCall,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0xFFE53935), // ← AppColors.danger yerine direkt renk
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.call_end_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'BİTİR',
            style: TextStyle(
              color: Color(0xFFE53935),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

class _GeometricAvatarPainter extends CustomPainter {
  final Color color;
  _GeometricAvatarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    for (int i = 0; i < 3; i++) {
      final r = size.width * (0.32 - i * 0.07);
      final opacity = (0.55 - i * 0.12).clamp(0.0, 1.0); // ← ekle
      final paint = Paint()
        ..color = color.withOpacity(opacity) // ← withValues yerine
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      final path = Path()
        ..moveTo(cx, cy - r)
        ..lineTo(cx + r, cy)
        ..lineTo(cx, cy + r)
        ..lineTo(cx - r, cy)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_GeometricAvatarPainter old) => false;
}