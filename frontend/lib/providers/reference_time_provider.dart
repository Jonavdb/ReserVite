import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prbd_2526_f03/providers/simulated_time_provider.dart';

final referenceTimeProvider = Provider<AsyncValue<DateTime>>((ref) {
   final myWatchedAsyncValue = ref.watch(simulatedTimeProvider);

   return myWatchedAsyncValue.whenData((simulatedDate) {
     return simulatedDate ?? DateTime.now();
   });
});
