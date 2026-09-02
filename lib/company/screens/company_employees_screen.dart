import 'package:flutter/material.dart';
import '../../common/theme/app_colors.dart';
import '../models/managed_employee.dart';
import '../repositories/company_repositories.dart';
import 'company_employee_form_screen.dart';

/// 従業員管理タブ。TimeFace2の`Company\EmployeeController@index`に対応する一覧。
class CompanyEmployeesScreen extends StatefulWidget {
  const CompanyEmployeesScreen({super.key, required this.repositories});

  final CompanyRepositories repositories;

  @override
  State<CompanyEmployeesScreen> createState() => _CompanyEmployeesScreenState();
}

class _CompanyEmployeesScreenState extends State<CompanyEmployeesScreen> {
  List<ManagedEmployee>? _items;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await widget.repositories.employee.fetchAll();
    if (!mounted) return;
    setState(() => _items = items);
  }

  Future<void> _openForm({ManagedEmployee? employee}) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CompanyEmployeeFormScreen(repositories: widget.repositories, employee: employee),
      ),
    );
    if (result == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: items == null
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? const Center(child: Text('従業員が登録されていません', style: TextStyle(fontSize: 13.5, color: AppColors.textSubtle)))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 96),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final employee = items[index];
                    return Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        onTap: () => _openForm(employee: employee),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(employee.fullName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${employee.officeName} / ${employee.departmentName.isEmpty ? "未所属" : employee.departmentName}',
                                      style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(color: AppColors.badgeNeutralBg, borderRadius: BorderRadius.circular(999)),
                                child: Text(employee.enrollmentStatusLabel, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'company-employees-fab',
        onPressed: () => _openForm(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}
