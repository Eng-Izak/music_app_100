import 'package:equatable/equatable.dart';
import '../../../core/shared/enums/equalizer_preset.dart';

/// حالة المعادل الصوتي (Equalizer State)
class EqualizerState extends Equatable {
  final bool isEnabled;
  final EqualizerPresetType preset;
  final Map<String, double> bandGains; // كسب الترددات بالديسيبل (-12 إلى +12)
  final double bassBoost; // نسبة تضخيم الجهير (0.0 إلى 1.0)
  final double virtualizer; // نسبة الصوت المحيطي (0.0 إلى 1.0)

  const EqualizerState({
    this.isEnabled = true,
    this.preset = EqualizerPresetType.custom,
    this.bandGains = const {
      '60Hz': 3.0,
      '230Hz': -2.0,
      '910Hz': 8.0,
      '4kHz': 4.0,
      '14kHz': 0.0,
    },
    this.bassBoost = 0.65,
    this.virtualizer = 0.25,
  });

  EqualizerState copyWith({
    bool? isEnabled,
    EqualizerPresetType? preset,
    Map<String, double>? bandGains,
    double? bassBoost,
    double? virtualizer,
  }) {
    return EqualizerState(
      isEnabled: isEnabled ?? this.isEnabled,
      preset: preset ?? this.preset,
      bandGains: bandGains ?? this.bandGains,
      bassBoost: bassBoost ?? this.bassBoost,
      virtualizer: virtualizer ?? this.virtualizer,
    );
  }

  @override
  List<Object?> get props => [
        isEnabled,
        preset,
        bandGains,
        bassBoost,
        virtualizer,
      ];
}

