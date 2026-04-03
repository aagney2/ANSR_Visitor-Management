import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../shared/widgets/branded_header.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/error_banner.dart';
import '../../../features/visitor_checkin/providers/checkin_provider.dart';
import '../providers/employee_provider.dart';

class EmployeeSelectScreen extends ConsumerStatefulWidget {
  const EmployeeSelectScreen({super.key});

  @override
  ConsumerState<EmployeeSelectScreen> createState() =>
      _EmployeeSelectScreenState();
}

class _EmployeeSelectScreenState extends ConsumerState<EmployeeSelectScreen> {
  final _searchController = TextEditingController();
  EmployeeOption? _selected;

  @override
  void initState() {
    super.initState();
    // Reset filter so the full employee list shows on each visit
    Future.microtask(() {
      ref.read(whomToMeetProvider.notifier).search('');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final whomState = ref.watch(whomToMeetProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const BrandedHeader(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              const SectionHeader(
                title: 'Select the person you\'re meeting',
                subtitle: 'Search by name or designation',
              ),
              if (whomState.error != null)
                ErrorBanner(
                  message: whomState.error!,
                  onRetry: () =>
                      ref.read(whomToMeetProvider.notifier).reload(),
                ),
              TextFormField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search employees...',
                  prefixIcon: Icon(
                    Icons.search,
                    color: theme.colorScheme.primary,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            ref
                                .read(whomToMeetProvider.notifier)
                                .search('');
                            setState(() {});
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  ref.read(whomToMeetProvider.notifier).search(value);
                  setState(() {});
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: whomState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : whomState.filteredEmployees.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.person_search_outlined,
                                  size: 64,
                                  color: Colors.grey[300],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  whomState.allEmployees.isEmpty
                                      ? 'No employees found'
                                      : 'No matches found',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: whomState.filteredEmployees.length,
                            itemBuilder: (context, index) {
                              final emp = whomState.filteredEmployees[index];
                              final isSelected =
                                  _selected?.leadId == emp.leadId;
                              return _EmployeeTile(
                                employee: emp,
                                isSelected: isSelected,
                                onTap: () =>
                                    setState(() => _selected = emp),
                              )
                                  .animate()
                                  .fadeIn(
                                    delay: Duration(
                                        milliseconds:
                                            40 * index.clamp(0, 10)),
                                    duration: 250.ms,
                                  );
                            },
                          ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selected != null
                      ? () {
                          ref
                              .read(checkinProvider.notifier)
                              .selectWhomToMeet(_selected!);
                          final state = ref.read(checkinProvider);
                          if (state.detailsEdited) {
                            ref
                                .read(checkinProvider.notifier)
                                .proceedToReview();
                            context.go('/review');
                          } else {
                            context.go('/details');
                          }
                        }
                      : null,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_forward_rounded, size: 20),
                      SizedBox(width: 8),
                      Text('Continue'),
                    ],
                  ),
                ),
              ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => context.go('/purpose'),
                  icon: Icon(Icons.chevron_left, color: theme.colorScheme.primary, size: 20),
                  label: Text('Back', style: TextStyle(color: theme.colorScheme.primary, fontSize: 15, fontWeight: FontWeight.w500)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.3))),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmployeeTile extends StatelessWidget {
  final EmployeeOption employee;
  final bool isSelected;
  final VoidCallback onTap;

  const _EmployeeTile({
    required this.employee,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isSelected
            ? theme.colorScheme.primary.withValues(alpha: 0.08)
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : const Color(0xFFF0F0F0),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary.withValues(alpha: 0.15)
                        : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      employee.name.isNotEmpty
                          ? employee.name[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : const Color(0xFF757575),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employee.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: const Color(0xFF212121),
                        ),
                      ),
                      if (employee.designation != null &&
                          employee.designation!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          employee.designation!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF9E9E9E),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: theme.colorScheme.primary,
                    size: 22,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
