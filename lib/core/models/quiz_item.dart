enum QuizItemType { yesNo, selection, range }

class QuizItem {
  final String uid;
  final String prompt;
  final QuizItemType category;
  final List<String>? choices;
  final int? lowerBound;
  final int? upperBound;

  QuizItem({
    required this.uid,
    required this.prompt,
    required this.category,
    this.choices,
    this.lowerBound,
    this.upperBound,
  });

  factory QuizItem.fromMap(Map<String, dynamic> data) {
    QuizItemType itemType;
    final typeStr = data['type'] as String;
    if (typeStr == 'binary') {
      itemType = QuizItemType.yesNo;
    } else if (typeStr == 'multiple_choice') {
      itemType = QuizItemType.selection;
    } else {
      itemType = QuizItemType.range;
    }

    return QuizItem(
      uid: data['id'].toString(),
      prompt: data['text'] as String,
      category: itemType,
      choices: data['options'] != null ? List<String>.from(data['options']) : null,
      lowerBound: data['min_value'] as int?,
      upperBound: data['max_value'] as int?,
    );
  }
}
