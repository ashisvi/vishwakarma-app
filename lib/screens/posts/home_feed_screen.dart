import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';
import 'create_post_screen.dart';
import '../profile/profile_screen.dart';

class HomeFeedScreen extends StatelessWidget {
  const HomeFeedScreen({super.key, this.isAdmin = false});

  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: _buildAppBar(context),
      body: const _HomeFeedBody(),
      floatingActionButton: isAdmin ? _buildFab(context) : null,
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primarySaffron,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 16,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vishwakarma',
            style: GoogleFonts.notoSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.whiteCard,
            ),
          ),
          Text(
            'Yuva Sangathan',
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.whiteCard.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          color: AppColors.whiteCard,
          onPressed: () {},
        ),
        const SizedBox(width: 4),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
            },
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.whiteCard.withValues(alpha: 0.1),
              child: const Icon(Icons.person, color: AppColors.whiteCard),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFab(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const CreatePostScreen()));
      },
      backgroundColor: AppColors.primarySaffron,
      foregroundColor: AppColors.whiteCard,
      icon: const Icon(Icons.edit),
      label: Text(
        'Create Post',
        style: GoogleFonts.notoSans(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _HomeFeedBody extends StatelessWidget {
  const _HomeFeedBody();

  @override
  Widget build(BuildContext context) {
    final posts = _demoPosts;
    final pinned = posts.where((p) => p.isPinned).toList();
    final regular = posts.where((p) => !p.isPinned).toList();

    return ListView(
      padding: const EdgeInsets.all(10),
      children: [
        if (pinned.isNotEmpty) ...[
          _PinnedSection(post: pinned.first),
          const SizedBox(height: 16),
        ],
        ...regular
            .map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _PostCard(post: p),
              ),
            )
            .toList(),
      ],
    );
  }
}

class _PinnedSection extends StatelessWidget {
  const _PinnedSection({required this.post});

  final _Post post;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.goldAccent, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.goldAccent.withValues(alpha: 0.12),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.push_pin, size: 18, color: AppColors.primarySaffron),
                const SizedBox(width: 8),
                Text(
                  'Pinned Announcement',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.maroon,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: _PostCard(post: post, isInsidePinned: true),
          ),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({required this.post, this.isInsidePinned = false});

  final _Post post;
  final bool isInsidePinned;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteCard,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 8),
            _buildContent(),
            if (post.imageUrls.isNotEmpty) ...[
              const SizedBox(height: 12),
              _PostImageSlider(imageUrls: post.imageUrls),
            ],
            const SizedBox(height: 12),
            _ReactionBar(post: post),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.creamBackground,
          child: Text(
            post.authorName.characters.first.toUpperCase(),
            style: GoogleFonts.notoSans(
              fontWeight: FontWeight.w700,
              color: AppColors.maroon,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.authorName,
                style: GoogleFonts.notoSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.maroon,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                post.designation,
                style: GoogleFonts.notoSansDevanagari(
                  fontSize: 13,
                  color: AppColors.maroon.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                post.timeAgo,
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  color: AppColors.maroon.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Text(
      post.content,
      style: GoogleFonts.notoSansDevanagari(
        fontSize: 14,
        height: 1.5,
        color: AppColors.maroon.withValues(alpha: 0.95),
      ),
    );
  }
}

class _PostImageSlider extends StatefulWidget {
  const _PostImageSlider({required this.imageUrls});

  final List<String> imageUrls;

  @override
  State<_PostImageSlider> createState() => _PostImageSliderState();
}

class _PostImageSliderState extends State<_PostImageSlider> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.imageUrls.length,
              onPageChanged: (i) => setState(() => _currentIndex = i),
              itemBuilder: (context, index) {
                // Replace with Image.network/asset when real URLs are used
                return Container(
                  color: AppColors.creamBackground,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.image,
                    size: 56,
                    color: AppColors.primarySaffron.withValues(alpha: 0.7),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.imageUrls.length,
            (i) => Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i == _currentIndex
                    ? AppColors.primarySaffron
                    : AppColors.primarySaffron.withValues(alpha: 0.3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReactionBar extends StatelessWidget {
  const _ReactionBar({required this.post});

  final _Post post;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _ReactionButton(
          icon: Icons.thumb_up_alt_outlined,
          labelHi: 'पसंद करें',
          count: post.likes,
        ),
        _ReactionButton(
          icon: Icons.thumb_down_alt_outlined,
          labelHi: 'नापसंद करें',
          count: post.dislikes,
        ),
        _ReactionButton(
          icon: Icons.chat_bubble_outline,
          labelHi: 'टिप्पणी',
          count: post.comments,
        ),
      ],
    );
  }
}

class _ReactionButton extends StatelessWidget {
  const _ReactionButton({
    required this.icon,
    required this.labelHi,
    required this.count,
  });

  final IconData icon;
  final String labelHi;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // TODO: Hook up reactions
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color: AppColors.maroon.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 6),
              Text(
                '$count',
                style: GoogleFonts.notoSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.maroon,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Post {
  _Post({
    required this.authorName,
    required this.designation,
    required this.timeAgo,
    required this.content,
    this.imageUrls = const [],
    this.likes = 0,
    this.dislikes = 0,
    this.comments = 0,
    this.isPinned = false,
  });

  final String authorName;
  final String designation;
  final String timeAgo;
  final String content;
  final List<String> imageUrls;
  final int likes;
  final int dislikes;
  final int comments;
  final bool isPinned;
}

final List<_Post> _demoPosts = [
  _Post(
    authorName: 'Rajesh Kumar',
    designation: 'अध्यक्ष, युवा समिति',
    timeAgo: '2 घंटे पहले',
    content:
        'कल शाम 5 बजे सामुदायिक भवन में बैठक रखी गई है। सभी सदस्य समय पर पहुँचने की कृपा करें। महत्वपूर्ण निर्णय लिए जाएंगे, इसलिए उपस्थिति आवश्यक है।',
    imageUrls: ['1', '2'],
    likes: 42,
    dislikes: 1,
    comments: 12,
    isPinned: true,
  ),
  _Post(
    authorName: 'Sunita Devi',
    designation: 'महिला मंडल सदस्य',
    timeAgo: '4 घंटे पहले',
    content:
        'आने वाले त्यौहार के लिए साफ-सफाई अभियान रविवार सुबह 7 बजे से शुरू होगा। सभी युवाओं से अनुरोध है कि झाड़ू, फावड़ा आदि लेकर समय पर आएँ।',
    imageUrls: const [],
    likes: 35,
    dislikes: 0,
    comments: 8,
  ),
  _Post(
    authorName: 'Amit Verma',
    designation: 'शिक्षा सहयोगी',
    timeAgo: 'कल',
    content:
        'कक्षा 10 और 12 के विद्यार्थियों के लिए निःशुल्क कोचिंग कक्षाएँ अगले सप्ताह से शुरू होंगी। इच्छुक विद्यार्थी अपना नाम इस पोस्ट पर टिप्पणी करके दर्ज कराएँ।',
    imageUrls: ['1'],
    likes: 51,
    dislikes: 3,
    comments: 19,
  ),
];
