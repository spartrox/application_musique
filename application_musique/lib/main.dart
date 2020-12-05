import 'package:flutter/material.dart';
import 'package:audioplayer2/audioplayer2.dart'; //package que l'on récupère sur le site pub.dev
import 'package:volume/volume.dart'; //package que l'on récupère sur le site pub.dev
import 'musique.dart'; //importation depuis le fichier lib/
import 'package:flutter/services.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "Application Musique",
      theme: new ThemeData(primarySwatch: Colors.blueGrey),
      debugShowCheckedModeBanner: false, // Enlever la banniere
      home: new Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _Home();
  }
}

class _Home extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text("Application de musique"),
        backgroundColor: Colors.red,
        centerTitle: true,
        elevation: 20,
      ),
      backgroundColor: Colors.grey,
      body: new Center(
        child: new Container(
          child: new Column(),
        ),
      ),
    );
  }
}
