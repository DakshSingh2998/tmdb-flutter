import '../bundle/localization/localization_store.dart';

final localizationStore = LocalizationStore();

extension LocalizedString on String {
  String get loc {
    return localizationStore.translate(this);
  }
}

enum ScreenStatus { initial, loading, success, failure }
