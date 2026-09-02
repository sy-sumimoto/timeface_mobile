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

/// 有給休暇の新規申請画面。開始日・区分・取得日数を入力すると、
/// TimeFace2側(PaidHolidayController@calculateEndDate)に終了日を計算させ、
/// 送信時は同じくサーバー側(@store)へ申請を保存する。
class PaidHolidayCreateScreen extends StatefulWidget {
  const PaidHolidayCreateScreen({super.key, required this.repository});

  final PaidHolidayRepository repository;

  @override
  State<PaidHolidayCreateScreen> createState() => _PaidHolidayCreateScreenState();
}

class _PaidHolidayCreateScreenState extends State<PaidHolidayCreateScreen> {
  final _noteController = TextEditingController();
  final _usedDaysController = TextEditingController();

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
  void dispose() {
    _noteController.dispose();
    _usedDaysController.dispose();
    super.dispose();
  }

  double? get _usedDays => double.tryParse(_usedDaysController.text);

  /// 全休/半休の切り替え。半休は取得日数が常に0.5固定になるため自動入力し、
  /// 全休に戻したときは古い0.5表示を消してユーザーに入力させる。
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

  /// 開始日・区分・取得日数が揃うたびにサーバーへ終了日の計算を依頼する。
  /// この結果(_computedEndDate)は改変せずそのまま送信データに使う
  /// (PaidHolidayRepository.calculateEndDateのドキュメント参照。サーバー側で突合される)。
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

  /// TimeFace2側のバリデーションエラー(フィールド名付き)を各入力欄に振り分ける。
  /// どのフィールドにも該当しない場合は一般エラーとしてフォーム下部に表示する。
  void _applyErrors(ApiException e) {
    _startError = e.errorFor('paid_holiday_start_date');
    _usedDaysError = e.errorFor('used_paid_holidays');
    _endDateError = e.errorFor('paid_holiday_end_date');
    _generalError = e.errorFor('failed') ??
        (_startError == null && _usedDaysError == null && _endDateError == null ? e.message : null);
  }

  /// 入力チェック → (未計算なら)終了日再計算 → 申請送信、の順で実行する。
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
      await widget.repository.submitCreate(
        startDate: _startDate!,
        computedEndDate: _computedEndDate!,
        type: _type,
        usedDays: _usedDays!,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('有給休暇を申請しました')),
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
      appBar: AppBackBar(title: '有給休暇を申請', onBack: () => Navigator.of(context).pop()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const SizedBox(height: 8),
            const Text('承認者(直属の上長)に自動的に通知されます。残日数が不足する期間は申請できません。', style: TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
          ],
        ),
      ),
      bottomNavigationBar: StickyFormFooter(
        buttonLabel: _submitting ? '送信中…' : '申請する',
        linkLabel: 'キャンセルして一覧に戻る',
        onSubmit: _submitting ? null : _handleSubmit,
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }
}
