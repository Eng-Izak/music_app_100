import 'package:flutter_bloc/flutter_bloc.dart';
import 'equalizer_state.dart';
import '../../../core/services/equalizer_service.dart';
import '../../../core/shared/enums/equalizer_preset.dart';

/// كيبوت المعادل الصوتي (Equalizer Cubit)
/// مسؤول عن معالجة تحويلات الديسيبل وضبط الترددات والقرص الدوار (Rotary Knobs)
class EqualizerCubit extends Cubit<EqualizerState> {
  final EqualizerService _equalizerService;

  EqualizerCubit(this._equalizerService) : super(const EqualizerState()) {
    _syncFromService();
  }

  void _syncFromService() {
    emit(state.copyWith(
      isEnabled: _equalizerService.isEnabled,
      preset: _equalizerService.currentPreset,
      bandGains: _equalizerService.bandGains,
      bassBoost: _equalizerService.bassBoost,
      virtualizer: _equalizerService.virtualizer,
    ));
  }

  /// تشغيل أو إيقاف المعادل الصوتي
  void togglePower() {
    _equalizerService.toggleEnabled();
    emit(state.copyWith(isEnabled: _equalizerService.isEnabled));
  }

  /// تغيير كسب تردد معين بالديسيبل (-12dB إلى +12dB)
  void setBandGain(String band, double gainDb) {
    _equalizerService.setBandGain(band, gainDb);
    emit(state.copyWith(
      preset: EqualizerPresetType.custom,
      bandGains: Map<String, double>.from(_equalizerService.bandGains),
    ));
  }

  /// ضبط نسبة تضخيم الجهير (Bass Boost)
  void setBassBoost(double value) {
    _equalizerService.setBassBoost(value);
    emit(state.copyWith(bassBoost: _equalizerService.bassBoost));
  }

  /// ضبط نسبة الصوت المحيطي ثلاثي الأبعاد (3D Surround)
  void setVirtualizer(double value) {
    _equalizerService.setVirtualizer(value);
    emit(state.copyWith(virtualizer: _equalizerService.virtualizer));
  }

  /// اختيار وضبط نمط صوتي مسبق (Preset)
  void selectPreset(EqualizerPresetType preset) {
    _equalizerService.applyPreset(preset);
    _syncFromService();
  }
}

