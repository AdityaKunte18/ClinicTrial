import 'package:flutter/material.dart';

import '../../../config/theme.dart';
import '../../../models/models.dart';

/// Shared helpers for workup status colors, icons, labels, and domain metadata.
/// Centralises logic previously duplicated across multiple screens.
class WorkupHelpers {
  WorkupHelpers._();

  // ── Status helpers ──────────────────────────────────────────────────

  static Color statusColor(WorkupStatus status) {
    switch (status) {
      case WorkupStatus.pending:
        return AppTheme.statusPending;
      case WorkupStatus.ordered:
        return AppTheme.statusOrdered;
      case WorkupStatus.sent:
        return AppTheme.statusSent;
      case WorkupStatus.resulted:
      case WorkupStatus.reviewed:
        return AppTheme.statusSent;
      case WorkupStatus.done:
        return AppTheme.statusDone;
      case WorkupStatus.notApplicable:
      case WorkupStatus.deferredOpd:
        return Colors.grey;
    }
  }

  static IconData statusIcon(WorkupStatus status) {
    switch (status) {
      case WorkupStatus.pending:
        return Icons.circle_outlined;
      case WorkupStatus.ordered:
        return Icons.schedule;
      case WorkupStatus.sent:
        return Icons.send;
      case WorkupStatus.resulted:
        return Icons.assignment_turned_in_outlined;
      case WorkupStatus.reviewed:
        return Icons.fact_check_outlined;
      case WorkupStatus.done:
        return Icons.check_circle;
      case WorkupStatus.notApplicable:
        return Icons.remove_circle_outline;
      case WorkupStatus.deferredOpd:
        return Icons.event_note_outlined;
    }
  }

  static String statusLabel(WorkupStatus status) {
    switch (status) {
      case WorkupStatus.pending:
        return 'Pending';
      case WorkupStatus.ordered:
        return 'Ordered';
      case WorkupStatus.sent:
        return 'Sent';
      case WorkupStatus.resulted:
        return 'Resulted';
      case WorkupStatus.reviewed:
        return 'Reviewed';
      case WorkupStatus.done:
        return 'Done';
      case WorkupStatus.notApplicable:
        return 'N/A';
      case WorkupStatus.deferredOpd:
        return 'Deferred OPD';
    }
  }

  // ── Day helpers ─────────────────────────────────────────────────────

  static Color dayColor(int day) {
    switch (day) {
      case 1:
        return AppTheme.day1;
      case 2:
        return AppTheme.day2;
      case 3:
        return AppTheme.day3;
      case 4:
        return AppTheme.day4;
      default:
        return AppTheme.day5;
    }
  }

  // ── Domain helpers ──────────────────────────────────────────────────

  static IconData domainIcon(WorkupDomain domain) {
    switch (domain) {
      case WorkupDomain.history:
        return Icons.history_edu;
      case WorkupDomain.examination:
        return Icons.medical_services_outlined;
      case WorkupDomain.blood:
        return Icons.bloodtype_outlined;
      case WorkupDomain.radiology:
        return Icons.image_outlined;
      case WorkupDomain.treatment:
        return Icons.medication_outlined;
      case WorkupDomain.referral:
        return Icons.group_outlined;
      case WorkupDomain.schemePrereq:
        return Icons.card_membership_outlined;
      case WorkupDomain.discharge:
        return Icons.exit_to_app;
    }
  }

  static String domainLabel(WorkupDomain domain) {
    switch (domain) {
      case WorkupDomain.history:
        return 'History';
      case WorkupDomain.examination:
        return 'Examination';
      case WorkupDomain.blood:
        return 'Blood Investigations';
      case WorkupDomain.radiology:
        return 'Radiology';
      case WorkupDomain.treatment:
        return 'Treatment Orders';
      case WorkupDomain.referral:
        return 'Referrals';
      case WorkupDomain.schemePrereq:
        return 'Scheme Prerequisites';
      case WorkupDomain.discharge:
        return 'Discharge Criteria';
    }
  }

  /// Short label used in tab headers.
  static String domainTabLabel(WorkupDomain domain) {
    switch (domain) {
      case WorkupDomain.history:
        return 'History';
      case WorkupDomain.examination:
        return 'Examination';
      case WorkupDomain.blood:
        return 'Bloods';
      case WorkupDomain.radiology:
        return 'Radiology';
      case WorkupDomain.treatment:
        return 'Treatment';
      case WorkupDomain.referral:
        return 'Referrals';
      case WorkupDomain.schemePrereq:
        return 'Scheme';
      case WorkupDomain.discharge:
        return 'Discharge';
    }
  }

  // ── Progress helpers ────────────────────────────────────────────────

  /// Returns red (<33%), amber (<67%), or green (≥67%) based on progress.
  static Color progressColor(double percent) {
    if (percent < 0.33) return AppTheme.statusOverdue;
    if (percent < 0.67) return AppTheme.warning;
    return AppTheme.statusDone;
  }

  // ── Completed status check ──────────────────────────────────────────

  static const completedStatuses = {
    WorkupStatus.done,
    WorkupStatus.notApplicable,
  };

  static bool isCompleted(WorkupStatus status) =>
      completedStatuses.contains(status);

  // ── Clinical domains (6 tabs, excludes schemePrereq and discharge) ──

  static const clinicalDomains = [
    WorkupDomain.history,
    WorkupDomain.examination,
    WorkupDomain.blood,
    WorkupDomain.radiology,
    WorkupDomain.treatment,
    WorkupDomain.referral,
  ];
}
