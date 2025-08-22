import 'home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/signUp.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;





void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SignInPage(),
  ));
}
class SignInPage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage>{
  String data = "";

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<bool> signIn(String username, String password) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/users'));
      print(response);
      if (response.statusCode == 200) {
        final users = json.decode(response.body);

        final user = users.firstWhere(
              (u) =>
          u['username'] == username && u['password'] == password,
          orElse: () => null,
        );

        if (user != null) {
          print("SignIn Success: $user");
          return true;
        } else {
          setState(() {
            data = "Invalid username or password";
          });
          return false;
        }
      } else {
        setState(() {
          data = "Failed to fetch users";
        });
        return false;
      }
    } catch (e) {
      setState(() {
        data = "Error: $e";
      });
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 10),
            Text(
              data, // Display the error message here
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String username = usernameController.text;
                String password = passwordController.text;

                if (username.isEmpty || password.isEmpty) {
                  setState(() {
                    data = "Please fill in all fields";
                  });
                  return;
                }


                bool ans = await  signIn(username, password);
                print(ans);
                if (ans) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CheckIn(username: username)),
                  );
                };
              },
              child: const Text('Sign In'),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => SignUpPage()),
                );
              },
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}

















