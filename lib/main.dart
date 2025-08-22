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
  Future<bool> signIn(username, password) async {
    final response = await http.get(Uri.parse('http://localhost:3000/dev/signIn?username=$username&password=$password'));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      print(jsonData);
      return true;
    } else {
    final jsonData = json.decode(response.body);
      setState(() {
        data = jsonData['message']; // Replace 'key' with the key of the data you want
      });
    print(json.decode(response.body));
      throw Exception('Failed to load data');
    }
  }

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();


  String errorMessage = '';

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
                // String username = usernameController.text;
                // String password = passwordController.text;
                // bool ans = await  signIn(username, password);
                bool ans= true;
                if (ans) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CheckIn()),
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

















