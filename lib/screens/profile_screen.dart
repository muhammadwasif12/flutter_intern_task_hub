import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'tasks_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<List<dynamic>> fetchApiUsers() async {
    final response = await http.get(Uri.parse("https://jsonplaceholder.typicode.com/users"));
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>?> getUserDetails() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final snapshot = await FirebaseFirestore.instance.collection("users").doc(uid).get();
      return snapshot.data();
    }
    return null;
  }

  void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("User Profile",style:TextStyle(color:Colors.white,fontWeight: FontWeight.w500,fontSize: 20)),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(Icons.task,color:Colors.white),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => TasksScreen()));
            },
          ),
          IconButton(
            icon: Icon(Icons.logout,color:Colors.white),
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: FutureBuilder(
        future: Future.wait([getUserDetails(), fetchApiUsers()]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final userData = snapshot.data![0] as Map<String, dynamic>?;
          final apiUsers = snapshot.data![1] as List;

          return ListView(
            padding: EdgeInsets.all(20),
            children: [
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 5,
                child: ListTile(
                  title: Text("Name: ${userData?['name'] ?? 'Unknown'}", style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Email: ${userData?['email'] ?? ''}"),
                  leading: CircleAvatar(child: Icon(Icons.person)),
                ),
              ),
              SizedBox(height: 20),
              Text("API Users", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ...apiUsers.map((u) => Card(
                margin: EdgeInsets.symmetric(vertical: 5),
                child: ListTile(
                  title: Text(u['name']),
                  subtitle: Text(u['email']),
                  leading: Icon(Icons.account_circle_outlined),
                ),
              )),
            ],
          );
        },
      ),
    );
  }
}