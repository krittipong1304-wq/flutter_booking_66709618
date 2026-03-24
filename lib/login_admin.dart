import 'package:flutter/material.dart';
import 'package:flutter_booking/room_list.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'room_crud.dart';

class LoginAdmin extends StatefulWidget {
  const LoginAdmin({super.key});

  @override
  State<LoginAdmin> createState() => _LoginAdminState();
}

class _LoginAdminState extends State<LoginAdmin> {
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();

  bool isPasswordHidden = true;

  Future login() async {
    var url = Uri.parse("http://localhost/flutter_booking_66709618/php_api/login_admin.php");

    var response = await http.post(
      url,
      body: {"username": username.text, "password": password.text},
    );

    var data = json.decode(response.body);

    if (data["status"] == "success") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => roompage(name: data["name"])), //เพิ่มการส่งค่า name ไปยัง HomePage
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Username หรือ Password ไม่ถูกต้อง"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login Admin")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            const Icon(Icons.account_circle, size: 100),

            const SizedBox(height: 30),

            TextField(
              controller: username,
              decoration: const InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: password,
              obscureText: isPasswordHidden,
              decoration: InputDecoration(
                labelText: "Password",
                border: const OutlineInputBorder(),

                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordHidden ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordHidden = !isPasswordHidden;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(
                onPressed: login,
                child: const Text("LOGIN", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
