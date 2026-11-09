/// امتدادات لفئة Duration لتحويل الفترات الزمنية إلى صياغة نصية أنيقة
extension DurationFormatting on Duration {
  /// تحويل المدة الزمنية إلى صياغة دقيقة:ثانية (مثل: 1:17 أو 4:03)
  /// تستخدم في شريط التقدم لشاشة Now Playing والمشغل المصغر
  String toMinutesSeconds() {
    final minutes = inMinutes.remainder(60);
    final seconds = inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// تحويل المدة الزمنية إلى صياغة ساعات ودقائق للمؤقت (مثل: 1h 30m)
  String toHoursMinutes() {
    final hours = inHours;
    final minutes = inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}

