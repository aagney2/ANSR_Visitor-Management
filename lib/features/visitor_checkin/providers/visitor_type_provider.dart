import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/app_exception.dart';
import '../../../data/models/kelsa_field.dart';
import '../../../shared/providers/app_providers.dart';

class VisitorTypeState {
  final List<KelsaFieldOption> options;
  final bool isLoading;
  final String? error;

  const VisitorTypeState({
    this.options = const [],
    this.isLoading = false,
    this.error,
  });

  VisitorTypeState copyWith({
    List<KelsaFieldOption>? options,
    bool? isLoading,
    String? error,
  }) {
    return VisitorTypeState(
      options: options ?? this.options,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class VisitorTypeNotifier extends StateNotifier<VisitorTypeState> {
  final Ref _ref;

  VisitorTypeNotifier(this._ref) : super(const VisitorTypeState()) {
    _loadOptions();
  }

  Future<void> _loadOptions() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final service = _ref.read(visitorMgmtServiceProvider);
      final fields = await service.getCustomFields();

      for (final field in fields) {
        if (field.identifier == 'visitor_type' && field.options != null) {
          state = state.copyWith(
            options: field.options!,
            isLoading: false,
          );
          return;
        }
      }

      state = state.copyWith(options: [], isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: userFriendlyError(e),
      );
    }
  }

  Future<void> reload() async => _loadOptions();
}

final visitorTypeProvider =
    StateNotifierProvider<VisitorTypeNotifier, VisitorTypeState>((ref) {
  return VisitorTypeNotifier(ref);
});
