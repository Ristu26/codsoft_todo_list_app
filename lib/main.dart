import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black87),
        ),
      ),
      home: const TodoListScreen(),
    );
  }
}

class Todo {
  Todo({
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    this.isCompleted = false,
  });

  String description;
  DateTime dueDate;
  bool isCompleted;
  String priority;
  String title;
}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  TodoListScreenState createState() => TodoListScreenState();
}

class TodoListScreenState extends State<TodoListScreen> {
  final List<Todo> _todos = [];

  Future<void> _deleteTodoDialog(BuildContext context, int index) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete Task',
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          content:
              Text('Are you sure you want to delete "${_todos[index].title}"?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel')),
            TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () {
                  _deleteTodo(index);
                  Navigator.of(context).pop();
                },
                child: const Text('Delete')),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _addTodo(Todo todo) {
    setState(() {
      _todos.add(todo);
    });
    _showSnackBar('Task "${todo.title}" has been created successfully!');
  }

  void _editTodo(int index, Todo updatedTodo) {
    setState(() {
      _todos[index] = updatedTodo;
    });
    _showSnackBar('Task "${updatedTodo.title}" has been updated successfully!');
  }

  void _deleteTodo(int index) {
    final deletedTodo = _todos[index];
    setState(() {
      _todos.removeAt(index);
    });
    _showSnackBar('Task "${deletedTodo.title}" has been deleted successfully!');
  }

  Future<void> _showAddTodoDialog(BuildContext context) async {
    final newTodo = await _showTodoDialog(context, 'Add New Task');
    if (newTodo != null) {
      _addTodo(newTodo);
    }
  }

  Future<void> _showEditTodoDialog(
      BuildContext context, Todo todo, int index) async {
    final updatedTodo = await _showTodoDialog(context, 'Edit Task', todo);
    if (updatedTodo != null) {
      _editTodo(index, updatedTodo);
    }
  }

  Future<Todo?> _showTodoDialog(BuildContext context, String title,
      [Todo? todo]) async {
    final titleController = TextEditingController(text: todo?.title ?? '');
    final descriptionController =
        TextEditingController(text: todo?.description ?? '');

    DateTime selectedDate = todo?.dueDate ?? DateTime.now();
    String priority = todo?.priority ?? 'Low';

    return await showDialog<Todo>(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Task Title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    title: const Text('Due Date'),
                    trailing: OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today,
                          color: Colors.deepPurple),
                      label: const Text('Select Date'),
                      onPressed: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null && pickedDate != selectedDate) {
                          selectedDate = pickedDate;
                        }
                      },
                    ),
                    subtitle: Text(
                      DateFormat.yMMMd().format(selectedDate),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: priority,
                    decoration: InputDecoration(
                      labelText: 'Priority',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    onChanged: (String? newValue) {
                      if (newValue != null) priority = newValue;
                    },
                    items: ['Low', 'Medium', 'High']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey,
                        ),
                        child: const Text('Cancel'),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          if (titleController.text.isNotEmpty) {
                            final newTodo = Todo(
                              title: titleController.text,
                              description: descriptionController.text,
                              dueDate: selectedDate,
                              priority: priority,
                            );
                            Navigator.of(context).pop(newTodo);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Please enter a task title')),
                            );
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Todo List App',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: _todos.isEmpty
          ? const Center(child: Text('No tasks available.'))
          : ListView.builder(
              itemCount: _todos.length,
              itemBuilder: (context, index) {
                final todo = _todos[index];
                return TodoItemWidget(
                  todo: todo,
                  index: index,
                  onDelete: _deleteTodoDialog,
                  onEdit: _showEditTodoDialog,
                  onToggleCompletion: (value) {
                    setState(() {
                      todo.isCompleted = value!;
                    });
                    _showSnackBar(value!
                        ? 'Task "${todo.title}" marked as completed!'
                        : 'Task "${todo.title}" marked as incomplete!');
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTodoDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TodoItemWidget extends StatelessWidget {
  const TodoItemWidget({
    required this.todo,
    required this.index,
    required this.onDelete,
    required this.onEdit,
    required this.onToggleCompletion,
    super.key,
  });

  final Todo todo;
  final int index;
  final Function(BuildContext, int) onDelete;
  final Function(BuildContext, Todo, int) onEdit;
  final ValueChanged<bool?> onToggleCompletion;

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Medium':
        return Colors.green;
      case 'High':
        return Colors.red;
      default: // Low
        return Colors.blue;
    }
  }

  Color _getTaskColor(bool isCompleted) {
    return isCompleted ? Colors.green : Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: todo.isCompleted ? Colors.green[100] : Colors.white,
      child: ListTile(
        leading: Checkbox(
          value: todo.isCompleted,
          onChanged: onToggleCompletion,
          activeColor: Colors.green,
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            color: _getTaskColor(todo.isCompleted),
            decoration: todo.isCompleted
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              todo.description,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(width: 4),
            Text(
              'Due: ${DateFormat.yMMMd().format(todo.dueDate)}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(width: 4),
            Text(
              'Priority: ${todo.priority}',
              style: TextStyle(
                color: _getPriorityColor(todo.priority),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              onEdit(context, todo, index);
            } else if (value == 'delete') {
              onDelete(context, index);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Text('Edit'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }
}
