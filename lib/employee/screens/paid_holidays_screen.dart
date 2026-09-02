import 'package:flutter/material.dart';

import '../models/paid_holiday.dart';
import '../repositories/paid_holiday_repository.dart';
import '../../common/theme/app_colors.dart';
import '../../common/widgets/badge.dart';
import '../../common/widgets/kpi_card.dart';
import '../../common/widgets/request_card.dart';
import 'paid_holiday_create_screen.dart';
import 'paid_holiday_edit_screen.dart';

/// 有給休暇タブ。残日数サマリー・「申請中」「処理済み」の2タブ一覧・新規申請FABをまとめる。
/// 一覧はTimeFace2の `GET /api/mobile/paid-holidays` が返す pending/processed を
/// そのまま2タブとして表示する。
class PaidHolidaysScreen extends StatefulWidget {
  const PaidHolidaysScreen({super.key, required this.repository});

  final PaidHolidayRepository repository;

  @override
  State<PaidHolidaysScreen> createState() => _PaidHolidaysScreenState();
}

class _PaidHolidaysScreenState extends State<PaidHolidaysScreen> {
  PaidHolidaySummary? _summary;
  List<PaidHolidayRequest>? _pending;
  List<PaidHolidayRequest>? _processed;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final summary = await widget.repository.fetchSummary();
    final pending = await widget.repository.fetchPending();
    final processed = await widget.repository.fetchProcessed();
    if (!mounted) return;
    setState(() {
      _summary = summary;
      _pending = pending;
      _processed = processed;
    });
  }

  /// 新規申請画面を開く。申請完了(pop(true))で戻ってきたら一覧を再取得する。
  Future<void> _openCreate() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PaidHolidayCreateScreen(repository: widget.repository),
      ),
    );
    if (result == true) _load();
  }

  /// 差し戻された申請の再申請画面を開く。戻り値の扱いは[_openCreate]と同じ。
  Future<void> _openEdit(PaidHolidayRequest request) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PaidHolidayEditScreen(
          repository: widget.repository,
          request: request,
        ),
      ),
    );
    if (result == true) _load();
  }

  AppBadgeVariant _statusVariant(PaidHolidayStatus status) {
    switch (status) {
      case PaidHolidayStatus.pending:
        return AppBadgeVariant.warning;
      case PaidHolidayStatus.rejected:
        return AppBadgeVariant.danger;
      case PaidHolidayStatus.approved:
        return AppBadgeVariant.active;
    }
  }

  String _statusLabel(PaidHolidayStatus status) {
    switch (status) {
      case PaidHolidayStatus.pending:
        return '承認待ち';
      case PaidHolidayStatus.rejected:
        return '差し戻し';
      case PaidHolidayStatus.approved:
        return '承認済み';
    }
  }

  @override
  Widget build(BuildContext context) {
    final summary = _summary;
    final pending = _pending;
    final processed = _processed;
    final loading = summary == null || pending == null || processed == null;

    return DefaultTabController(
      length: 2,
      child: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: loading
                    ? const SizedBox(
                        height: 100,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.05,
                        children: [
                          KpiCard(
                            compact: true,
                            label: '残日数',
                            value: summary.remainingDays,
                            delta: '直近付与11日',
                            icon: Icons.wb_sunny_rounded,
                            iconColor: KpiIconColor.green,
                          ),
                          KpiCard(
                            compact: true,
                            label: '消化予定',
                            value: summary.plannedDays,
                            delta: '承認済み未取得分',
                            icon: Icons.calendar_month_rounded,
                            iconColor: KpiIconColor.blue,
                          ),
                          KpiCard(
                            compact: true,
                            label: '次回付与日',
                            value: summary.nextGrantDate,
                            delta: ' ',
                            icon: Icons.event_rounded,
                            iconColor: KpiIconColor.purple,
                          ),
                        ],
                      ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: const TabBar(
                  isScrollable: true,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textMuted,
                  indicatorColor: AppColors.primary,
                  labelStyle: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: [
                    Tab(text: '申請中'),
                    Tab(text: '処理済み'),
                  ],
                ),
              ),
              Expanded(
                child: loading
                    ? const SizedBox()
                    : TabBarView(
                        children: [
                          pending.isEmpty
                              ? const Center(
                                  child: Text(
                                    '申請中の有給休暇はありません',
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      color: AppColors.textSubtle,
                                    ),
                                  ),
                                )
                              : ListView(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    16,
                                    16,
                                    96,
                                  ),
                                  children: [
                                    for (final request in pending) ...[
                                      RequestCard(
                                        period: request.periodLabel,
                                        type: request.typeLabel,
                                        days: request.daysLabel,
                                        statusLabel: _statusLabel(
                                          request.status,
                                        ),
                                        statusVariant: _statusVariant(
                                          request.status,
                                        ),
                                        metaLines: [
                                          '申請日 ${request.appliedDate}',
                                        ],
                                        noteText: request.rejectionNote,
                                        footerActionLabel:
                                            request.status ==
                                                PaidHolidayStatus.rejected
                                            ? '修正して再申請'
                                            : null,
                                        onFooterActionTap:
                                            request.status ==
                                                PaidHolidayStatus.rejected
                                            ? () => _openEdit(request)
                                            : null,
                                      ),
                                      const SizedBox(height: 12),
                                    ],
                                  ],
                                ),
                          processed.isEmpty
                              ? const Center(
                                  child: Text(
                                    '処理済みの有給休暇はありません',
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      color: AppColors.textSubtle,
                                    ),
                                  ),
                                )
                              : ListView(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    16,
                                    16,
                                    96,
                                  ),
                                  children: [
                                    for (final request in processed) ...[
                                      RequestCard(
                                        period: request.periodLabel,
                                        type: request.typeLabel,
                                        days: request.daysLabel,
                                        statusLabel: _statusLabel(
                                          request.status,
                                        ),
                                        statusVariant: _statusVariant(
                                          request.status,
                                        ),
                                        metaLines: [
                                          if (request.approverInfo != null)
                                            '承認者 ${request.approverInfo}',
                                          if (request.processedAt != null)
                                            request.processedAt!,
                                        ],
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
          Positioned(
            right: 20,
            bottom: 20,
            child: FloatingActionButton(
              onPressed: _openCreate,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
