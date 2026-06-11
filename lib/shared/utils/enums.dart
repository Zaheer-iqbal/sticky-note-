enum RepeatType { once, daily, weekly, monthly }

enum NoteCategory { personal, study, work, health, finance, custom }

extension RepeatTypeExtension on RepeatType {
  String get label {
    switch (this) {
      case RepeatType.once:
        return 'Once';
      case RepeatType.daily:
        return 'Daily';
      case RepeatType.weekly:
        return 'Weekly';
      case RepeatType.monthly:
        return 'Monthly';
    }
  }
}

extension NoteCategoryExtension on NoteCategory {
  String get label {
    switch (this) {
      case NoteCategory.personal:
        return 'Personal';
      case NoteCategory.study:
        return 'Study';
      case NoteCategory.work:
        return 'Work';
      case NoteCategory.health:
        return 'Health';
      case NoteCategory.finance:
        return 'Finance';
      case NoteCategory.custom:
        return 'Custom';
    }
  }
}
