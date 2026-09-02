import 'package:flutter/material.dart';
import '../../common/theme/app_colors.dart';
import '../../common/widgets/badge.dart';
import '../../common/widgets/request_card.dart';
import '../models/paid_holiday_approval.dart';
import '../repositories/company_repositories.dart';

/// 有給休暇申請タブ。TimeFace2の`Company\PaidHolidayRequestController`に対応する。
/// 「未承認」タブでは承認/差し戻しをその場で行える(Web版は勤怠入力側の別画面での操作だが、
/// モバイル版は申請一覧から直接操作できるようにしている)。
class CompanyPaidHolidayRequestsScreen extends StatefulWidget {
  const CompanyPaidHolidayRequestsScreen({super.key, required this.repositories});

  final CompanyRepositories repositories;

  @override
  State<CompanyPaidHolidayRequestsScreen> createState() => _CompanyPaidHolidayRequestsScreenState();
}

class _CompanyPaidHolidayRequestsScreenState extends State<CompanyPaidHolidayRequestsScreen> {
  List<PaidHolidayApproval>? _pending;
  List<PaidHolidayApproval>? _processed;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final pending = await widget.repositories.paidHolidayApproval.fetchPending();
    final processed = await widget.repositories.paidHolidayApproval.fetchProcessed();
    if (!mounted) return;
    setState(() {
      _pending = pending;
      _processed = processed;
    });
  }

  Future<void> _approve(PaidHolidayApproval item) async {
    await widget.repositories.paidHolidayApproval.approve(item.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${item.employeeName}さんの申請を承認しました')));
    _load();
  }

  Future<void> _reject(PaidHolidayApproval item) async {
    final noteController = TextEditingController();
    final note = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('差し戻し理由'),
        content: TextField(
          controller: noteController,
          maxLines: 3,
          decoration: const InputDecoration(hintText: '差し戻す理由を入力してください'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('キャンセル')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(noteController.text.trim()),
            child: const Text('差し戻す'),
          ),
        ],
      ),
    );
    if (note == null || note.isEmpty) return;
    await widget.repositories.paidHolidayApproval.reject(item.id, note: note);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${item.employeeName}さんの申請を差し戻しました')));
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final pending = _pending;
    final processed = _processed;
    final loading = pending == null || processed == null;

    return DefaultTabController(
      length: 2,
      child: Column(
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
                Tab(text: '未承認'),
                Tab(text: '処理済み'),
              ],
            ),
          ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    children: [
                      pending.isEmpty
                          ? const Center(child: Text('未承認の申請はありません', style: TextStyle(fontSize: 13.5, color: AppColors.textSubtle)))
                          : ListView(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                              children: [
                                for (final item in pending) ...[
                                  RequestCard(
                                    period: '${item.employeeName}  ${item.periodLabel}',
                                    type: item.typeLabel,
                                    days: item.daysLabel,
                                    statusLabel: '承認待ち',
                                    statusVariant: AppBadgeVariant.warning,
                                    metaLines: ['申請日 ${item.appliedDate}'],
                                    footerActionLabel: '差し戻す',
                                    onFooterActionTap: () => _reject(item),
                                    trailingActionLabel: '承認する',
                                    onTrailingActionTap: () => _approve(item),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              ],
                            ),
                      processed.isEmpty
                          ? const Center(child: Text('処理済みの申請はありません', style: TextStyle(fontSize: 13.5, color: AppColors.textSubtle)))
                          : ListView(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                              children: [
                                for (final item in processed) ...[
                                  RequestCard(
                                    period: '${item.employeeName}  ${item.periodLabel}',
                                    type: item.typeLabel,
                                    days: item.daysLabel,
                                    statusLabel: item.status == PaidHolidayApprovalStatus.approved ? '承認済み' : '差し戻し',
                                    statusVariant: item.status == PaidHolidayApprovalStatus.approved
                                        ? AppBadgeVariant.active
                                        : AppBadgeVariant.danger,
                                    metaLines: ['申請日 ${item.appliedDate}'],
                                    noteText: item.note,
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              ],
                            ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
