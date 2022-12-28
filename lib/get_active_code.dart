import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tictactoe_app/login_page.dart';
import 'globals.dart';

class GetActiveCode extends StatelessWidget {
  final String documentId;
  //static List<String> codeList = [];
  //LoginPage loginPage = new LoginPage();

  GetActiveCode({required this.documentId});

  //List returnCodeList() {
  //return codeList;
  //}

  @override
  Widget build(BuildContext context) {
    // get the collection
    CollectionReference activeCodes =
        FirebaseFirestore.instance.collection('activeCodes');
    return FutureBuilder<DocumentSnapshot>(
      future: activeCodes.doc(documentId).get(),
      builder: ((context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          //codeList.add('${data['code']}');
          //print(returnCodeList());
          codeList.add('${data['code']}');
          //print(codeList);
          return Text(''); //Text('Code is: ${data['code']}');
        }
        return const Text(''); //Text('loading..');
      }),
    );
  }
}
