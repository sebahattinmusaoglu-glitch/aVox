import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/avox_header.dart';
import 'searching_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _topicController = TextEditingController();
  int _selectedNavIndex = 0;

  final List<String> _exampleTopics = [
    'Felsefe',
    'İlişkiler',
    'Mısır piramitleri',
    'Siyasi gündem',
    'Dün oynanan derbi maçı',
  ];

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  void _onFindPartner() {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lütfen bir konu girin',
            style: GoogleFonts.inter(color: Colors.white),
          ),
          backgroundColor: AppColors.card,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchingScreen(topic: topic),
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
            AVoxHeader(badgeText: 'MİSAFİR MODU'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 44),
                    _buildHeroTitle(),
                    const SizedBox(height: 32),
                    _buildTopicInput(),
                    const SizedBox(height: 20),
                    _buildExampleTags(),
                    const SizedBox(height: 40),
                    _buildFindButton(),
                  ],
                ),
              ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroTitle() {
    return RichText(
      text: TextSpan(
        style: GoogleFonts.inter(
          fontSize: 38,
          fontWeight: FontWeight.w800,
          height: 1.15,
          color: AppColors.textPrimary,
        ),
        children: [
          const TextSpan(text: 'Ne hakkında\n'),
          TextSpan(
            text: 'konuşmak\n',
            style: GoogleFonts.inter(
              fontSize: 38,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const TextSpan(text: 'istersin?'),
        ],
      ),
    );
  }

  Widget _buildTopicInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Icon(Icons.graphic_eq_rounded,
                color: AppColors.textMuted, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _topicController,
              style: GoogleFonts.inter(
                  color: AppColors.textPrimary, fontSize: 15),
              maxLines: 2,
              minLines: 2,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: 'Konu, uzmanlık veya duygu...',
                hintStyle: GoogleFonts.inter(
                    color: AppColors.textMuted, fontSize: 15),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleTags() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Örnek aramalar:',
          style: GoogleFonts.inter(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _exampleTopics.map(_buildTag).toList(),
        ),
      ],
    );
  }

  Widget _buildTag(String text) {
    return GestureDetector(
      onTap: () => setState(() => _topicController.text = text),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildFindButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _onFindPartner,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Konuşacak Birini Bul',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.background,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.person_add_outlined,
                size: 20, color: AppColors.background),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      (Icons.home_rounded, Icons.home_outlined, 'Anasayfa'),
      (Icons.chat_bubble_rounded, Icons.chat_bubble_outline_rounded,
          'Görüşmeler'),
      (Icons.person_rounded, Icons.person_outline_rounded, 'Profil'),
    ];

    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border:
            Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.asMap().entries.map((e) {
          final i = e.key;
          final (activeIcon, inactiveIcon, label) = e.value;
          final isSelected = i == _selectedNavIndex;
          return GestureDetector(
            onTap: () => setState(() => _selectedNavIndex = i),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 80,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isSelected ? activeIcon : inactiveIcon,
                    color: isSelected
                        ? AppColors.secondary
                        : AppColors.textMuted,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      color: isSelected
                          ? AppColors.secondary
                          : AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: isSelected ? 4 : 0,
                    height: isSelected ? 4 : 0,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
