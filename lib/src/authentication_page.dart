import 'buttons/login_button.dart';
import 'dart:async';
import 'dart:convert' show json;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;


GoogleSignIn _googleSignIn = GoogleSignIn(
  // Optional clientId
  // clientId: '479882132969-9i9aqik3jfjd7qhci1nqf0bm2g71rm1u.apps.googleusercontent.com',
  scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);


class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State createState() => AuthPageState();
}

class AuthPageState extends State<AuthPage> {
  GoogleSignInAccount? _currentUser;
  String _contactText = '';

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
      if (_currentUser != null) {
        _handleGetContact(_currentUser!);
      }
    });
    _googleSignIn.signInSilently();
  }

  Future<void> _handleGetContact(GoogleSignInAccount user) async {
    setState(() {
      _contactText = 'Loading contact info...';
    });
    final http.Response response = await http.get(
      Uri.parse('https://people.googleapis.com/v1/people/me/connections'
          '?requestMask.includeField=person.names'),
      headers: await user.authHeaders,
    );
    if (response.statusCode != 200) {
      setState(() {
        _contactText = 'People API gave a ${response.statusCode} '
            'response. Check logs for details.';
      });
      print('People API ${response.statusCode} response: ${response.body}');
      return;
    }
    final Map<String, dynamic> data =
    json.decode(response.body) as Map<String, dynamic>;
    final String? namedContact = _pickFirstNamedContact(data);
    setState(() {
      if (namedContact != null) {
        _contactText = 'I see you know $namedContact!';
      } else {
        _contactText = 'No contacts to display.';
      }
    });
  }

  String? _pickFirstNamedContact(Map<String, dynamic> data) {
    final List<dynamic>? connections = data['connections'] as List<dynamic>?;
    final Map<String, dynamic>? contact = connections?.firstWhere(
          (dynamic contact) => contact['names'] != null,
      orElse: () => null,
    ) as Map<String, dynamic>?;
    if (contact != null) {
      final Map<String, dynamic>? name = contact['names'].firstWhere(
            (dynamic name) => name['displayName'] != null,
        orElse: () => null,
      ) as Map<String, dynamic>?;
      if (name != null) {
        return name['displayName'] as String?;
      }
    }
    return null;
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  Future<void> _handleSignOut() => _googleSignIn.disconnect();

  @override
  Widget build(BuildContext context) {
    final GoogleSignInAccount? user = _currentUser;
    if (user != null) {
      return Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            ListTile(
              leading: GoogleUserCircleAvatar(
                identity: user,
              ),
              title: Text(user.displayName ?? ''),
              subtitle: Text(user.email),
            ),
            const Text('Signed in successfully.'),
            Text(_contactText),
            ElevatedButton(
              onPressed: _handleSignOut,
              child: const Text('SIGN OUT'),
            ),
            ElevatedButton(
              child: const Text('REFRESH'),
              onPressed: () => _handleGetContact(user),
            ),
          ],
        ),
      );
    }else {
      return Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                Center(
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      //Gradient

                      Container(
                        // margin: const EdgeInsets.all(10),
                        // padding: const EdgeInsets.all(10),
                        width: MediaQuery.of(context).size.width,
                        // height: 1024,
                        height: MediaQuery.of(context).size.height,
                        decoration: BoxDecoration(
                          gradient: SweepGradient(
                            colors: [
                              Colors.pinkAccent.shade700,
                              Colors.pink.shade500,
                              Colors.pink.shade700,
                              Colors.pink.shade700,
                              Colors.pinkAccent.shade400,
                              Colors.pinkAccent.shade200,
                              Colors.pinkAccent.shade100,
                              Colors.white,
                              Colors.white,
                              Colors.white,
                              Colors.lightBlue.shade100,
                              Colors.lightBlue.shade300,
                              Colors.blue.shade500,
                              Colors.blue,
                              Colors.blueAccent.shade700,
                              Colors.lightBlue.shade100,
                              Colors.white,
                              Colors.white,
                              Colors.pinkAccent.shade100,
                            ],
                            startAngle: 0.0,
                            endAngle: 6.0,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 620),
                        child: Image.asset(
                          'assets/images/tindog_logo_black.png',
                          fit: BoxFit.cover,
                          alignment: Alignment.bottomCenter,
                          scale: 1.3,
                          color: Colors.black,
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'By clicking Log in, you agree with our Terms. Learn how we process your data in our Privacy Policy and Cookies Policy.',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            //Botão google

                            LoginButton(
                              texto: 'LOG IN WITH GOOGLE',
                              imagem: const AssetImage('assets/images/google.png'),
                              cor: Colors.black87,
                              onPressed: _handleSignIn,
                            ),

                            //Espaçador
                            const SizedBox(
                              height: 15,
                            ),
                            LoginButton(
                                texto: 'LOG IN WITH FACEBOOK',
                                imagem: const AssetImage(
                                    'assets/images/facebook.png'),
                                cor: Colors.blue.shade500),
                            //Espaçador
                            const SizedBox(
                              height: 15,
                            ),
                            //Botão número
                            const LoginButton(
                              texto: 'LOG IN WITH YOUR PHONE',
                              imagem: AssetImage('assets/images/chats.png'),
                              cor: Colors.black87,
                            ),
                            // Espaçador
                            const SizedBox(
                              height: 30,
                            ),
                            const Text(
                              'Trouble logging in?',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
    // final ImageProvider _imageProvider;
  }
}

