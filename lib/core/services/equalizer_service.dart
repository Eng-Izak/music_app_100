import '../shared/enums/equalizer_preset.dart';

/// خدمة إدارة وتطبيق المعادل الصوتي (Equalizer Service)
/// تدير قيم الترددات الخمسة (60Hz, 230Hz, 910Hz, 4kHz, 14kHz)
/// وتتحكم في تضخيم الجهير (Bass Boost) ومحاكاة الصوت المحيطي ثلاثي الأبعاد (3D Surround)
class EqualizerService {
  bool _isEnabled = true;
  EqualizerPresetType _currentPreset = EqualizerPresetType.custom;

  // القيم الافتراضية للترددات الخمسة بالديسيبل (-12dB إلى +12dB)
  // تم ضبطها وفقاً للشكل في الصورة المرفقة (الصورة #5)
  Map<String, double> _bandGains = {
    '60Hz': 3.0,
    '230Hz': -2.0,
    '910Hz': 8.0,
    '4kHz': 4.0,
    '14kHz': 0.0,
  };

  // نسبة تضخيم الصوت الجهير (Bass Boost) من 0.0 إلى 1.0 (65% في الصورة)
  double _bassBoost = 0.65;

  // نسبة الصوت المحيطي ثلاثي الأبعاد (3D Surround) من 0.0 إلى 1.0 (25% في الصورة)
  double _virtualizer = 0.25;

  bool get isEnabled => _isEnabled;
  EqualizerPresetType get currentPreset => _currentPreset;
  Map<String, double> get bandGains => Map.unmodifiable(_bandGains);
  double get bassBoost => _bassBoost;
  double get virtualizer => _virtualizer;

  /// تشغيل أو إيقاف المعادل الصوتي
  void toggleEnabled() {
    _isEnabled = !_isEnabled;
  }

  /// ضبط كسب تردد معين بالديسيبل
  /// يتم تقييد القيمة رياضياً بين -12 ديسيبل و +12 ديسيبل
  void setBandGain(String band, double gainDb) {
    if (_bandGains.containsKey(band)) {
      _bandGains[band] = gainDb.clamp(-12.0, 12.0);
      _currentPreset = EqualizerPresetType.custom;
    }
  }

  /// ضبط نسبة تضخيم الصوت المنخفض (Bass Boost)
  /// القيمة بين 0.0 (0%) و 1.0 (100%)
  void setBassBoost(double value) {
    _bassBoost = value.clamp(0.0, 1.0);
  }

  /// ضبط نسبة المحاكاة المكانية ثلاثية الأبعاد (3D Surround)
  /// القيمة بين 0.0 (0%) و 1.0 (100%)
  void setVirtualizer(double value) {
    _virtualizer = value.clamp(0.0, 1.0);
  }

  /// تطبيق إعداد نمط صوتي مسبق (Preset)
  void applyPreset(EqualizerPresetType preset) {
    _currentPreset = preset;
    switch (preset) {
      case EqualizerPresetType.rock:
        _bandGains = {'60Hz': 4.8, '230Hz': 2.4, '910Hz': -1.2, '4kHz': 3.6, '14kHz': 6.0};
        _bassBoost = 0.50;
        _virtualizer = 0.30;
        break;
      case EqualizerPresetType.pop:
        _bandGains = {'60Hz': -1.2, '230Hz': 1.2, '910Hz': 4.8, '4kHz': 2.4, '14kHz': -2.4};
        _bassBoost = 0.35;
        _virtualizer = 0.20;
        break;
      case EqualizerPresetType.bassBooster:
        _bandGains = {'60Hz': 9.6, '230Hz': 6.0, '910Hz': 1.2, '4kHz': 0.0, '14kHz': -2.4};
        _bassBoost = 0.90;
        _virtualizer = 0.15;
        break;
      case EqualizerPresetType.classical:
        _bandGains = {'60Hz': 3.6, '230Hz': 2.4, '910Hz': -2.4, '4kHz': 2.4, '14kHz': 3.6};
        _bassBoost = 0.20;
        _virtualizer = 0.40;
        break;
      case EqualizerPresetType.electronic:
        _bandGains = {'60Hz': 6.0, '230Hz': 4.8, '910Hz': 0.0, '4kHz': 2.4, '14kHz': 4.8};
        _bassBoost = 0.70;
        _virtualizer = 0.35;
        break;
      case EqualizerPresetType.custom:
        break;
    }
  }
}

