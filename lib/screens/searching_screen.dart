import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/avox_header.dart';
import '../widgets/waveform_painter.dart';
import '../services/match_service.dart';
import 'active_call_screen.dart';

class SearchingScreen extends StatefulWidget {
  final String topic;
  const SearchingScreen({super.key, required this.topic});

  @override
  State<SearchingScreen> createState() => _SearchingScreenState();
}

class _SearchingScreenState extends State<SearchingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final AnimationController _waveCtrl;
  late final AnimationController _ringCtrl;
  late final Animation<double> _pulse;
  late final Animation<double> _ringScale;
  late final Animation<double> _ringOpacity;

  StreamSubscription<DocumentSnapshot>? _matchSub;
  Timer? _searchTimer;
  int _elapsedSeconds = 0;
  bool _searching = true;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startMatching();
  }

  void _initAnimations() {
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _pulse = Tween<double>(begin: 0.97, end: 1.03)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _ringScale = Tween<double>(begin: 1.0, end: 1.6)
        .animate(CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOut));

    _ringOpacity = Tween<double>(begin: 0.4, end: 0.0)
        .animate(CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOut));
  }

  Future<void> _startMatching() async {
    await MatchService.joinPool(widget.topic);

    _matchSub = MatchService.listenForMatch().listen((snapshot) {
      if (!_searching) return;
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        final channelId = data['channelId'] as String;
        final topic = data['topic'] as String;
        final matchedUid = data['matchedUid'] as String;
        _onMatchFound(channelId, topic, matchedUid);
      }
    });

    _searchTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (!_searching) return;
      setState(() => _elapsedSeconds += 3);
      await MatchService.findAndMatch(widget.topic);
    });
  }

  void _onMatchFound(String channelId, String topic, String matchedUid) async {
    if (!_searching) return;
    _searching = false;
    await MatchService.clearMatch();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ActiveCallScreen(
          topic: topic,
          channelId: channelId,
          matchedUid: matchedUid,
        ),
      ),
    );
  }

  Future<void> _cancel() async {
    _searching = false;
    await MatchService.leavePool();
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _waveCtrl.dispose();
    _ringCtrl.dispose();
    _matchSub?.cancel();
    _searchTimer?.cancel();
    super.dispose();
  }

  String get _waitLabel {
    if (_elapsedSeconds < 10) return 'Bağlantı Aranıyor...';
    if (_elapsedSeconds < 30) return 'Hâlâ Aranıyor...';
    return 'Biraz Daha Bekle...';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            CenteredHeader(
              title: 'a V o x',
              titleColor: AppColors.textPrimary,
              onClose: _cancel,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildAnimatedCard(),
                    const SizedBox(height: 44),
                    _buildStatusLabel(),
                    const SizedBox(height: 18),
                    _buildTopicChip(),
                    const SizedBox(height: 14),
                    _buildInfoText(),
                    const SizedBox(height: 44),
                    _buildCancelButton(),
                    const SizedBox(height: 20),
                    _buildSecurityBadge(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedCard() {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, child) => Transform.scale(scale: _pulse.value, child: child),
      child: SizedBox(
        width: 240,
        height: 240,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _ringCtrl,
              builder: (_, __) => Transform.scale(
                scale: _ringScale.value,
                child: Opacity(
                  opacity: _ringOpacity.value,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.secondary, width: 1.5),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.12),
                    blurRadius: 32,
                    spreadRadius: 6,
                  ),
                ],
              ),
              child: Center(
                child: AnimatedBuilder(
                  animation: _waveCtrl,
                  builder: (_, __) => CustomPaint(
                    size: const Size(88, 64),
                    painter: WaveformPainter(
                      animation: _waveCtrl,
                      color: AppColors.secondary,
                      barCount: 7,
                      barWidth: 4.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusLabel() {
    return Column(
      children: [
        Text(
          'DURUM',
          style: GoogleFonts.inter(
            color: AppColors.secondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _waitLabel,
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildTopicChip() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
      ),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
          children: [
            TextSpan(
              text: '#${widget.topic}',
              style: GoogleFonts.inter(
                color: AppColors.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const TextSpan(text: ' üzerine konuşacak birini arıyoruz.'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoText() {
    return Text(
      'Eşleşme sağlandığında mikrofonun otomatik\nolarak aktifleşecektir.',
      textAlign: TextAlign.center,
      style: GoogleFonts.inter(
        color: AppColors.textMuted,
        fontSize: 13,
        height: 1.6,
      ),
    );
  }

  Widget _buildCancelButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: _cancel,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(
          'İptal Et',
          style: GoogleFonts.inter(
            color: AppColors.secondary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityBadge() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 7),
        Text(
          'HATTINIZ GİZLİ VE GÜVENLİ',
          style: GoogleFonts.inter(
            color: AppColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
