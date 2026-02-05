class ResponseRecord {
  final String quizUid;
  final String? deviceUid;
  final dynamic value;
  final DateTime when;
  final String? demographic;
  final String? region;

  ResponseRecord({
    required this.quizUid,
    this.deviceUid,
    required this.value,
    required this.when,
    this.demographic,
    this.region,
  });

  Map<String, dynamic> toMap() {
    return {
      'question_id': quizUid,
      'device_id': deviceUid,
      'answer': value,
      'timestamp': when.toIso8601String(),
      'age_group': demographic,
      'location': region,
    };
  }
}
