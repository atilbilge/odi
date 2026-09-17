import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/settings_service.dart';
import '../../core/services/notion_sync_service.dart';
import '../../core/theme/app_theme.dart';
import '../progress/progress_screen.dart';
import 'home_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _nameController = TextEditingController();
  bool _isSyncing = false;
  String? _syncResult;
  bool _syncSuccess = false;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _nameController.text = settings.userName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _runSync() async {
    if (_isSyncing) return;
    setState(() { _isSyncing = true; _syncResult = null; });

    final svc = ref.read(notionSyncServiceProvider);
    final result = await svc.sync();

    if (mounted) {
      if (result.isSuccess) {
        ref.invalidate(lessonsProvider);
        ref.invalidate(lessonsWithStatsProvider);
      }
      setState(() {
        _isSyncing = false;
        _syncSuccess = result.isSuccess;
        _syncResult = result.isSuccess
            ? '${result.lessonsAdded} new lessons and ${result.wordsAdded} new words downloaded successfully.'
            : result.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final goalOptions = [10, 15, 20, 30, 45, 60];

    // Normalize gender string for dropdown
    final currentGender = (settings.userGender == 'Kadın' || settings.userGender == 'Female')
        ? 'Female'
        : 'Male';

    return Scaffold(
      backgroundColor: OdiColors.lightGrey,
      appBar: AppBar(
        title: Text('Settings', style: OdiTextStyles.h3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [

          // ── Profile Information ───────────────────────────────────────────
          _sectionLabel('PROFILE & PREFERENCES'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: OdiDecorations.card(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This information is used to personalize practice sentences with your name and adapt Serbian grammar (masculine/feminine inflections) according to your gender.',
                  style: OdiTextStyles.caption.copyWith(color: OdiColors.midGrey, height: 1.4),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                // Name Input
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [OdiColors.coral, OdiColors.sunset]),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.person_outline_rounded, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        style: OdiTextStyles.body1.copyWith(fontWeight: FontWeight.w600),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 4),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          labelText: 'Your Name',
                          labelStyle: TextStyle(color: OdiColors.midGrey, fontSize: 12),
                          filled: false,
                        ),
                        onChanged: (val) => settingsNotifier.updateUserName(val),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                // Gender Dropdown
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [OdiColors.ocean, OdiColors.deepSea]),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.wc_rounded, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text('Gender', style: OdiTextStyles.body1.copyWith(fontWeight: FontWeight.w600)),
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: currentGender,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: OdiColors.midGrey),
                        style: OdiTextStyles.body1.copyWith(color: OdiColors.coral, fontWeight: FontWeight.w600),
                        items: ['Male', 'Female'].map((g) => DropdownMenuItem<String>(
                          value: g,
                          child: Text(g),
                        )).toList(),
                        onChanged: (val) {
                          if (val != null) settingsNotifier.updateUserGender(val);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // ── Training Goal & Audio ─────────────────────────────────────────
          _sectionLabel('PRACTICE & AUDIO'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: OdiDecorations.card(),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [OdiColors.coral, OdiColors.sunset]),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.track_changes_rounded, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text('Daily Goal', style: OdiTextStyles.body1.copyWith(fontWeight: FontWeight.w600)),
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: settings.dailyGoalMinutes,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: OdiColors.midGrey),
                        style: OdiTextStyles.body1.copyWith(color: OdiColors.coral, fontWeight: FontWeight.w600),
                        items: goalOptions.map((mins) => DropdownMenuItem<int>(
                          value: mins,
                          child: Text('$mins min'),
                        )).toList(),
                        onChanged: (val) { if (val != null) settingsNotifier.updateDailyGoal(val); },
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                // Auto-play Audio Switch
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [OdiColors.ocean, OdiColors.deepSea]),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        settings.autoPlayAudio ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Auto-play Audio', style: OdiTextStyles.body1.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text('Automatically pronounce words on check', style: OdiTextStyles.caption),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: settings.autoPlayAudio,
                      activeTrackColor: OdiColors.coral,
                      onChanged: (val) => settingsNotifier.updateAutoPlayAudio(val),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // ── Study Plan Download ──────────────────────────────────────────
          _sectionLabel('CURRICULUM'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: OdiDecorations.card(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [OdiColors.ocean, OdiColors.deepSea]),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.cloud_download_rounded, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text('Curriculum & Lesson Update',
                        style: OdiTextStyles.body1.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Tap below to download the latest lessons, vocabulary, and study plan from the cloud.',
                  style: OdiTextStyles.body2.copyWith(color: OdiColors.midGrey),
                ),
                const SizedBox(height: 20),
                if (_syncResult != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (_syncSuccess ? OdiColors.success : OdiColors.error).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: (_syncSuccess ? OdiColors.success : OdiColors.error).withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text(
                      _syncResult!,
                      style: OdiTextStyles.body2.copyWith(
                        color: _syncSuccess ? OdiColors.success : OdiColors.error,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _isSyncing ? null : _runSync,
                    icon: _isSyncing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.download_rounded, size: 18),
                    label: Text(_isSyncing ? 'Downloading Plan...' : 'Download Curriculum'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // ── System ─────────────────────────────────────────────────────
          _sectionLabel('SYSTEM'),
          const SizedBox(height: 10),
          Container(
            decoration: OdiDecorations.card(),
            child: Column(
              children: [
                _settingsTile(
                  icon: Icons.bar_chart_rounded,
                  iconGradient: const LinearGradient(colors: [OdiColors.ocean, OdiColors.deepSea]),
                  title: 'Progress History',
                  subtitle: 'Practice statistics and detailed report',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProgressScreen()),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Footer
          Center(
            child: Column(
              children: [
                Text('Odi v1.0.0',
                    style: OdiTextStyles.body2.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('Serbian Practice with Echo', style: OdiTextStyles.caption),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
    text,
    style: OdiTextStyles.label.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.2),
  );

  Widget _settingsTile({
    required IconData icon,
    required Gradient iconGradient,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) =>
      Material(
        color: Colors.transparent,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: iconGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          title: Text(title, style: OdiTextStyles.body1.copyWith(fontWeight: FontWeight.w600)),
          subtitle: Text(subtitle, style: OdiTextStyles.body2),
          trailing: const Icon(Icons.chevron_right_rounded, color: OdiColors.midGrey),
          onTap: onTap,
        ),
      );
}
