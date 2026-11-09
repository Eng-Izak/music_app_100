/// امتدادات لمعالجة النصوص وتنسيقها
extension StringExtensions on String {
  /// اختصار النصوص الطويلة مع إضافة نقاط (...)
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }
}

