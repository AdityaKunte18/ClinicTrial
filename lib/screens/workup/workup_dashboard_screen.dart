import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/models.dart';
import '../../providers/workup_providers.dart';
import 'tabs/discharge_tab.dart';
import 'tabs/domain_tab.dart';
import 'tabs/overview_tab.dart';
import 'tabs/timeline_tab.dart';
import 'widgets/persistent_bottom_bar.dart';
import 'widgets/workup_helpers.dart';

class WorkupDashboardScreen extends ConsumerStatefulWidget {
  final String admissionId;
  final String? initialTab;

  const WorkupDashboardScreen({
    super.key,
    required this.admissionId,
    this.initialTab,
  });

  @override
  ConsumerState<WorkupDashboardScreen> createState() =>
      _WorkupDashboardScreenState();
}

class _WorkupDashboardScreenState
    extends ConsumerState<WorkupDashboardScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  // Tab index constants
  static const kOverview = 0;
  static const kHistory = 1;
  static const kExam = 2;
  static const kBlood = 3;
  static const kRadiology = 4;
  static const kTreatment = 5;
  static const kReferral = 6;
  static const kTimeline = 7;
  static const kDischarge = 8;

  static const _tabCount = 9;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _tabCount,
      vsync: this,
      initialIndex: _resolveInitialTab(),
    );
  }

  int _resolveInitialTab() {
    switch (widget.initialTab) {
      case 'overview':
        return kOverview;
      case 'history':
        return kHistory;
      case 'examination':
        return kExam;
      case 'blood':
        return kBlood;
      case 'radiology':
        return kRadiology;
      case 'treatment':
        return kTreatment;
      case 'referral':
        return kReferral;
      case 'timeline':
        return kTimeline;
      case 'discharge':
        return kDischarge;
      default:
        return kOverview;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveDayAsync =
        ref.watch(effectiveDayProvider(widget.admissionId));
    final progressAsync =
        ref.watch(workupProgressProvider(widget.admissionId));
    final syndromeNamesAsync =
        ref.watch(admissionSyndromeNamesProvider(widget.admissionId));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ClinicalPilot',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            syndromeNamesAsync.when(
              loading: () => Text('Loading...',
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant)),
              error: (_, _) => const SizedBox.shrink(),
              data: (names) => Text(
                names.isNotEmpty
                    ? '${names.join(" · ")} Workup · Interactive Demo'
                    : 'Workup Dashboard',
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          // Day & progress info
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                effectiveDayAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                  data: (day) => Text(
                    'Day $day of 5',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                progressAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                  data: (progress) {
                    final pct = (progress.overallPercent * 100).round();
                    return Text(
                      '$pct%',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: WorkupHelpers.progressColor(
                            progress.overallPercent),
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // Handoff note action
          IconButton(
            icon: const Icon(Icons.note_alt_outlined),
            tooltip: 'Handoff Note',
            onPressed: () =>
                context.push('/handoff/${widget.admissionId}'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_outlined, size: 20), text: 'Overview'),
            Tab(icon: Icon(Icons.history_edu, size: 20), text: 'History'),
            Tab(icon: Icon(Icons.medical_services_outlined, size: 20), text: 'Examination'),
            Tab(icon: Icon(Icons.bloodtype_outlined, size: 20), text: 'Bloods'),
            Tab(icon: Icon(Icons.image_outlined, size: 20), text: 'Radiology'),
            Tab(icon: Icon(Icons.medication_outlined, size: 20), text: 'Treatment'),
            Tab(icon: Icon(Icons.group_outlined, size: 20), text: 'Referrals'),
            Tab(icon: Icon(Icons.calendar_month, size: 20), text: 'Timeline'),
            Tab(icon: Icon(Icons.flag_outlined, size: 20), text: 'Discharge'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                OverviewTab(
                  admissionId: widget.admissionId,
                  tabController: _tabController,
                ),
                DomainTab(
                  admissionId: widget.admissionId,
                  domain: WorkupDomain.history,
                ),
                DomainTab(
                  admissionId: widget.admissionId,
                  domain: WorkupDomain.examination,
                ),
                DomainTab(
                  admissionId: widget.admissionId,
                  domain: WorkupDomain.blood,
                ),
                DomainTab(
                  admissionId: widget.admissionId,
                  domain: WorkupDomain.radiology,
                ),
                DomainTab(
                  admissionId: widget.admissionId,
                  domain: WorkupDomain.treatment,
                ),
                DomainTab(
                  admissionId: widget.admissionId,
                  domain: WorkupDomain.referral,
                ),
                TimelineTab(admissionId: widget.admissionId),
                DischargeTab(admissionId: widget.admissionId),
              ],
            ),
          ),
          PersistentBottomBar(admissionId: widget.admissionId),
        ],
      ),
    );
  }
}
