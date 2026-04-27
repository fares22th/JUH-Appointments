import 'package:flutter/material.dart';

class JuhColors {
  JuhColors._();

  // Primary palette (hospital blue — hue 210)
  static const primary = Color(0xFF1565C0);
  static const primarySoft = Color(0xFFE3F0FF);
  static const primaryInk = Color(0xFF0D3E82);

  // Semantic
  static const success = Color(0xFF2E7D32);
  static const successSoft = Color(0xFFE8F5E9);
  static const warning = Color(0xFFF57F17);
  static const warningSoft = Color(0xFFFFF8E1);
  static const error = Color(0xFFC62828);
  static const errorSoft = Color(0xFFFFEBEE);
  static const info = Color(0xFF0277BD);
  static const infoSoft = Color(0xFFE1F5FE);

  // Neutral light
  static const bg = Color(0xFFF8F9FC);
  static const surface = Color(0xFFFFFFFF);
  static const border = Color(0xFFE2E8F0);
  static const textPrimary = Color(0xFF1A202C);
  static const textSecondary = Color(0xFF718096);
  static const textMuted = Color(0xFFA0AEC0);

  // Neutral dark
  static const bgDark = Color(0xFF0F1117);
  static const surfaceDark = Color(0xFF1A1D24);
  static const borderDark = Color(0xFF2D3344);
  static const textPrimaryDark = Color(0xFFF0F4FF);
  static const textSecondaryDark = Color(0xFF8896B0);

  // Status chips
  static const statusConfirmed = Color(0xFF2E7D32);
  static const statusCancelled = Color(0xFFC62828);
  static const statusPending = Color(0xFFF57F17);
}
