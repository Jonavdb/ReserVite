import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:prbd_2526_f03/providers/current_user_provider.dart';
import '../models/client_state.dart';

final clientStateProvider = AsyncNotifierProvider<ClientStateNotifier, ClientState>(
      () => ClientStateNotifier(),
);

class ClientStateNotifier extends AsyncNotifier<ClientState> {
  @override
  Future<ClientState> build() async {
    ref.watch(currentUserProvider);
    final userNotifier = ref.watch(currentUserProvider.notifier);

    if(!userNotifier.isClient) {
      throw Exception("Access Denied: You must be logged in as a client.");
    }

    const defaultFilter = 'pending';

    final initialReservations = await ClientState.fetchReservations(defaultFilter);
    
    return ClientState(
        currentFilter: defaultFilter,
        reservations: initialReservations,
    );
  }

  Future<void> changeFilter(String newFilter) async {
    state = const AsyncLoading();

    try {
      final String? filterSanitized = (newFilter == 'all' || newFilter.isEmpty) ? null : newFilter;
      final updateReservations = await ClientState.fetchReservations(filterSanitized);
      state = AsyncData(ClientState(
        currentFilter: newFilter,
        reservations: updateReservations,
      ));
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }
}