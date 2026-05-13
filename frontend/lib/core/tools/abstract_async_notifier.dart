import 'package:hooks_riverpod/hooks_riverpod.dart';

// Le <T> permet à cette classe d'accepter n'importe quel type de donnée
// (WordPair?, List<WordPair>, etc.)
abstract class AbstractAsyncNotifier<T> extends AsyncNotifier<T> {
  Future<void> refresh();
}
