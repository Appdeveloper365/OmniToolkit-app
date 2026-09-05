import 'dart:math';

class PasswordGeneratorService {
  static const _lowercase = 'abcdefghijklmnopqrstuvwxyz';
  static const _uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const _numbers = '0123456789';
  static const _symbols = r'!@#$%^&*()_+-=[]{}|;:,.<>?';

  String generate({
    int length = 16,
    bool includeUppercase = true,
    bool includeNumbers = true,
    bool includeSymbols = true,
  }) {
    final rand = Random.secure();
    final chars = StringBuffer(_lowercase);

    if (includeUppercase) chars.write(_uppercase);
    if (includeNumbers) chars.write(_numbers);
    if (includeSymbols) chars.write(_symbols);

    final pool = chars.toString();
    if (pool.isEmpty) return '';

    return List.generate(length, (_) => pool[rand.nextInt(pool.length)]).join();
  }
}
