import 'package:flutter/material.dart';

class JuhColors {
  JuhColors._();

  // ── Primary: deep dark teal ──
  static const primary    = Color(0xFF003B4B);
  static const primarySoft = Color(0xFFE0EEF2);
  static const primaryInk  = Color(0xFF001E2B);
  static const primaryMid  = Color(0xFF005A72); // gradient partner

  // ── Accent: vibrant gold (CTA / notifications) ──
  static const accent     = Color(0xFFC9A84C);
  static const accentSoft = Color(0xFFFDF6E3);
  static const accentInk  = Color(0xFF9B7B30);

  // ── Semantic ──
  static const success     = Color(0xFF1D7A55);
  static const successSoft = Color(0xFFE6F4EE);
  static const warning     = Color(0xFFB8860B);
  static const warningSoft = Color(0xFFFFF8E1);
  static const error       = Color(0xFFC62828);
  static const errorSoft   = Color(0xFFFFEBEE);
  static const info        = Color(0xFF005A72); // = primaryMid
  static const infoSoft    = Color(0xFFE0EEF2); // = primarySoft

  // ── Neutral light ──
  static const bg            = Color(0xFFF3F7F8);
  static const surface       = Color(0xFFFFFFFF);
  static const border        = Color(0xFFD5E4E8);
  static const textPrimary   = Color(0xFF0D2B35);
  static const textSecondary = Color(0xFF537A8A);
  static const textMuted     = Color(0xFF8AADB8);

  // ── Neutral dark ──
  static const bgDark            = Color(0xFF081820);
  static const surfaceDark       = Color(0xFF0C2530);
  static const borderDark        = Color(0xFF1A3A4A);
  static const textPrimaryDark   = Color(0xFFE8F4F7);
  static const textSecondaryDark = Color(0xFF5A8EA0);

  // ── Status chips ──
  static const statusConfirmed = Color(0xFF1D7A55);
  static const statusCancelled = Color(0xFFC62828);
  static const statusPending   = Color(0xFFB8860B);
}
