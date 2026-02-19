import 'package:uuid/uuid.dart';
import '../models/models.dart';

/// Converts a syndrome's JSONB template into a list of WorkupItems.
List<WorkupItem> generateWorkupItems({
  required String admissionId,
  required SyndromeProtocol protocol,
}) {
  final template = protocol.baseTemplate;
  final items = <WorkupItem>[];
  int sortOrder = 0;

  const domainMapping = {
    'history': WorkupDomain.history,
    'examination': WorkupDomain.examination,
    'blood_investigations': WorkupDomain.blood,
    'radiology': WorkupDomain.radiology,
    'treatment_orders': WorkupDomain.treatment,
    'referrals': WorkupDomain.referral,
    'scheme_packages': WorkupDomain.schemePrereq,
    'discharge_criteria': WorkupDomain.discharge,
  };

  final uuid = Uuid();

  for (final entry in domainMapping.entries) {
    final templateItems = template[entry.key];
    if (templateItems is! List) continue;

    for (final ti in templateItems) {
      if (ti is! Map<String, dynamic>) continue;
      final text = ti['text'] as String?;
      if (text == null || text.isEmpty) continue;

      items.add(WorkupItem(
        id: uuid.v4(),
        admissionId: admissionId,
        syndromeId: protocol.id,
        domain: entry.value,
        itemText: text,
        isRequired: ti['required'] as bool? ?? false,
        isHardBlock: ti['hard_block'] as bool? ?? false,
        targetDay: ti['day'] as int?,
        status: WorkupStatus.pending,
        aiSuggested: false,
        reminderLevel: ReminderLevel.none,
        category: ti['category'] as String?,
        sortOrder: sortOrder++,
        templateItemId: ti['id'] as String?,
        originalTargetDay: ti['day'] as int?,
      ));
    }
  }
  return items;
}

/// Generates additional workup items from a classification rule's additional_workup map.
List<WorkupItem> generateClassificationItems({
  required String admissionId,
  required String syndromeId,
  required String classificationEventId,
  required Map<String, dynamic> additionalWorkup,
}) {
  const domainMapping = {
    'history': WorkupDomain.history,
    'examination': WorkupDomain.examination,
    'blood_investigations': WorkupDomain.blood,
    'radiology': WorkupDomain.radiology,
    'treatment_orders': WorkupDomain.treatment,
    'referrals': WorkupDomain.referral,
  };

  final uuid = Uuid();
  final items = <WorkupItem>[];
  int sortOrder = 1000; // High sort order so they appear after base items

  for (final entry in domainMapping.entries) {
    final templateItems = additionalWorkup[entry.key];
    if (templateItems is! List) continue;

    for (final ti in templateItems) {
      if (ti is! Map<String, dynamic>) continue;
      final text = ti['text'] as String?;
      if (text == null || text.isEmpty) continue;

      items.add(WorkupItem(
        id: uuid.v4(),
        admissionId: admissionId,
        syndromeId: syndromeId,
        domain: entry.value,
        itemText: text,
        isRequired: ti['required'] as bool? ?? false,
        isHardBlock: ti['hard_block'] as bool? ?? false,
        targetDay: ti['day'] as int?,
        status: WorkupStatus.pending,
        aiSuggested: true,
        reminderLevel: ReminderLevel.none,
        category: ti['category'] as String?,
        sortOrder: sortOrder++,
        templateItemId: ti['id'] as String?,
        originalTargetDay: ti['day'] as int?,
        classificationEventId: classificationEventId,
      ));
    }
  }
  return items;
}
