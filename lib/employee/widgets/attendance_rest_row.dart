import 'package:flutter/material.dart';

/// 勤怠一覧の休日1日分を表す簡易行(法定休日/所定休日のラベル表示)。
class AttendanceRestRow extends StatelessWidget {
  const AttendanceRestRow({super.key, required this.date, required this.label});

  final String date;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(date, style: const TextStyle(fontSize: 12.5, color: Color(0xFFB0B4BF))),
          Text(label, style: const TextStyle(fontSize: 12.5, color: Color(0xFFB0B4BF))),
        ],
      ),
    );
  }
}
