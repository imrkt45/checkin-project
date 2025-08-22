import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_app/main.dart';


class CodeInputScreen extends StatefulWidget {
  @override
  final String username;
  CodeInputScreen({required this.username});
  // ignore: library_private_types_in_public_api
  _CodeInputScreenState createState() => _CodeInputScreenState();
}


class _CodeInputScreenState extends State<CodeInputScreen>  {
  String data = "";
  Future<bool> verifyUsers(code,username) async {
    final response = await http.get(Uri.parse('http://localhost:3000/dev/confirmUser?username=$username&code=$code'));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      print(jsonData);
    //  data = jsonData['message'];
      return true;
    } else {
      final jsonData = json.decode(response.body);
      print(json.decode(response.body));
      throw Exception('Failed to load data');
    }
  }

  @override

  final TextEditingController _codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Please Verify ${widget.username}"),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: 'Enter Code',
              ),
            ),
            SizedBox(height: 20),
            Text(
              data, // Display the error message here
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                String otp = _codeController.text;
                if(otp.length!=6) {
                  // ignore: unnecessary_null_comparison
                  if(otp=="0")
                  setState(() {
                    data = "Invalid code provided, please request a code again";
                  });
                  else {
                    setState(() {
                      data = "Invalid verification code provided, please try again.";
                    });
                  }
                } else {
                  bool ans  = await verifyUsers(otp, widget.username);
              if(ans) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SignInPage(),
                  ),
                );
              } else{
          setState(() {
          data = "Invalid verification code provided, please try again.";
          });
              }
                  }
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

