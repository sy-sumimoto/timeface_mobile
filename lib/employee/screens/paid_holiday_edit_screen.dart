import 'package:flutter/material.dart';
import '../../common/api/api_exception.dart';
import '../models/paid_holiday.dart';
import '../repositories/paid_holiday_repository.dart';
import '../../common/theme/app_colors.dart';
import '../../common/utils/date_format.dart';
import '../../common/widgets/app_back_bar.dart';
import '../../common/widgets/labeled_field.dart';
import '../../common/widgets/radio_option.dart';
import '../../common/widgets/sticky_form_footer.dart';

/// 差し戻された有給休暇申請の再申請画面。既存の申請内容(request)で
/// フォームを初期化する点以外は[PaidHolidayCreateScreen]と同じ流れで、
/// 送信時はTimeFace2の `POST /api/mobile/paid-holidays` にidを含めて呼ぶ
/// (新規申請と同一エンドポイント。idの有無で再申請かどうかをサーバー側が判定する)。
class PaidHolidayEditScreen extends StatefulWidget {
  const PaidHolidayEditScreen({super.key, required this.repository, required this.request});

  final PaidHolidayRepository repository;
  final PaidHolidayRequest request;

  @override
  State<PaidHolidayEditScreen> createState() => _PaidHolidayEditScreenState();
}

class _PaidHolidayEditScreenState extends State<PaidHolidayEditScreen> {
  late final TextEditingController _noteController;
  late final TextEditingController _usedDaysController;

  DateTime? _startDate;
  PaidHolidayType _type = PaidHolidayType.fullDay;
  String? _computedEndDate;

  String? _startError;
  String? _usedDaysError;
  String? _endDateError;
  String? _generalError;

  bool _calculating = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    // 差し戻された申請の内容をそのままフォーム初期値にする
    _startDate = widget.request.startDate;
    _type = widget.request.type;
    _usedDaysController = TextEditingController(text: _formatUsedDays(widget.request.usedDays));
    _noteController = TextEditingController(text: widget.request.note ?? '');
    _computedEndDate = formatSlashDate(widget.request.endDate);
  }

  @override
  void dispose() {
    _noteController.dispose();
    _usedDaysController.dispose();
    super.dispose();
  }

  String _formatUsedDays(double value) {
    return value == value.roundToDouble() ? value.toInt().toString() : value.toString();
  }

  double? get _usedDays => double.tryParse(_usedDaysController.text);

  /// [PaidHolidayCreateScreen._onTypeChanged]と同じロジック(半休は0.5固定)。
  void _onTypeChanged(PaidHolidayType type) {
    setState(() {
      _type = type;
      if (type == PaidHolidayType.halfDay) {
        _usedDaysController.text = '0.5';
      } else if (_usedDaysController.text == '0.5') {
        _usedDaysController.clear();
      }
    });
    _recalculate();
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: DateTime(now.year + 2),
    );
    if (picked == null) return;
    setState(() => _startDate = picked);
    _recalculate();
  }

  /// 入力変更のたびにサーバーへ終了日を再計算させる([PaidHolidayCreateScreen]と同じ)。
  Future<void> _recalculate() async {
    final startDate = _startDate;
    final usedDays = _usedDays;

    setState(() {
      _computedEndDate = null;
      _startError = null;
      _usedDaysError = null;
      _endDateError = null;
      _generalError = null;
    });

    if (startDate == null || usedDays == null || usedDays <= 0) return;

    setState(() => _calculating = true);
    try {
      final endDate = await widget.repository.calculateEndDate(
        startDate: startDate,
        type: _type,
        usedDays: usedDays,
      );
      if (!mounted) return;
      setState(() => _computedEndDate = endDate);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _applyErrors(e));
    } finally {
      if (mounted) setState(() => _calculating = false);
    }
  }

  void _applyErrors(ApiException e) {
    _startError = e.errorFor('paid_holiday_start_date');
    _usedDaysError = e.errorFor('used_paid_holidays');
    _endDateError = e.errorFor('paid_holiday_end_date');
    _generalError = e.errorFor('failed') ??
        (_startError == null && _usedDaysError == null && _endDateError == null ? e.message : null);
  }

  /// 入力チェック後、TimeFace2側(@update)へ再申請を送信する。
  Future<void> _handleSubmit() async {
    if (_startDate == null) {
      setState(() => _startError = '有給開始日を選択してください');
      return;
    }
    if (_usedDays == null || _usedDays! <= 0) {
      setState(() => _usedDaysError = '取得日数を入力してください');
      return;
    }
    if (_computedEndDate == null) {
      await _recalculate();
      if (_computedEndDate == null) return;
    }

    setState(() => _submitting = true);
    try {
      await widget.repository.submitEdit(
        id: widget.request.id,
        startDate: _startDate!,
        computedEndDate: _computedEndDate!,
        type: _type,
        usedDays: _usedDays!,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('有給休暇を再申請しました')),
      );
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      setState(() => _applyErrors(e));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bodyBg,
      appBar: AppBackBar(title: '修正して再申請', onBack: () => Navigator.of(context).pop()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.request.rejectionNote != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(color: AppColors.badgeDangerBg, borderRadius: BorderRadius.circular(10)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 16, color: Color(0xFFB42318)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '差し戻し理由: ${widget.request.rejectionNote}',
                        style: const TextStyle(fontSize: 12.5, color: Color(0xFFB42318), height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            const AppLabel(text: '休暇区分', required: true),
            Row(
              children: [
                AppRadioOption(
                  label: '全休',
                  selected: _type == PaidHolidayType.fullDay,
                  onTap: () => _onTypeChanged(PaidHolidayType.fullDay),
                ),
                const SizedBox(width: 20),
                AppRadioOption(
                  label: '半休',
                  selected: _type == PaidHolidayType.halfDay,
                  onTap: () => _onTypeChanged(PaidHolidayType.halfDay),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppLabel(text: '有給開始日', required: true),
                      AppMockField(
                        text: _startDate != null ? formatIsoDate(_startDate!) : null,
                        hint: 'yyyy-mm-dd',
                        onTap: _pickStartDate,
                      ),
                      if (_startError != null) ...[
                        const SizedBox(height: 4),
                        Text(_startError!, style: const TextStyle(fontSize: 12, color: Color(0xFFDC2626))),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppLabel(text: '取得日数', required: true),
                      TextField(
                        controller: _usedDaysController,
                        enabled: _type == PaidHolidayType.fullDay,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _recalculate(),
                        decoration: appInputDecoration(hintText: '例)2'),
                      ),
                      if (_usedDaysError != null) ...[
                        const SizedBox(height: 4),
                        Text(_usedDaysError!, style: const TextStyle(fontSize: 12, color: Color(0xFFDC2626))),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const AppLabel(text: '終了日'),
            AppMockField(
              text: _computedEndDate != null ? formatIsoDate(parseSlashDate(_computedEndDate!)) : null,
              hint: _calculating ? '計算中…' : '開始日と取得日数を入力すると自動計算されます',
            ),
            if (_endDateError != null) ...[
              const SizedBox(height: 4),
              Text(_endDateError!, style: const TextStyle(fontSize: 12, color: Color(0xFFDC2626))),
            ],
            const SizedBox(height: 20),
            const AppLabel(text: '備考'),
            TextField(
              controller: _noteController,
              maxLines: 4,
              maxLength: 60,
              decoration: appInputDecoration(hintText: '申請理由など、必要があれば入力してください(60文字まで)'),
            ),
            if (_generalError != null) ...[
              const SizedBox(height: 4),
              Text(_generalError!, style: const TextStyle(fontSize: 12.5, color: Color(0xFFDC2626))),
            ],
          ],
        ),
      ),
      bottomNavigationBar: StickyFormFooter(
        buttonLabel: _submitting ? '送信中…' : '再申請する',
        linkLabel: 'キャンセルして一覧に戻る',
        onSubmit: _submitting ? null : _handleSubmit,
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }
}
