import 'package:flutter/material.dart';

class SchemaUiTheme {
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color cardBackgroundColor;
  final Color textColor;
  final Color subtitleColor;
  final Color accentBadgeColor;
  final TextStyle headerTextStyle;
  final TextStyle bodyTextStyle;
  final TextStyle captionTextStyle;
  final double cardElevation;
  final EdgeInsets cardMargin;
  final EdgeInsets cardPadding;
  final BorderRadius borderRadius;

  const SchemaUiTheme({
    this.primaryColor = Colors.indigo,
    this.secondaryColor = Colors.indigoAccent,
    this.backgroundColor = const Color(0xF2F4F7FF),
    this.cardBackgroundColor = Colors.white,
    this.textColor = const Color(0xFF1E293B),
    this.subtitleColor = const Color(0xFF64748B),
    this.accentBadgeColor = const Color(0xFFE0E7FF),
    this.headerTextStyle = const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
    this.bodyTextStyle = const TextStyle(fontSize: 14, color: Color(0xFF334155)),
    this.captionTextStyle = const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
    this.cardElevation = 2.0,
    this.cardMargin = const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
    this.cardPadding = const EdgeInsets.all(16.0),
    this.borderRadius = const BorderRadius.all(Radius.circular(12.0)),
  });

  factory SchemaUiTheme.dark() {
    return const SchemaUiTheme(
      primaryColor: Colors.lightBlueAccent,
      secondaryColor: Colors.cyanAccent,
      backgroundColor: Color(0xFF0F172A),
      cardBackgroundColor: Color(0xFF1E293B),
      textColor: Color(0xFFF8FAFC),
      subtitleColor: Color(0xFF94A3B8),
      accentBadgeColor: Color(0xFF334155),
      headerTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFF8FAFC)),
      bodyTextStyle: TextStyle(fontSize: 14, color: Color(0xFFE2E8F0)),
      captionTextStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
    );
  }
}
