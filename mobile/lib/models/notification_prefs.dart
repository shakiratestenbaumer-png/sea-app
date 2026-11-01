class NotificationPrefs {
  const NotificationPrefs({
    this.enabled = true,
    this.dailyDigest = true,
    this.dailyDigestHour = 7,
    this.dailyDigestMinute = 30,
    this.reminderLeadMinutes = 30,
    this.quietHoursStartHour = 22,
    this.quietHoursStartMinute = 0,
    this.quietHoursEndHour = 7,
    this.quietHoursEndMinute = 0,
    this.pushRegistered = false,
  });

  final bool enabled;
  final bool dailyDigest;
  final int dailyDigestHour;
  final int dailyDigestMinute;
  final int reminderLeadMinutes;
  final int quietHoursStartHour;
  final int quietHoursStartMinute;
  final int quietHoursEndHour;
  final int quietHoursEndMinute;
  final bool pushRegistered;

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'daily_digest': dailyDigest,
        'daily_digest_hour': dailyDigestHour,
        'daily_digest_minute': dailyDigestMinute,
        'reminder_lead_minutes': reminderLeadMinutes,
        'quiet_hours_start_hour': quietHoursStartHour,
        'quiet_hours_start_minute': quietHoursStartMinute,
        'quiet_hours_end_hour': quietHoursEndHour,
        'quiet_hours_end_minute': quietHoursEndMinute,
        'push_registered': pushRegistered,
      };

  factory NotificationPrefs.fromJson(Map<String, dynamic> json) {
    return NotificationPrefs(
      enabled: json['enabled'] as bool? ?? true,
      dailyDigest: json['daily_digest'] as bool? ?? true,
      dailyDigestHour: json['daily_digest_hour'] as int? ?? 7,
      dailyDigestMinute: json['daily_digest_minute'] as int? ?? 30,
      reminderLeadMinutes: json['reminder_lead_minutes'] as int? ?? 30,
      quietHoursStartHour: json['quiet_hours_start_hour'] as int? ?? 22,
      quietHoursStartMinute: json['quiet_hours_start_minute'] as int? ?? 0,
      quietHoursEndHour: json['quiet_hours_end_hour'] as int? ?? 7,
      quietHoursEndMinute: json['quiet_hours_end_minute'] as int? ?? 0,
      pushRegistered: json['push_registered'] as bool? ?? false,
    );
  }

  NotificationPrefs copyWith({
    bool? enabled,
    bool? dailyDigest,
    int? dailyDigestHour,
    int? dailyDigestMinute,
    int? reminderLeadMinutes,
    int? quietHoursStartHour,
    int? quietHoursStartMinute,
    int? quietHoursEndHour,
    int? quietHoursEndMinute,
    bool? pushRegistered,
  }) {
    return NotificationPrefs(
      enabled: enabled ?? this.enabled,
      dailyDigest: dailyDigest ?? this.dailyDigest,
      dailyDigestHour: dailyDigestHour ?? this.dailyDigestHour,
      dailyDigestMinute: dailyDigestMinute ?? this.dailyDigestMinute,
      reminderLeadMinutes: reminderLeadMinutes ?? this.reminderLeadMinutes,
      quietHoursStartHour: quietHoursStartHour ?? this.quietHoursStartHour,
      quietHoursStartMinute:
          quietHoursStartMinute ?? this.quietHoursStartMinute,
      quietHoursEndHour: quietHoursEndHour ?? this.quietHoursEndHour,
      quietHoursEndMinute: quietHoursEndMinute ?? this.quietHoursEndMinute,
      pushRegistered: pushRegistered ?? this.pushRegistered,
    );
  }
}
