import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_app/verifyUser.dart';



class SignUpPage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

  String data = "";
  Future<bool> signUp(username, password, email) async {
    final response = await http.get(Uri.parse('http://localhost:3000/dev/signUp?username=$username&password=$password&email=$email'));
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
  final TextEditingController emailController = TextEditingController();
  String errorMessage ="";


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ), SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ), SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 10),
            Text(
              data, // Display the error message here
              style: const TextStyle(color: Colors.red),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String username = usernameController.text;
                String password = passwordController.text;
                String email = emailController.text;
                if(username.isEmpty || password.isEmpty || email.isEmpty){
                  setState(() {
                    errorMessage = 'Please fill in all the fields';
                  });
                } else{
                  setState(() {
                    errorMessage=data;
                  });
                }
                bool ans = await signUp(username, password, email);
                if (ans) {
                  // Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>
                        CodeInputScreen(username: username)),
                  );
                }
              },
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
