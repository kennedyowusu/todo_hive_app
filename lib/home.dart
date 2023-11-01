import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:todo_app/model/todos.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? newTaskTitle;
  Box? hiveBox;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Todo App using Hive".toUpperCase(),
          key: const Key("title"),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: buildAllTodoView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Center(
                  child: Text(
                    "Add Your Task",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                content: TextFormField(
                  decoration: const InputDecoration(
                    hintText: "Enter Your Task",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (String value) {
                    setState(() {
                      newTaskTitle = value;
                    });
                  },
                  onFieldSubmitted: (String value) {
                    if (value.isNotEmpty) {
                      Todos newTodo = Todos(
                        title: value,
                        date: DateTime.now(),
                        isDone: false,
                      );
                      hiveBox!.add(newTodo.toMap());
                      setState(() {
                        newTaskTitle = "";
                      });
                      Navigator.pop(context);
                    }
                  },
                ),
              );
            },
          );
        },
        child: const CircleAvatar(
          backgroundColor: Colors.white,
          radius: 20,
          child: Icon(
            Icons.add,
            color: Colors.teal,
            size: 30,
            weight: 2.5,
          ),
        ),
      ),
    );
  }

  Widget buildAllTodoView() {
    return FutureBuilder(
      future: Hive.openBox("todos"),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return const Text("Error Opening Hive");
          } else {
            hiveBox = snapshot.data;
            return allTodos();
          }
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  Padding allTodos() {
    List allTodos = hiveBox!.values.toList();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: ListView.builder(
        itemCount: allTodos.length,
        itemBuilder: (context, index) {
          Todos todo = Todos.fromMap(allTodos[index]);
          return Container(
            height: MediaQuery.of(context).size.height * 0.1,
            decoration: BoxDecoration(
              color: Colors.teal.shade100,
              borderRadius: BorderRadius.circular(6),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0, 2),
                  blurRadius: 30,
                ),
              ],
            ),
            margin: const EdgeInsets.symmetric(
              vertical: 15,
            ),
            child: ListTile(
              onTap: () {
                setState(() {
                  todo.isDone = !todo.isDone;
                  hiveBox!.putAt(index, todo.toMap());
                });
              },
              onLongPress: () => showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Center(
                      child: Text(
                        "Delete Task".toUpperCase(),
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    content: const Text("Are you sure you want to delete?"),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    actions: [
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () {
                          hiveBox!.deleteAt(index);
                          setState(() {});
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Yes",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.black54,
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "No",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              title: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  todo.title,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                    decoration: todo.isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              subtitle: Text(
                "${todo.date.day}-${todo.date.month}-${todo.date.year} at ${todo.date.hour}:${todo.date.minute}",
                style: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
              trailing: Icon(
                todo.isDone ? Icons.check_box : Icons.check_box_outline_blank,
                color: todo.isDone ? Colors.green : Colors.black26,
              ),
            ),
          );
        },
      ),
    );
  }
}
