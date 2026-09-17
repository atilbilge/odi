import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

class UserSettings {
  final String selectedVoice; // Default is 'native' (built-in OS engine)
  final int dailyGoalMinutes; // Default: 20 minutes
  final String userName;      // Default: 'Atil'
  final String userGender;    // 'Male' / 'Female' or 'Erkek' / 'Kadın'
  final bool autoPlayAudio;   // Default: true (auto-speak on check)

  UserSettings({
    required this.selectedVoice,
    required this.dailyGoalMinutes,
    required this.userName,
    required this.userGender,
    this.autoPlayAudio = true,
  });

  factory UserSettings.defaultConfig() => UserSettings(
    selectedVoice: 'native',
    dailyGoalMinutes: 20,
    userName: 'Atil',
    userGender: 'Male',
    autoPlayAudio: true,
  );

  Map<String, dynamic> toJson() => {
    'selectedVoice': selectedVoice,
    'dailyGoalMinutes': dailyGoalMinutes,
    'userName': userName,
    'userGender': userGender,
    'autoPlayAudio': autoPlayAudio,
  };

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    final voice = json['selectedVoice'] as String? ?? 'native';
    return UserSettings(
      selectedVoice: (voice == 'nikola' || voice == 'milica' || voice == 'hr' || voice == 'sr') ? 'native' : voice,
      dailyGoalMinutes: json['dailyGoalMinutes'] as int? ?? 20,
      userName: json['userName'] as String? ?? 'Atil',
      userGender: json['userGender'] as String? ?? 'Male',
      autoPlayAudio: json['autoPlayAudio'] as bool? ?? true,
    );
  }

  UserSettings copyWith({
    String? selectedVoice,
    int? dailyGoalMinutes,
    String? userName,
    String? userGender,
    bool? autoPlayAudio,
  }) {
    return UserSettings(
      selectedVoice: selectedVoice ?? this.selectedVoice,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      userName: userName ?? this.userName,
      userGender: userGender ?? this.userGender,
      autoPlayAudio: autoPlayAudio ?? this.autoPlayAudio,
    );
  }
}

class SettingsNotifier extends StateNotifier<UserSettings> {
  SettingsNotifier() : super(UserSettings.defaultConfig()) {
    loadSettings();
  }

  Future<File> get _settingsFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/user_settings.json');
  }

  Future<void> loadSettings() async {
    try {
      final file = await _settingsFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        final json = jsonDecode(contents) as Map<String, dynamic>;
        state = UserSettings.fromJson(json);
      }
    } catch (e) {
      // Fallback to default config on error
    }
  }

  Future<void> updateVoice(String voice) async {
    state = state.copyWith(selectedVoice: voice);
    try {
      final file = await _settingsFile;
      await file.writeAsString(jsonEncode(state.toJson()));
    } catch (e) {
      // Handle write error
    }
  }

  Future<void> updateDailyGoal(int minutes) async {
    state = state.copyWith(dailyGoalMinutes: minutes);
    try {
      final file = await _settingsFile;
      await file.writeAsString(jsonEncode(state.toJson()));
    } catch (e) {
      // Handle write error
    }
  }

  Future<void> updateUserName(String name) async {
    state = state.copyWith(userName: name.trim().isEmpty ? 'Atil' : name.trim());
    try {
      final file = await _settingsFile;
      await file.writeAsString(jsonEncode(state.toJson()));
    } catch (_) {}
  }

  Future<void> updateUserGender(String gender) async {
    state = state.copyWith(userGender: gender);
    try {
      final file = await _settingsFile;
      await file.writeAsString(jsonEncode(state.toJson()));
    } catch (_) {}
  }

  Future<void> updateAutoPlayAudio(bool enabled) async {
    state = state.copyWith(autoPlayAudio: enabled);
    try {
      final file = await _settingsFile;
      await file.writeAsString(jsonEncode(state.toJson()));
    } catch (_) {}
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, UserSettings>((ref) {
  return SettingsNotifier();
});
