// lib/features/settings/providers/settings_provider.dart

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  // ── Keys ──────────────────────────────────────────────────
  static const _kTheme = 'theme';
  static const _kFontSize = 'fontSize';
  static const _kBubble = 'bubble';
  static const _kSound = 'sound';
  static const _kTyping = 'typing';
  static const _kChips = 'chips';
  static const _kPageSize = 'pageSize';

  // ── Defaults ──────────────────────────────────────────────
  AppThemeMode _theme = AppThemeMode.dark;
  FontSizeMode _fontSize = FontSizeMode.medium;
  BubbleStyle _bubble = BubbleStyle.rounded;
  bool _sound = false;
  bool _typing = true;
  bool _chips = true;
  int _pageSize = 5;

  // ── Getters ───────────────────────────────────────────────
  AppThemeMode get theme => _theme;
  FontSizeMode get fontSize => _fontSize;
  BubbleStyle get bubble => _bubble;
  bool get sound => _sound;
  bool get typing => _typing;
  bool get chips => _chips;
  int get pageSize => _pageSize;
  bool get isLight => _theme == AppThemeMode.light;
  
  // ── Font size in pts ──────────────────────────────────────
  double get messageFontSize {
    switch (_fontSize) {
      case FontSizeMode.small:
        return 12.5;
      case FontSizeMode.large:
        return 16.5;
      case FontSizeMode.medium:
        return 14.5;
    }
  }

  // ── Bubble radius ─────────────────────────────────────────
  double get bubbleRadius => _bubble == BubbleStyle.sharp ? 6.0 : 18.0;
  double get bubbleTailRadius => _bubble == BubbleStyle.sharp ? 2.0 : 4.0;

  // ── Load from prefs ───────────────────────────────────────
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _theme = AppThemeMode.values.firstWhere(
      (e) => e.name == (prefs.getString(_kTheme) ?? 'dark'),
      orElse: () => AppThemeMode.dark,
    );
    _fontSize = FontSizeMode.values.firstWhere(
      (e) => e.name == (prefs.getString(_kFontSize) ?? 'medium'),
      orElse: () => FontSizeMode.medium,
    );
    _bubble = BubbleStyle.values.firstWhere(
      (e) => e.name == (prefs.getString(_kBubble) ?? 'rounded'),
      orElse: () => BubbleStyle.rounded,
    );
    _sound = prefs.getBool(_kSound) ?? false;
    _typing = prefs.getBool(_kTyping) ?? true;
    _chips = prefs.getBool(_kChips) ?? true;
    _pageSize = prefs.getInt(_kPageSize) ?? 5;
    notifyListeners();
  }

  // ── Setters + save ────────────────────────────────────────
  Future<void> setTheme(AppThemeMode v) async {
    _theme = v;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setString(_kTheme, v.name);
  }

  Future<void> setFontSize(FontSizeMode v) async {
    _fontSize = v;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setString(_kFontSize, v.name);
  }

  Future<void> setBubble(BubbleStyle v) async {
    _bubble = v;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setString(_kBubble, v.name);
  }

  Future<void> setSound(bool v) async {
    _sound = v;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kSound, v);
  }

  Future<void> setTyping(bool v) async {
    _typing = v;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kTyping, v);
  }

  Future<void> setChips(bool v) async {
    _chips = v;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kChips, v);
  }

  Future<void> setPageSize(int v) async {
    _pageSize = v;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kPageSize, v);
  }
}

// ── Enums ─────────────────────────────────────────────────
enum AppThemeMode { dark, light }

enum FontSizeMode { small, medium, large }

enum BubbleStyle { rounded, sharp }
