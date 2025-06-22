import 'package:flutter/material.dart';
import '../models/report_model.dart';
import 'report_card.dart';

class ReportListView extends StatelessWidget {
  final List<Report> reports;
  final String emptyMessage;
  final Function(Report) onReportTap;
  final bool showVerificationActions;

  const ReportListView({
    Key? key,
    required this.reports,
    required this.emptyMessage,
    required this.onReportTap,
    this.showVerificationActions = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (reports.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Text(
            emptyMessage,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        return ReportCard(
          report: reports[index],
          onTap: () => onReportTap(reports[index]),
          showVerificationActions: showVerificationActions,
        );
      },
    );
  }
}