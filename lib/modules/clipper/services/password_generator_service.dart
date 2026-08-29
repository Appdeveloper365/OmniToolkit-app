/// FILE: lib/modules/clipper/services/password_generator_service.dart
import 'dart:math';

/// Generates random passwords honoring the requested composition rules.
class PasswordGeneratorService {
  static const _lower = 'abcdefghijklmnopqrstuvwxyz';
  static const _upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const _numbers = '0123456789';
  static const _symbols = r'!@#$%^&*()_-+=<>?';

  final _random = Random.secure();

  String generate({
    required int length,
    required bool includeUppercase,
    required bool includeNumbers,
    required bool includeSymbols,
  }) {
    var pool = _lower;
    if (includeUppercase) pool += _upper;
    if (includeNumbers) pool += _numbers;
    if (includeSymbols) pool += _symbols;

    return List.generate(length, (_) => pool[_random.nextInt(pool.length)]).join();
  }
}
