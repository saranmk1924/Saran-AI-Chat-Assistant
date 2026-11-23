import 'dart:math';

Stream<String> typewriter(
  Stream<String> source, {
  int charsPerTick = 3,
  Duration tick = const Duration(milliseconds: 20),
}) async* {
  await for (final piece in source) {
    final runes = piece.runes.toList();
    for (var i = 0; i < runes.length; i += charsPerTick) {
      final end = min(i + charsPerTick, runes.length);
      yield String.fromCharCodes(runes.sublist(i, end));
      await Future<void>.delayed(tick);
    }
  }
}