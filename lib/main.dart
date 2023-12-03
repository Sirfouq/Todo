// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:todo/services/sqlite_service.dart';
import 'package:todo/themes/apptheme.dart';

import 'model/todo.dart';

// ... imports ...

void main() {
  ensure_initialized();
  runApp(const MyApp());
}

void ensure_initialized() {
  WidgetsFlutterBinding.ensureInitialized();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      darkTheme: darkTheme,
      theme: lightTheme,
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Todo>> getItems;
  var _controller = TextEditingController();
  var todoService = SqfliteService<Todo>(
    tableName: 'todos',
    dbName: 'myapp.db',
    dbVersion: 1,
    fromMap: Todo.fromMap,
    toMap: (todo) => todo.toMap(),
  );

  void _fetchTodos() {
    setState(() {
      getItems = todoService.getAll();
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchTodos();
  }

  void _popupdisplay(Todo? todoItem) {
    _controller.text = todoItem?.description ?? '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add a task'),
          content: TextField(controller: _controller),
          actions: [
            TextButton(
              onPressed: () async {
                if (todoItem == null) {
                  await todoService.insert(Todo(
                      description: _controller.text,
                      isCompleted: false,
                      id: null));
                  _controller.clear();
                } else {
                  todoItem.description = _controller.text;
                  await todoService.update(todoItem);
                }
                Navigator.of(context).pop();
                _fetchTodos();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () => _popupdisplay(null),
            icon: const Icon(Icons.add_task),
          ),
        ],
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.background,
        title: const Text(
          'Todays Tasks',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<List<Todo>>(
          future: getItems,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              final todos = snapshot.data!;
              return ListView.builder(
                itemCount: todos.length,
                itemBuilder: (context, index) {
                  final todo = todos[index];
                  return Dismissible(
                    key: ValueKey<int>(todos.indexOf(todo)),
                    onDismissed: (direction) async {
                      await todoService.delete(todo.id ?? 0);
                      setState(() {
                        _fetchTodos();
                      });
                    },
                    background: Padding(
                      padding: EdgeInsets.all(10),
                      child: Container(
                          padding: EdgeInsets.all(8.0),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.onSecondary),
                          child: Icon(
                            Icons.cancel,
                            color: Colors.grey,
                            
                          )),
                    ),
                    child: ListTile(
                      title: Text(
                        todo.description,
                        style: TextStyle(
                          decoration: todo.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              onPressed: () {
                                _popupdisplay(todo);

                                _fetchTodos();
                              },
                              icon: Icon(Icons.edit)),
                          Checkbox(
                            fillColor: MaterialStateProperty.all<Color>(
                                Theme.of(context).colorScheme.onPrimary),
                            checkColor:
                                Theme.of(context).colorScheme.background,
                            value: todo.isCompleted,
                            onChanged: (value) {
                              setState(() {
                                todo.isCompleted = value!;
                                todoService.update(todo);
                              });
                            },
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            } else {
              return const Text('No data available');
            }
          },
        ),
      ),
    );
  }
}
