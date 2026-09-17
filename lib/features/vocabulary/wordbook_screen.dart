import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/database/database_service.dart';
import '../../core/database/models/vocabulary.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/speech_service.dart';
import '../../core/services/settings_service.dart';
import '../home/home_screen.dart';

class WordbookScreen extends ConsumerStatefulWidget {
  final bool isTab;
  const WordbookScreen({super.key, this.isTab = false});

  @override
  ConsumerState<WordbookScreen> createState() => _WordbookScreenState();
}

class _WordbookScreenState extends ConsumerState<WordbookScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  List<Vocabulary> _curriculumVocab = [];
  List<Vocabulary> _customVocab = [];
  bool _isLoading = true;

  String? _currentlyPlayingText;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadVocabulary();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    final settings = ref.read(settingsProvider);
    final voice = settings.selectedVoice;
    await ref.read(speechServiceProvider).initialize(selectedVoice: voice);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadVocabulary() async {
    final db = ref.read(databaseServiceProvider);
    final List<Vocabulary> curriculum = [];
    final lessons = await db.getAllLessons();
    for (final l in lessons) {
      curriculum.addAll(await db.getVocabularyForLesson(l.id));
    }
    final custom = await db.getCustomVocabulary();
    if (mounted) {
      setState(() {
        _curriculumVocab = curriculum;
        _customVocab = custom;
        _isLoading = false;
      });
    }
  }

  List<Vocabulary> _filterVocab(List<Vocabulary> list) {
    if (_searchQuery.isEmpty) return list;
    final q = _searchQuery.toLowerCase();
    return list.where((v) =>
        v.serbianText.toLowerCase().contains(q) ||
        v.turkishText.toLowerCase().contains(q) ||
        (v.englishText?.toLowerCase().contains(q) ?? false)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OdiColors.lightGrey,
      appBar: AppBar(
        backgroundColor: OdiColors.cardWhite,
        elevation: 0,
        automaticallyImplyLeading: !widget.isTab,
        leading: widget.isTab
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: OdiColors.anthracite),
                onPressed: () => Navigator.of(context).pop(),
              ),
        title: Text('Wordbook', style: OdiTextStyles.h3),
        bottom: TabBar(
          controller: _tabController,
          labelColor: OdiColors.coral,
          unselectedLabelColor: OdiColors.midGrey,
          indicatorColor: OdiColors.coral,
          indicatorWeight: 3,
          labelStyle: OdiTextStyles.body2.copyWith(fontWeight: FontWeight.w600, color: OdiColors.coral),
          unselectedLabelStyle: OdiTextStyles.body2,
          tabs: const [
            Tab(text: 'Curriculum'),
            Tab(text: 'Custom Words'),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Search Bar
            TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              style: OdiTextStyles.body1,
              decoration: InputDecoration(
                hintText: 'Search words...',
                hintStyle: OdiTextStyles.body2,
                prefixIcon: const Icon(Icons.search_rounded, color: OdiColors.midGrey),
                filled: true,
                fillColor: OdiColors.cardWhite,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: OdiColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: OdiColors.coral, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: OdiColors.coral))
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildVocabList(_filterVocab(_curriculumVocab)),
                        _buildVocabList(_filterVocab(_customVocab)),
                      ],
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddWordDialog(context),
        backgroundColor: OdiColors.coral,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildVocabList(List<Vocabulary> list) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.menu_book_outlined, color: OdiColors.midGrey, size: 48),
            const SizedBox(height: 12),
            Text('No words found.', style: OdiTextStyles.body1.copyWith(color: OdiColors.midGrey)),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final vocab = list[index];
        final lastPracticed = vocab.lastPracticedDate != null
            ? DateFormat('dd.MM.yyyy').format(vocab.lastPracticedDate!)
            : null;

        Color scoreColor;
        Color scoreBg;
        if (vocab.successRate >= 80.0) {
          scoreColor = OdiColors.success;
          scoreBg = OdiColors.success.withValues(alpha: 0.1);
        } else if (vocab.successRate > 0) {
          scoreColor = OdiColors.warning;
          scoreBg = OdiColors.warning.withValues(alpha: 0.1);
        } else {
          scoreColor = OdiColors.midGrey;
          scoreBg = OdiColors.lightGrey;
        }

        final isPlaying = _currentlyPlayingText == vocab.serbianText;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: OdiDecorations.card(radius: 14),
          child: Row(
            children: [
              // Language badge / Play button
              GestureDetector(
                onTap: () async {
                  if (isPlaying) return;
                  setState(() => _currentlyPlayingText = vocab.serbianText);
                  try {
                    await ref.read(speechServiceProvider).speak(vocab.serbianText);
                  } catch (_) {}
                  if (mounted) {
                    setState(() => _currentlyPlayingText = null);
                  }
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: isPlaying
                        ? const LinearGradient(colors: [OdiColors.coral, OdiColors.sunset])
                        : const LinearGradient(colors: [OdiColors.ocean, OdiColors.deepSea]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(
                      isPlaying ? Icons.volume_up_rounded : Icons.volume_mute_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(vocab.serbianText,
                              style: OdiTextStyles.body1.copyWith(fontWeight: FontWeight.w600)),
                        ),
                        if (vocab.wordType != null && vocab.wordType!.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: OdiColors.deepSea.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              vocab.wordType!,
                              style: OdiTextStyles.caption.copyWith(
                                color: OdiColors.deepSea,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(vocab.displayMeaning, style: OdiTextStyles.body2),
                    if (lastPracticed != null) ...[
                      const SizedBox(height: 4),
                      Text('Last practiced: $lastPracticed', style: OdiTextStyles.caption),
                    ],
                  ],
                ),
              ),
              // Success rate badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: scoreBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  vocab.successRate > 0 ? '%${vocab.successRate.toInt()}' : '—',
                  style: OdiTextStyles.label.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scoreColor,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddWordDialog(BuildContext context) {
    final serbianController = TextEditingController();
    final turkishController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: OdiColors.cardWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Add Word', style: OdiTextStyles.h3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: serbianController,
              style: OdiTextStyles.body1,
              decoration: OdiDecorations.inputDecoration(label: 'Serbian', hint: 'Zdravo'),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: turkishController,
              style: OdiTextStyles.body1,
              decoration: OdiDecorations.inputDecoration(label: 'Translation / Meaning', hint: 'Hello'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: OdiTextStyles.body2.copyWith(color: OdiColors.midGrey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final sText = serbianController.text.trim();
              final tText = turkishController.text.trim();
              if (sText.isNotEmpty && tText.isNotEmpty) {
                await ref.read(databaseServiceProvider).addCustomVocabulary(sText, tText);
                ref.read(progressNotifierProvider.notifier).addWords(1);
                await _loadVocabulary();
                if (ctx.mounted) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Word added successfully!'),
                      backgroundColor: OdiColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }
              }
            },
            child: Text('Add', style: OdiTextStyles.button),
          ),
        ],
      ),
    );
  }
}
