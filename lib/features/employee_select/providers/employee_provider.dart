import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/app_exception.dart';
import '../../../data/models/kelsa_lead.dart';
import '../../../shared/providers/app_providers.dart';

class EmployeeOption {
  final int leadId;
  final String name;
  final String? email;
  final String? designation;

  const EmployeeOption({
    required this.leadId,
    required this.name,
    this.email,
    this.designation,
  });
}

class WhomToMeetState {
  final String query;
  final List<EmployeeOption> allEmployees;
  final List<EmployeeOption> filteredEmployees;
  final bool isLoading;
  final String? error;

  const WhomToMeetState({
    this.query = '',
    this.allEmployees = const [],
    this.filteredEmployees = const [],
    this.isLoading = false,
    this.error,
  });

  WhomToMeetState copyWith({
    String? query,
    List<EmployeeOption>? allEmployees,
    List<EmployeeOption>? filteredEmployees,
    bool? isLoading,
    String? error,
  }) {
    return WhomToMeetState(
      query: query ?? this.query,
      allEmployees: allEmployees ?? this.allEmployees,
      filteredEmployees: filteredEmployees ?? this.filteredEmployees,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class WhomToMeetNotifier extends StateNotifier<WhomToMeetState> {
  final Ref _ref;

  WhomToMeetNotifier(this._ref) : super(const WhomToMeetState()) {
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final service = _ref.read(employeeMasterServiceProvider);
      final employees = <EmployeeOption>[];
      int page = 1;

      while (true) {
        final response = await service.client.get<Map<String, dynamic>>(
          '/leads',
          queryParameters: {'page': page.toString(), 'per_page': '50'},
        );
        final data = response.data!;
        final leads = (data['leads'] as List?) ?? [];

        for (final leadJson in leads) {
          final lead = KelsaLead.fromJson(leadJson as Map<String, dynamic>);
          final name = lead.name ?? _extractName(lead);
          if (name != null && name.isNotEmpty && lead.id != null) {
            employees.add(EmployeeOption(
              leadId: lead.id!,
              name: name,
              email: _extractString(lead, ['employee_email', 'email']),
              designation: _extractString(lead, ['designation']),
            ));
          }
        }

        if (leads.length < 50) break;
        page++;
      }

      state = state.copyWith(
        allEmployees: employees,
        filteredEmployees: employees,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: userFriendlyError(e));
    }
  }

  String? _extractName(KelsaLead lead) {
    final cfv = lead.customFieldValues;
    final nameField = cfv['name_of_employee1'];
    if (nameField is Map && nameField['name'] != null) {
      return nameField['name'] as String;
    }
    for (final key in ['name', 'employee_name', 'name_of_employee']) {
      if (cfv[key] is String && (cfv[key] as String).isNotEmpty) {
        return cfv[key] as String;
      }
    }
    return null;
  }

  String? _extractString(KelsaLead lead, List<String> keys) {
    final cfv = lead.customFieldValues;
    for (final key in keys) {
      final val = cfv[key];
      if (val is String && val.isNotEmpty) return val;
    }
    return null;
  }

  void search(String query) {
    state = state.copyWith(query: query);
    if (query.isEmpty) {
      state = state.copyWith(filteredEmployees: state.allEmployees);
    } else {
      final lower = query.toLowerCase();
      state = state.copyWith(
        filteredEmployees: state.allEmployees
            .where((e) =>
                e.name.toLowerCase().contains(lower) ||
                (e.designation?.toLowerCase().contains(lower) ?? false))
            .toList(),
      );
    }
  }

  Future<void> reload() async {
    await _loadEmployees();
  }
}

final whomToMeetProvider =
    StateNotifierProvider<WhomToMeetNotifier, WhomToMeetState>((ref) {
  return WhomToMeetNotifier(ref);
});
