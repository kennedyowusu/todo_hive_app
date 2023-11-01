class Todos {
  final String title;
  final DateTime date;
  bool isDone;

  Todos({
    required this.title,
    required this.date,
    required this.isDone,
  });

  factory Todos.fromMap(Map todo) {
    return Todos(
      title: todo["title"],
      date: todo['date'],
      isDone: todo['isDone'],
    );
  }

  Map toMap() {
    return {
      'title': title,
      'date': date,
      'isDone': isDone,
    };
  }
}
