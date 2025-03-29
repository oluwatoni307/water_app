// userData.dart
class UserData {
  final String id;
  final String userName;
  int goal;
  Map<String, int> metric;
  Map<Duration, int> Day_Log;
  Map<Duration, int> lastLog;
  Map<Duration, int> nextLog;

  UserData(
    this.userName,
    this.goal,
    this.metric,
    this.Day_Log,
    this.lastLog,
    this.nextLog,
    this.id,
  );

  // Convert UserData to JSON for storage
  Map<String, dynamic> toJson() => {
        'id': id,
        'userName': userName,
        'goal': goal,
        'metric': metric,
        'Day_Log': Day_Log.map(
            (key, value) => MapEntry(key.inMilliseconds.toString(), value)),
        'lastLog': lastLog.map(
            (key, value) => MapEntry(key.inMilliseconds.toString(), value)),
        'nextLog': nextLog.map(
            (key, value) => MapEntry(key.inMilliseconds.toString(), value)),
      };

  // Create UserData from JSON
  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      json['userName'] ?? '',
      json['goal'] ?? 0,
      (json['metric'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, value as int),
          ) ??
          {},
      (json['Day_Log'] as Map<String, dynamic>?)?.map(
            (key, value) =>
                MapEntry(Duration(milliseconds: int.parse(key)), value as int),
          ) ??
          {},
      (json['lastLog'] as Map<String, dynamic>?)?.map(
            (key, value) =>
                MapEntry(Duration(milliseconds: int.parse(key)), value as int),
          ) ??
          {},
      (json['nextLog'] as Map<String, dynamic>?)?.map(
            (key, value) =>
                MapEntry(Duration(milliseconds: int.parse(key)), value as int),
          ) ??
          {},
      json['id'] ?? '',
    );
  }
}
