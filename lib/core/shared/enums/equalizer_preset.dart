/// الإعدادات المسبقة للمعادل الصوتي (Equalizer Presets)
enum EqualizerPresetType {
  custom('Custom'),
  rock('Rock'),
  pop('Pop'),
  bassBooster('Bass Booster'),
  classical('Classical'),
  electronic('Electronic');

  final String displayName;
  const EqualizerPresetType(this.displayName);
}

