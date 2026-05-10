import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/avox_header.dart';
import 'home_screen.dart';

class RatingScreen extends StatefulWidget {
  final String topic;
  final String userId;

  const RatingScreen({
    super.key,
    required this.topic,
    required this.userId,
  });

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  bool? _politeness;        // null=unrated, true=positive, false=negative
  int _topicKnowledge = 0;  // 0–5
  int _relevance = 0;       // 0–5
  final TextEditingController _feedbackCtrl = TextEditingController();

  bool get _hasInteraction =>
      _politeness != null ||
      _topicKnowledge > 0 ||
      _relevance > 0 ||
      _feedbackCtrl.text.trim().isNotEmpty;

  int get _earnedPoints {
  int points = 0;
  if (_politeness != null) points += 2;
  if (_topicKnowledge > 0) points += 2;
  if (_relevance > 0) points += 2;
  if (_feedbackCtrl.text.trim().isNotEmpty) points += 4;
  return points;
  }

  @override
  void dispose() {
    _feedbackCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _feedbackCtrl.addListener(() => setState(() {}));
  }

void _submit() {
  if (_hasInteraction) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Geri bildiriminiz için teşekkürler 🙏',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: AppColors.card,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const HomeScreen()),
    (_) => false,
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            CenteredHeader(
              title: 'Görüşme Sonlandı',
              titleColor: AppColors.secondary,
              onClose: _submit,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitle(),
                    const SizedBox(height: 24),
                    _buildUserRow(),
                    const SizedBox(height: 16),
                    _buildPolitenessCard(),
                    const SizedBox(height: 10),
                    _buildStarCard(
                      label: 'Konu Bilgisi',
                      value: _topicKnowledge,
                      onChanged: (v) =>
                          setState(() => _topicKnowledge = v),
                    ),
                    const SizedBox(height: 10),
                    _buildStarCard(
                      label: 'Alaka Düzeyi',
                      value: _relevance,
                      onChanged: (v) => setState(() => _relevance = v),
                    ),
                    const SizedBox(height: 20),
                    _buildFeedbackSection(),
                    const SizedBox(height: 24),
                    _buildComplaintLink(),
                    const SizedBox(height: 16),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: GoogleFonts.inter(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
            children: [
              TextSpan(
                text: 'Görüşme Nasıl\nGeçti?',
                style: GoogleFonts.inter(
                    color: AppColors.primary,
                    fontSize: 34,
                    fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
          Text(
          'Aşağıdaki alanları doldurmaya başla,', style: GoogleFonts.inter( color: AppColors.textPrimary, fontSize: 16,),
          ),

          Text(
          '${_earnedPoints > 0 ? '+$_earnedPoints ' : ''}itibar puanı kazan!',
            style: GoogleFonts.inter( color: AppColors.secondary, fontSize: 16, height: 1.55,),
              ),
      ],
    );
  }

  Widget _buildUserRow() {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.14),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.person_outline,
              color: AppColors.secondary, size: 26),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'KONUŞMACI',
              style: GoogleFonts.inter(
                color: AppColors.textMuted,
                fontSize: 11,
                letterSpacing: 1,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'USER #${widget.userId}',
              style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPolitenessCard() {
    return _ratingCard(
      label: 'Nezaket',
      child: Row(
        children: [
          Expanded(
              child: _thumbButton(
                  isPositive: false,
                  selected: _politeness == false,
                  onTap: () =>
                      setState(() => _politeness = false))),
          const SizedBox(width: 10),
          Expanded(
              child: _thumbButton(
                  isPositive: true,
                  selected: _politeness == true,
                  onTap: () =>
                      setState(() => _politeness = true))),
        ],
      ),
    );
  }

  Widget _thumbButton({
    required bool isPositive,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final activeColor =
        isPositive ? AppColors.success : AppColors.danger;
    final icon = isPositive
        ? Icons.thumb_up_outlined
        : Icons.thumb_down_outlined;
    final label = isPositive ? 'Olumlu' : 'Olumsuz';

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: selected ? activeColor.withOpacity(0.14) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? activeColor.withOpacity(0.55)
                : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: selected ? activeColor : AppColors.textMuted,
                size: 17),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                color: selected ? activeColor : AppColors.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarCard({
    required String label,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return _ratingCard(
      label: label,
      child: Row(
        children: List.generate(5, (i) {
          final filled = i < value;
          return GestureDetector(
            onTap: () => onChanged(i + 1),
            child: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Icon(
                filled ? Icons.star_rounded : Icons.star_outline_rounded,
                color: filled ? AppColors.warning : AppColors.textMuted,
                size: 30,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _ratingCard({required String label, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildFeedbackSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Geri Bildirim Yazın (Opsiyonel)',
          style: GoogleFonts.inter(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            controller: _feedbackCtrl,
            maxLines: 4,
            style: GoogleFonts.inter(
                color: AppColors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Deneyiminizi detaylandırın...',
              hintStyle: GoogleFonts.inter(
                  color: AppColors.textMuted, fontSize: 14),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComplaintLink() {
    return Center(
      child: GestureDetector(
        onTap: () {
          // TODO: Open complaint flow
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: AppColors.danger, size: 16),
            const SizedBox(width: 6),
            Text(
              'Şikayet Et',
              style: GoogleFonts.inter(
                color: AppColors.danger,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: Text(
          _hasInteraction ? 'Gönder ve Ana Sayfaya Dön' : 'Ana Sayfaya Dön',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.background,
          ),
        ),
      ),
    );
  }
}