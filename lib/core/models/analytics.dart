class Analytics {
  final String quizUid;
  final Map<String, int> distribution;
  final int totalCount;

  Analytics({
    required this.quizUid,
    required this.distribution,
    required this.totalCount,
  });

  double calculateRatio(String val) {
    if (totalCount == 0) return 0;
    return ((distribution[val] ?? 0) / totalCount) * 100;
  }

  factory Analytics.fromMap(Map<String, dynamic> data) {
    return Analytics(
      quizUid: data['question_id'].toString(),
      distribution: Map<String, int>.from(data['answer_counts'] as Map),
      totalCount: data['total_answers'] as int,
    );
  }
}
