import 'package:flutter/material.dart';
import 'login.dart';

class HomePage extends StatelessWidget {

  final String name;

  const HomePage({super.key, required this.name});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Home Page"),

        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                ),
                (route) => false,
              );

            },
          ),
        ],
      ),

      body: Center(

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            const Icon(
              Icons.verified_user,
              size: 80,
              color: Colors.green,
            ),

            const SizedBox(height: 20),

            Text(
              "Welcome $name : $name",
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Login Success",
              style: TextStyle(fontSize: 18),
            ),

          ],
        ),

      ),

    );

  }

}