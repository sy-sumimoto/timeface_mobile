import 'package:flutter/material.dart';
import '../../common/theme/app_colors.dart';
import '../models/department.dart';
import '../models/office.dart';
import '../repositories/company_repositories.dart';
import 'company_department_form_screen.dart';
import 'company_office_form_screen.dart';

/// 事業所タブ。「事業所」「部署」の2つを内部タブで切り替える
/// (TimeFace2側は`offices`/`departments`という別々の管理画面だが、
/// どちらも小規模な一覧+フォームのためモバイル版では1タブにまとめている)。
class CompanyOfficesDepartmentsScreen extends StatefulWidget {
  const CompanyOfficesDepartmentsScreen({super.key, required this.repositories});

  final CompanyRepositories repositories;

  @override
  State<CompanyOfficesDepartmentsScreen> createState() => _CompanyOfficesDepartmentsScreenState();
}

class _CompanyOfficesDepartmentsScreenState extends State<CompanyOfficesDepartmentsScreen> {
  List<Office>? _offices;
  List<Department>? _departments;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final offices = await widget.repositories.office.fetchAll();
    final departments = await widget.repositories.department.fetchAll();
    if (!mounted) return;
    setState(() {
      _offices = offices;
      _departments = departments;
    });
  }

  Future<void> _openOfficeForm({Office? office}) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => CompanyOfficeFormScreen(repositories: widget.repositories, office: office)),
    );
    if (result == true) _load();
  }

  Future<void> _openDepartmentForm({Department? department}) async {
    final offices = _offices ?? const [];
    if (offices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('先に事業所を登録してください')));
      return;
    }
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CompanyDepartmentFormScreen(repositories: widget.repositories, offices: offices, department: department),
      ),
    );
    if (result == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    final offices = _offices;
    final departments = _departments;
    final loading = offices == null || departments == null;

    return DefaultTabController(
      length: 2,
      child: Stack(
        children: [
          Column(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
                child: const TabBar(
                  isScrollable: true,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textMuted,
                  indicatorColor: AppColors.primary,
                  labelStyle: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                  tabs: [
                    Tab(text: '事業所'),
                    Tab(text: '部署'),
                  ],
                ),
              ),
              Expanded(
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : TabBarView(
                        children: [
                          _OfficeList(offices: offices, onTap: (o) => _openOfficeForm(office: o)),
                          _DepartmentList(departments: departments, onTap: (d) => _openDepartmentForm(department: d)),
                        ],
                      ),
              ),
            ],
          ),
          Positioned(
            right: 20,
            bottom: 20,
            child: Builder(
              builder: (context) {
                final activeTab = DefaultTabController.of(context);
                return AnimatedBuilder(
                  animation: activeTab,
                  builder: (context, _) => FloatingActionButton(
                    heroTag: 'company-offices-departments-fab',
                    onPressed: activeTab.index == 0 ? () => _openOfficeForm() : () => _openDepartmentForm(),
                    backgroundColor: AppColors.primary,
                    child: const Icon(Icons.add_rounded, color: Colors.white),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OfficeList extends StatelessWidget {
  const _OfficeList({required this.offices, required this.onTap});

  final List<Office> offices;
  final ValueChanged<Office> onTap;

  @override
  Widget build(BuildContext context) {
    if (offices.isEmpty) {
      return const Center(child: Text('事業所が登録されていません', style: TextStyle(fontSize: 13.5, color: AppColors.textSubtle)));
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      itemCount: offices.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final office = offices[index];
        return _EntityTile(title: office.name, subtitle: office.address, onTap: () => onTap(office));
      },
    );
  }
}

class _DepartmentList extends StatelessWidget {
  const _DepartmentList({required this.departments, required this.onTap});

  final List<Department> departments;
  final ValueChanged<Department> onTap;

  @override
  Widget build(BuildContext context) {
    if (departments.isEmpty) {
      return const Center(child: Text('部署が登録されていません', style: TextStyle(fontSize: 13.5, color: AppColors.textSubtle)));
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      itemCount: departments.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final department = departments[index];
        return _EntityTile(title: department.name, subtitle: department.officeName, onTap: () => onTap(department));
      },
    );
  }
}

/// 事業所/部署共通の一覧行(名称+補足情報)。
class _EntityTile extends StatelessWidget {
  const _EntityTile({required this.title, required this.subtitle, required this.onTap});

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
            ],
          ),
        ),
      ),
    );
  }
}
