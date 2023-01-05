// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, prefer_interpolation_to_compose_strings, avoid_print

//import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:randomstring_dart/randomstring_dart.dart';
import 'package:tictactoe_app/game_page.dart';
import 'dart:async';
//import 'package:tictactoe_app/get_active_code.dart';
//import 'globals.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text controllers
  final _codeController = TextEditingController();

  // local variables
  String generatedNewCode = '';

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  // generate a random code using
  String generateCode() {
    final rs = RandomString();
    String code = rs.getRandomString(
      uppersCount: 5,
      lowersCount: 0,
      numbersCount: 2,
      specialsCount: 0,
    );
    return code;
  }

  // create a new game
  Future createNewGame(uniqueCode) async {
    generatedNewCode = uniqueCode;
    // create a code and add it to the database
    await FirebaseFirestore.instance.collection('activeCodes').add({
      'code': uniqueCode,
      'p1pos': [],
      'p2pos': [],
      'turn': true,
    });
  }

  // function to check if the code exists in the db
  Future<bool> doesCodeExist(currentCode) async {
    bool isTrue = true;
    try {
      await FirebaseFirestore.instance
          .collection('activeCodes')
          .where('code', isEqualTo: currentCode)
          .get()
          .then((value) => value.size > 0 ? isTrue = true : isTrue = false);
    } catch (e) {
      debugPrint(e.toString());
    }

    return isTrue;
  }

  // function to check if new code is needed or not
  codeProcess() async {
    String currentCode = generateCode();

    while (await doesCodeExist(currentCode)) {
      print(
          'ah the code generated is available in the database so trying again!');
      currentCode = generateCode();
    }
    print('yey ' +
        currentCode +
        ' code doesn\'t exist so adding it to the database');
    createNewGame(currentCode);
  }

  // function to join an existing game
  joinGame() async {
    if (!_codeController.text.isEmpty) {
      if (_codeController.text.trim().length == 7) {
        if (await doesCodeExist(_codeController.text.trim())) {
          Future.delayed(Duration.zero, () {
            showDialog(
              context: context,
              builder: (context) {
                print('Valid code! Joining the session');
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            );
          });

          // timer
          final timer = Timer(const Duration(seconds: 1), () {
            // deleting the loading screen
            Navigator.of(context).pop();

            // navigating to the game page
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        GamePage(currentCode: _codeController.text.trim())));
          });
        } else {
          Future.delayed(Duration.zero, () {
            showDialog(
              context: context,
              builder: (context) {
                //_codeController.text = '';
                return AlertDialog(
                  content: Text('Invalid code!'),
                );
              },
            );
          });
        }
      } else {
        Future.delayed(Duration.zero, () {
          showDialog(
            context: context,
            builder: (context) {
              //_codeController.text = '';
              return AlertDialog(
                content: Text('Invalid code!'),
              );
            },
          );
        });
      }
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('No code has entered!'),
          );
        },
      );
    }

    //Navigator.of(context).pop();
  }

  // function to join a newly created game
  joinNewGame() async {
    Future.delayed(Duration.zero, () {
      showDialog(
        context: context,
        builder: (context) {
          print('Valid code! Joining the session');
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      );
    });

    // timer
    final timer = Timer(const Duration(seconds: 1), () {
      // deleting the loading screen
      Navigator.of(context).pop();

      // navigating to the game page
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => GamePage(currentCode: generatedNewCode)));
    });
  }

  // document IDs
  List<String> docIDs = [];
  List<String> activeCodes = [];

  var seen = Set<String>();
  List<String> uniqueCodeList = [];

  // get available IDs
  Future getDocId() async {
    await FirebaseFirestore.instance
        .collection('activeCodes')
        .get()
        .then((snapshot) => snapshot.docs.forEach((element) {
              //print(element.reference);
              docIDs.add(element.reference.id);
            }));
  }

  @override
  void initState() {
    generatedNewCode = '';
    getDocId();
    super.initState();
  }

  /*
  // function for display the active codes
  String displayTheList() {
    // precaution: removes if there are duplicate codes
    uniqueCodeList = codeList.where((code) => seen.add(code)).toList();
    return uniqueCodeList.toString();
  }

  updateTheList(String value) {
    activeCodes.add(value);
  }
  */

  @override
  Widget build(BuildContext context) {
    // get the screen width
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 29, 15, 74),
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: screenWidth > 380 ? 380 : screenWidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // title
                Text(
                  'TicTacToe',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 36,
                    color: Colors.white,
                  ),
                ),

                Text(
                  'Simple game created using Flutter',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white70,
                  ),
                ),

                SizedBox(height: 45),

                // enter code
                Text(
                  'Enter code to join a game',
                  style: TextStyle(
                    //fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: 10),

                // code textfield
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 44, 29, 91),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: TextField(
                        controller: _codeController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Code',
                          hintStyle: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 10),

                // join button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: GestureDetector(
                    onTap: joinGame,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 37, 228, 174),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Join',
                          style: TextStyle(
                            color: Color.fromARGB(255, 29, 15, 74),
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 10),

                // or text
                Text(
                  'or',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white70,
                  ),
                ),

                SizedBox(height: 10),

                // create a new game button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: GestureDetector(
                    onTap: () {
                      codeProcess();
                      joinNewGame();
                    },
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 37, 228, 174),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Create a new game',
                          style: TextStyle(
                            color: Color.fromARGB(255, 29, 15, 74),
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                /*
                Expanded(
                  child: FutureBuilder(
                    future: getDocId(),
                    builder: (context, snapshot) {
                      return ListView.builder(
                        itemCount: docIDs.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: GetActiveCode(documentId: docIDs[index]),
                          );
                          //updateTheList();
                        },
                      );
                    },
                  ),
                ),
          
                Column(
                  children: [
                    Text(
                      'Current code list : ' + displayTheList(),
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
                */
              ],
            ),
          ),
        ),
      ),
    );
  }
}
