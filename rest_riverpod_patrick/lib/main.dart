import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class Todo {
  final int userId;
  final int id;
  final String title;
  final bool completed;

  Todo({
    required this.userId,
    required this.id,
    required this.title,
    required this.completed,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
      completed: json['completed'],
    );
  }
}



final todosProvider = FutureProvider<List<Todo>>((ref) async {
  final response = await http.get(
    Uri.parse('https://jsonplaceholder.typicode.com/todos'),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to load todos');
  }

  final List<dynamic> data = jsonDecode(response.body);
  return data.map((item) => Todo.fromJson(item)).toList();
});


void main() {
  runApp(const ProviderScope(child: MyApp()));
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Patrick Todo App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 129, 74, 224)),
      ),
      home: const HomePage(),
    );
  }
}


// First Page
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to the Patrick Todo App!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 9),
            const Text('Tap the button below to fetch and view todos'),
            const Text('from the REST API.'),
            const SizedBox(height: 25),
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Go to Todo List'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TodoListsPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}


// Second Page
class TodoListsPage extends ConsumerWidget {
  const TodoListsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosAsync = ref.watch(todosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: todosAsync.when(
        data: (todos) => ListView.builder(
          itemCount: todos.length,
          itemBuilder: (context, index) {
            final todo = todos[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  child: Icon(todo.completed ? Icons.check : Icons.access_time),
                ),
                title: Text(
                  todo.title,
                  style: TextStyle(
                    decoration:
                        todo.completed ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Text('Task ID: ${todo.id} | User ID: ${todo.userId}'),
                trailing: Checkbox(
                  value: todo.completed,
                  onChanged: (value) {},
                ),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
    );
  }
}