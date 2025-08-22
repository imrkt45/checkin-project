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
  String errorMessage ="";
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  // Future<bool> signUp(String username, String password, String email) async {
  //   final url = Uri.parse("http://localhost:3000/users"); // json-server users API
  //
  //   final response = await http.post(
  //     url,
  //     headers: {"Content-Type": "application/json"},
  //     body: jsonEncode({
  //       "username": username,
  //       "password": password,
  //       "email": email,
  //       "checkIn": null,
  //       "checkOut": null
  //     }),
  //   );
  //
  //   if (response.statusCode == 201) {
  //     final jsonData = json.decode(response.body);
  //     print("User created: $jsonData");
  //     return true;
  //   } else {
  //     setState(() {
  //       data = "Error: ${response.body}";
  //     });
  //     print("Failed: ${response.body}");
  //     return false;
  //   }
  // }



  Future<bool> signUp(String username, String password, String email) async {
    final url = Uri.parse("http://localhost:3000/users"); // json-server users API

    final existingResponse = await http.get(url);
    if (existingResponse.statusCode == 200) {
      final List users = json.decode(existingResponse.body);

      final usernameExists =
      users.any((u) => u['username'].toString().toLowerCase() == username.toLowerCase());
      final emailExists =
      users.any((u) => u['email'].toString().toLowerCase() == email.toLowerCase());

      if (usernameExists || emailExists) {
        setState(() {
          data = usernameExists
              ? "Username already exists"
              : "Email already exists";
        });
        return false;
      }
    } else {
      setState(() {
        data = "Failed to fetch existing users";
      });
      return false;
    }

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "password": password,
        "email": email
      }),
    );

    if (response.statusCode == 201) {
      final jsonData = json.decode(response.body);
      print("User created: $jsonData");
      return true;
    } else {
      setState(() {
        data = "Error: ${response.body}";
      });
      print("Failed: ${response.body}");
      return false;
    }
  }



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
