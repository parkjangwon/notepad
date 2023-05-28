class MemoDTO {
  final String id;
  late String title;
  late String text;
  final String createdTime;
  String editedTime;

  MemoDTO({
    required this.id,
    required this.title,
    required this.text,
    required this.createdTime,
    required this.editedTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'text': text,
      'createdTime': createdTime,
      'editedTime': editedTime
    };
  }

  @override
  String toString() {
    return '''
    MemoDTO {
      id: $id,
      title: $title,
      text: $text,
      createdTime: $createdTime,
      editedTime: $editedTime
    }
    ''';
  }
}
