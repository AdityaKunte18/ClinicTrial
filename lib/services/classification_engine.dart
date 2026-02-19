import '../models/models.dart';

/// Rule-based classification engine.
/// Evaluates workup item results against classification rules
/// and returns matching rules sorted by priority.
class ClassificationEngine {
  /// Evaluates all classification rules against current workup item results.
  /// Returns matching rules sorted by priority (highest first).
  static List<ClassificationRule> evaluateResults({
    required List<WorkupItem> items,
    required List<ClassificationRule> rules,
  }) {
    final matches = <ClassificationRule>[];

    for (final rule in rules) {
      final allCriteriaMet = rule.criteria.every((criterion) {
        // Find the workup item matching this criterion's template item
        final item = items
            .where((i) => i.templateItemId == criterion.templateItemId)
            .where((i) => i.resultValue != null && i.resultValue!.isNotEmpty)
            .firstOrNull;

        if (item == null) return false;

        return _evaluateCriterion(item.resultValue!, criterion);
      });

      if (allCriteriaMet) {
        matches.add(rule);
      }
    }

    // Sort by priority descending (highest priority first)
    matches.sort((a, b) => b.priority.compareTo(a.priority));
    return matches;
  }

  static bool _evaluateCriterion(
      String resultValue, ClassificationCriterion criterion) {
    switch (criterion.operator) {
      case 'equals':
        return resultValue == criterion.value.toString();
      case 'contains':
        return resultValue
            .toLowerCase()
            .contains(criterion.value.toString().toLowerCase());
      case 'in':
        if (criterion.value is List) {
          return (criterion.value as List)
              .map((v) => v.toString())
              .contains(resultValue);
        }
        return false;
      default:
        return false;
    }
  }
}
