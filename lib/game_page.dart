// ignore_for_file: prefer_const_constructors, prefer_interpolation_to_compose_strings, avoid_unnecessary_containers, sort_child_properties_last, depend_on_referenced_packages, prefer_const_literals_to_create_immutables

import 'dart:async';
//import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tictactoe_app/blank_pixel.dart';
import 'package:tictactoe_app/login_page.dart';
import 'package:tictactoe_app/player2_pixel.dart';
import 'package:tictactoe_app/player_pixel.dart';
import 'package:collection/collection.dart';

class GamePage extends StatefulWidget {
  final String currentCode;

  const GamePage({super.key, required this.currentCode});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  // grid dimensions
  int rowSize = 3;
  int totalNumberOfSquares = 9;

  // player turn
  bool p1Turn = true; // intially player 1 gets the turn

  // player position
  List<int> playerPos = [];
  List<int> player2Pos = [];

  // player position from the database
  static List databasePlayer1Pos = [];
  static List databasePlayer2Pos = [];

  // game over boolean (to fix the overlapping msg)
  static bool anyoneWon = false;

  // document id
  static String docId = '';

  // function to add player positioon to the list
  addPlayerPos(int index) {
    if (p1Turn) {
      playerPos.add(index);
    } else {
      player2Pos.add(index);
    }
    p1Turn = !p1Turn;
  }

  // function to clear the grid and revert the turn
  clearGrid() {
    playerPos.clear();
    player2Pos.clear();
    setState(() {});
    p1Turn = true;
  }

  // function to update the received data from the database
  updateDataList() async {
    //databasePlayer1Pos.clear;
    getPlayer1List();
    getPlayer2List();
    setState(() {});
  }

  // function to check which players turn it is
  String checkPlayerTurn(bool bool) {
    String text = "";
    if (bool) {
      text = "Player 1";
    } else {
      text = "Player 2";
    }
    return text;
  }

  // initial state function
  @override
  void initState() {
    //Navigator.of(context).pop();
    databasePlayer1Pos.clear();
    databasePlayer2Pos.clear();
    docId = '';
    getPlayer1List();
    getPlayer2List();
    getDocID();
    updateGame(false);
    setState(() {});
    //getPlayer1List();
    super.initState();
  }

  // function to take the realtime data from the database
  void updateGame(bool bool) {
    final timer = Timer.periodic(Duration(milliseconds: 200), (timer) {
      //print('updating..');
      if (mounted) {
        setState(() {
          getPlayer1List();
          getPlayer2List();
          //print(databasePlayer1Pos.toString());
          playerPos = databasePlayer1Pos.cast<int>();
          player2Pos = databasePlayer2Pos.cast<int>();
        });
      }
    });
    if (bool) {
      timer.cancel();
    }
  }

  // function to clear the player position list
  clearPlayerList() {
    databasePlayer1Pos.clear();
    databasePlayer2Pos.clear();
  }

  @override
  void dispose() {
    updateGame(true);
    databasePlayer1Pos.clear();
    databasePlayer2Pos.clear();
    super.dispose();
  }

  // list equality function
  Function eq = const ListEquality().equals;

  // function to get the database list of player 1
  Future getPlayer1List() async {
    //List<int> dbPlayer1Pos = [];
    //String currentCode = 'dd';
    //databasePlayer1Pos.clear();
    try {
      await FirebaseFirestore.instance
          .collection('activeCodes')
          .where('code', isEqualTo: widget.currentCode)
          .get()
          .then(
        (value) {
          value.docs.forEach(
            (element) {
              //databasePlayer1Pos.clear();
              if (databasePlayer1Pos.isEmpty) {
                //databasePlayer1Pos.add(element.get("p1pos"));
                //print(element.reference.id);
                //if (docId.isEmpty) {
                //docId = element.reference.id;
                //}
                p1Turn = element.get("turn");
                databasePlayer1Pos = element.get("p1pos");
              }
              //print(element.get("p1pos"));
              //databasePlayer1Pos = element.get("p1pos");
            },
          );
        },
      );
    } catch (e) {
      //print(e.toString());
    }

    //return dbPlayer1Pos;
  }

  // function to get the database list of player 2
  Future getPlayer2List() async {
    try {
      await FirebaseFirestore.instance
          .collection('activeCodes')
          .where('code', isEqualTo: widget.currentCode)
          .get()
          .then(
        (value) {
          value.docs.forEach(
            (element) {
              if (databasePlayer2Pos.isEmpty) {
                p1Turn = element.get("turn");
                databasePlayer2Pos = element.get("p2pos");
              }
            },
          );
        },
      );
    } catch (e) {
      //print(e.toString());
    }
  }

  // function to get document id
  Future getDocID() async {
    await FirebaseFirestore.instance
        .collection('activeCodes')
        .where('code', isEqualTo: widget.currentCode)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        //if (databasePlayer1Pos.isEmpty) {
        //if (docId.isEmpty) {
        //setState(() {
        docId = element.reference.id;
        //print(docId);
        //});
        //}
        //}
      });
    });
  }

  // store game data in database
  Future updateFirebase(int value) async {
    try {
      if (!p1Turn) {
        await FirebaseFirestore.instance
            .collection('activeCodes')
            .doc(docId)
            .update({
          'p1pos': FieldValue.arrayUnion([value]),
          //'p2pos': FieldValue.arrayUnion([value]),
          'turn': p1Turn,
        });
      } else {
        await FirebaseFirestore.instance
            .collection('activeCodes')
            .doc(docId)
            .update({
          //'p1pos': FieldValue.arrayUnion([value]),
          'p2pos': FieldValue.arrayUnion([value]),
          'turn': p1Turn,
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future clearGridFromDatabase() async {
    try {
      // by turning off this statement, it makes game mechanics more cool ig
      //p1Turn = true;
      await FirebaseFirestore.instance
          .collection('activeCodes')
          .doc(docId)
          .update({
        'p1pos': FieldValue.delete(),
        'p2pos': FieldValue.delete(),
        'turn': p1Turn,
      });
      playerPos.clear();
      player2Pos.clear();
    } catch (e) {
      print(e.toString());
    }
    anyoneWon = false;
    setState(() {});
  }

  // function to check winning pattern
  checkGameGrid() {
    // checking player 1
    if (playerPos.contains(0) &&
        playerPos.contains(1) &&
        playerPos.contains(2)) {
      playerWin();
    } else if (playerPos.contains(3) &&
        playerPos.contains(4) &&
        playerPos.contains(5)) {
      playerWin();
    } else if (playerPos.contains(6) &&
        playerPos.contains(7) &&
        playerPos.contains(8)) {
      playerWin();
    } else if (playerPos.contains(0) &&
        playerPos.contains(3) &&
        playerPos.contains(6)) {
      playerWin();
    } else if (playerPos.contains(1) &&
        playerPos.contains(4) &&
        playerPos.contains(7)) {
      playerWin();
    } else if (playerPos.contains(2) &&
        playerPos.contains(5) &&
        playerPos.contains(8)) {
      playerWin();
    } else if (playerPos.contains(0) &&
        playerPos.contains(4) &&
        playerPos.contains(8)) {
      playerWin();
    } else if (playerPos.contains(6) &&
        playerPos.contains(4) &&
        playerPos.contains(2)) {
      playerWin();
    }

    // checking player 2
    if (player2Pos.contains(0) &&
        player2Pos.contains(1) &&
        player2Pos.contains(2)) {
      playerWin();
    } else if (player2Pos.contains(3) &&
        player2Pos.contains(4) &&
        player2Pos.contains(5)) {
      playerWin();
    } else if (player2Pos.contains(6) &&
        player2Pos.contains(7) &&
        player2Pos.contains(8)) {
      playerWin();
    } else if (player2Pos.contains(0) &&
        player2Pos.contains(3) &&
        player2Pos.contains(6)) {
      playerWin();
    } else if (player2Pos.contains(1) &&
        player2Pos.contains(4) &&
        player2Pos.contains(7)) {
      playerWin();
    } else if (player2Pos.contains(2) &&
        player2Pos.contains(5) &&
        player2Pos.contains(8)) {
      playerWin();
    } else if (player2Pos.contains(0) &&
        player2Pos.contains(4) &&
        player2Pos.contains(8)) {
      playerWin();
    } else if (player2Pos.contains(6) &&
        player2Pos.contains(4) &&
        player2Pos.contains(2)) {
      playerWin();
    }
  }

  // function to send msg as player 1 as winner
  playerWin() {
    anyoneWon = true;
    clearGridFromDatabase();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(checkPlayerTurn(!p1Turn) + ' win!'),
        );
      },
    );
  }

  // funtion to return player color
  Color checkPlayerColor() {
    Color color;
    if (p1Turn) {
      color = Color.fromARGB(255, 37, 228, 174);
    } else {
      color = Colors.pink;
    }

    return color;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 29, 15, 74),
      body: Column(
        children: [
          // space for title or something / top
          Expanded(
            flex: 0,
            child: Container(
              child: SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Container(
                        padding: EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 44, 29, 91),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Wrap(
                            //mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Session Code: ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                              Text(
                                widget.currentCode.toString(),
                                style: TextStyle(
                                  color: Color.fromARGB(255, 37, 228, 174),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        //SizedBox(width: 20),
                        Padding(
                          padding: const EdgeInsets.only(left: 25.0),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 0.0),
                            child: Container(
                              padding: EdgeInsets.all(25),
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 44, 29, 91),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Turn : ',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                      ),
                                    ),
                                    Text(
                                      checkPlayerTurn(p1Turn),
                                      style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 37, 228, 174),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Container(
                            padding: EdgeInsets.all(25),
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 44, 29, 91),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  /*
                                  Text(
                                    'Color :',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                    ),
                                  ),
                                  */
                                  Icon(
                                    Icons.square,
                                    color: checkPlayerColor(),
                                    size: 30,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // game grid
          Expanded(
            flex: 3,
            child: GridView.builder(
              itemCount: totalNumberOfSquares,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: rowSize,
              ),
              itemBuilder: (context, index) {
                /*
                if (playerPos.contains(index)) {
                  return const PlayerPixel();
                } else {
                  return const BlankPixel();
                }*/
                if (playerPos.contains(index)) {
                  return GestureDetector(
                    child: PlayerPixel(),
                  );
                } else if (player2Pos.contains(index)) {
                  return GestureDetector(
                    child: Player2Pixel(),
                  );
                } else {
                  return GestureDetector(
                    child: BlankPixel(),
                    onTap: () {
                      /*
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            content:
                                Text('You clicked index : ' + index.toString()),
                                //Text(playerPos.toString()),
                          );
                        },
                      );
                      */

                      addPlayerPos(index);
                      updateFirebase(index);
                      setState(() {});

                      checkGameGrid();

                      // checking if all the spaces are full
                      if (playerPos.length + player2Pos.length == 9) {
                        if (!anyoneWon) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                content: Text('Game over!'),
                              );
                            },
                          );
                          //clearGrid();
                          clearGridFromDatabase();
                        }
                      }
                      anyoneWon = false;

                      /* old sample winning method
                      if (eq(playerPos, [0, 1, 2])) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              content: Text(checkPlayerTurn(p1Turn) + ' win!'),
                            );
                          },
                        );
                        clearGrid();
                      }
                      */
                    },
                  );
                }
              },
            ),
          ),

          // space for bottom : Debug data
          Expanded(
            child: Container(
              child: Column(
                children: [
                  //Text('Current session\'s code: ' +
                  //widget.currentCode.toString()),
                  Text('Player 1 Position List: ' + playerPos.toString()),
                  Text('Player 2 Position List: ' + player2Pos.toString()),
                  //Text('Turn: ' + checkPlayerTurn(p1Turn)),
                  Text('Database value of player 1 position: ' +
                      databasePlayer1Pos.toString()),
                  Text('Database value of player 2 position: ' +
                      databasePlayer2Pos.toString()),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MaterialButton(
                          child: Text(
                            'clear the grid',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 29, 15, 74),
                            ),
                          ),
                          color: Color.fromARGB(255, 37, 228, 174),
                          onPressed: () {
                            clearGrid();
                          },
                        ),
                        SizedBox(width: 10),
                        MaterialButton(
                          child: Text(
                            'clear the player list',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 29, 15, 74),
                            ),
                          ),
                          color: Color.fromARGB(255, 37, 228, 174),
                          onPressed: () {
                            /*
                            // deleting the loading screen
                            Navigator.of(context).pop();

                            // navigating to the game page
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginPage()));
                            
                            updateGame(false);
                            clearPlayerList();
                            */
                          },
                        ),
                      ],
                    ),
                  ),
                  Text('Doc ID: ' + docId),
                  /*
                  MaterialButton(
                    child: Text(
                      'get data from db',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 29, 15, 74),
                      ),
                    ),
                    color: Color.fromARGB(255, 37, 228, 174),
                    onPressed: () {
                      /*
                      if (databasePlayer1Pos.length == 0) {
                        print('im null');
                        updateDataList();
                      } else {
                        print('im not null');
                      }
                      */
                      updateDataList();
                    },
                  ),*/
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//'Session Code: ' + widget.currentCode.toString(),
