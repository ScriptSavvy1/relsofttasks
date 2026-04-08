import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Task status values matching database CHECK constraint
enum TaskStatus {
  pending('pending', 'Pending'),
  inProgress('in_progress', 'In Progress'),
  blocked('blocked', 'Blocked'),
  completed('completed', 'Completed'),
  cancelled('cancelled', 'Cancelled');

  const TaskStatus(this.value, this.displayName);

  final String value;
  final String displayName;

  static TaskStatus fromString(String value) {
    return TaskStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => TaskStatus.pending,
    );
  }

  Color get color {
    switch (this) {
      case pending:
        return AppColors.statusPending;
      case inProgress:
        return AppColors.statusInProgress;
      case blocked:
        return AppColors.statusBlocked;
      case completed:
        return AppColors.statusCompleted;
      case cancelled:
        return AppColors.statusCancelled;
    }
  }

  IconData get icon {
    switch (this) {
      case pending:
        return Icons.schedule_outlined;
      case inProgress:
        return Icons.play_circle_outline;
      case blocked:
        return Icons.block_outlined;
      case completed:
        return Icons.check_circle_outline;
      case cancelled:
        return Icons.cancel_outlined;
    }
  }

  bool get isActive => this == pending || this == inProgress || this == blocked;
  bool get isTerminal => this == completed || this == cancelled;
}

/// Task priority values matching database CHECK constraint
enum TaskPriority {
  low('low', 'Low'),
  medium('medium', 'Medium'),
  high('high', 'High'),
  urgent('urgent', 'Urgent');

  const TaskPriority(this.value, this.displayName);

  final String value;
  final String displayName;

  static TaskPriority fromString(String value) {
    return TaskPriority.values.firstWhere(
      (p) => p.value == value,
      orElse: () => TaskPriority.medium,
    );
  }

  Color get color {
    switch (this) {
      case low:
        return AppColors.priorityLow;
      case medium:
        return AppColors.priorityMedium;
      case high:
        return AppColors.priorityHigh;
      case urgent:
        return AppColors.priorityUrgent;
    }
  }

  IconData get icon {
    switch (this) {
      case low:
        return Icons.arrow_downward_rounded;
      case medium:
        return Icons.remove_rounded;
      case high:
        return Icons.arrow_upward_rounded;
      case urgent:
        return Icons.priority_high_rounded;
    }
  }

  int get sortOrder {
    switch (this) {
      case urgent:
        return 4;
      case high:
        return 3;
      case medium:
        return 2;
      case low:
        return 1;
    }
  }
}

/// Meeting status values
enum MeetingStatus {
  scheduled('scheduled', 'Scheduled'),
  inProgress('in_progress', 'In Progress'),
  completed('completed', 'Completed'),
  cancelled('cancelled', 'Cancelled');

  const MeetingStatus(this.value, this.displayName);

  final String value;
  final String displayName;

  static MeetingStatus fromString(String value) {
    return MeetingStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => MeetingStatus.scheduled,
    );
  }

  Color get color {
    switch (this) {
      case scheduled:
        return AppColors.info;
      case inProgress:
        return AppColors.statusInProgress;
      case completed:
        return AppColors.statusCompleted;
      case cancelled:
        return AppColors.statusCancelled;
    }
  }

  IconData get icon {
    switch (this) {
      case scheduled:
        return Icons.event_outlined;
      case inProgress:
        return Icons.videocam_outlined;
      case completed:
        return Icons.event_available_outlined;
      case cancelled:
        return Icons.event_busy_outlined;
    }
  }
}
