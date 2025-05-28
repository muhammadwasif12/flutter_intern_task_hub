import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/task_provider.dart';

class TasksScreen extends StatelessWidget {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("My Tasks",style:TextStyle(color:Colors.white,fontWeight: FontWeight.w500,fontSize: 20)),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          hintText: "Enter new task...",
                          prefixIcon: Icon(Icons.task_alt),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add_circle, color: Colors.deepPurple),
                      onPressed: () {
                        final task = controller.text.trim();
                        if (task.isNotEmpty) {
                          taskProvider.addTask(task);
                          controller.clear();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Task cannot be empty")),
                          );
                        }
                      },
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: taskProvider.tasks.isEmpty
                  ? Center(child: Text("No tasks yet!", style: TextStyle(fontSize: 16)))
                  : ListView.builder(
                      itemCount: taskProvider.tasks.length,
                      itemBuilder: (context, index) {
                        final task = taskProvider.tasks[index];
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          margin: EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: Icon(Icons.check_circle_outline, color: Colors.deepPurple),
                            title: Text(task),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => taskProvider.removeTask(index),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
