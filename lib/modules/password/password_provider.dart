import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'password_generator_service.dart';

final passwordGeneratorServiceProvider = Provider((ref) => PasswordGeneratorService());

final passwordLengthProvider = StateProvider<double>((ref) => 16.0);
final includeUppercaseProvider = StateProvider<bool>((ref) => true);
final includeNumbersProvider = StateProvider<bool>((ref) => true);
final includeSymbolsProvider = StateProvider<bool>((ref) => true);

final generatedPasswordProvider = StateProvider<String>((ref) => '');

/// Session-only password history list stored in memory.
final passwordHistoryProvider = StateNotifierProvider<PasswordHistoryNotifier, List<String>>((ref) {
  return PasswordHistoryNotifier();
});

class PasswordHistoryNotifier extends StateNotifier<List<String>> {
  PasswordHistoryNotifier() : super([]);

  void addPassword(String pwd) {
    if (pwd.isEmpty) return;
    state = [pwd, ...state];
  }

  void clearHistory() {
    state = [];
  }
}
