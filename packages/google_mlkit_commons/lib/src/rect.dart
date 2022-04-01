import 'dart:ui';

extension RectJson on Rect {
  /// Convert map to Rect.
  static Rect fromJson(Map<dynamic, dynamic> json) {
    return Rect.fromLTRB(
      json['left']?.toDouble() ?? 0,
      json['top']?.toDouble() ?? 0,
      json['right']?.toDouble() ?? 0,
      json['bottom']?.toDouble() ?? 0,
    );
  }
}
