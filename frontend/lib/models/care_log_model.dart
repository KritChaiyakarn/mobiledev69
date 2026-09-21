class CareLog {
  final int? id;
  final int pet;
  final String activityType;
  final String title;
  final String? notes;
  final String logDate;
  final bool isCompleted;

  CareLog({
    this.id,
    required this.pet,
    required this.activityType,
    required this.title,
    this.notes,
    required this.logDate,
    this.isCompleted = false,
  });

  factory CareLog.fromJson(Map<String, dynamic> json) {
    return CareLog(
      id: json['id'],
      pet: json['pet'],
      activityType: json['activity_type'] ?? '',
      title: json['title'] ?? '',
      notes: json['notes'],
      logDate: json['log_date'] ?? '',
      isCompleted: json['is_completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'pet': pet,
      'activity_type': activityType,
      'title': title,
      'notes': notes,
      'log_date': logDate,
      'is_completed': isCompleted,
    };
  }
}