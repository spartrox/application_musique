import 'package:flutter/material.dart';
import 'package:audioplayer2/audioplayer2.dart'; //package que l'on récupère sur le site pub.dev
import 'package:volume/volume.dart'; //package que l'on récupère sur le site pub.dev
import 'musique.dart'; //importation depuis le fichier lib/
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
  List<Musique> musiqueListe = [
    new Musique('Evidemment', 'Kendji GIRAC', 'images/image1.jpg',
        'musiques/Kendji-Girac.mp3'),
    new Musique(
        'Trop beau', 'LOMEPAL', 'images/image2.jpg', 'musiques/lomepa.mp3'),
    new Musique('Longtemps', 'AMIR', 'images/image3.png', 'musiques/amir.mp3'),
  ];

  AudioPlayer audioPlayer;
  StreamSubscription positionSubscription;
  StreamSubscription StateSubscription;

  Musique actualMusique;
  Duration position = new Duration(seconds: 0); // par défaut la musique est a 0
  Duration duree = new Duration(seconds: 30); // Durée de la musique
  PlayerState statut = PlayerState.STOPPED; // La musique sera en pause de base
  int index = 0;
  bool mute = false;
  int maxVol = 0, currentVol = 0;

  // Permet d'initialiser l'application
  @override
  void initState() {
    super.initState();
    actualMusique = musiqueListe[index];
    configAudioPlayer();
    initPlatformState();
    updateVolume();
  }

  @override
  Widget build(BuildContext context) {
    double largeur = MediaQuery.of(context).size.width;
    //int nawVol = getVolumePourcent().toInt();
    return Scaffold(
      appBar: AppBar(
        title: new Text("Application de musique"),
        backgroundColor: Color.fromRGBO(154, 7, 7, 1),
        centerTitle: true,
        elevation: 20,
      ),
      backgroundColor: Colors.grey,
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            new Container(
              width: 250,
              color: Colors.red,
              child: new Image.asset(actualMusique.image),
            ),
            new Container(
              margin: EdgeInsets.only(top: 20),
              child: new Text(
                actualMusique.titre, // Récupere le titre de la musique
                textScaleFactor: 2, // Modifier la taille du texte
                style: new TextStyle(color: Colors.white),
              ),
            ),
            new Container(
              margin: EdgeInsets.only(top: 10),
              child: new Text(
                actualMusique.auteur, // Récupere le nom de l'auteur
                textScaleFactor: 1.5,
                style: new TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            new Container(
              height: largeur / 5,
              margin: EdgeInsets.only(left: 10, right: 10),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  new IconButton(
                      icon: new Icon(Icons.fast_rewind), onPressed: rewind),
                  new IconButton(
                      icon: (statut != PlayerState.PLAYING)
                          ? new Icon(Icons.play_arrow)
                          : new Icon(Icons.pause),
                      onPressed: (statut != PlayerState.PLAYING) ? play : pause,
                      iconSize: 50),
                  new IconButton(
                      icon: (mute)
                          ? new Icon(Icons.headset_off)
                          : new Icon(Icons.headset),
                      onPressed: muted),
                  new IconButton(
                      icon: new Icon(Icons.fast_forward), onPressed: forward),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

// POUR TOUTES LES CHOSES CREE APRES, JE ME SUIS AIDE ET J'AI RECUPERE UN PLUGIN :
// https://pub.dev/packages/volume

  // Pourcentage du volume sur 100
  double getVolumePourcent() {
    return (currentVol / maxVol) * 100;
  }

  //Initialiser le volume
  Future initPlatformState() async {
    //On choisit Stream Music pour bien montrer que l'on veut modifier le volume de la musique et pas de la sonnerie par exemple
    await Volume.controlVolume(AudioManager.STREAM_MUSIC);
  }

  // Update le volume
  updateVolume() async {
    maxVol = await Volume.getMaxVol;
    currentVol = await Volume.getVol;
    setState(() {});
  }

  // Définir le volume
  setVol(int i) async {
    await Volume.setVol(i);
  }

  // Gestion des textes avec styles
  Text textWithStyle(String data, double scale) {
    return new Text(data,
        textScaleFactor: scale,
        textAlign: TextAlign.center,
        style: new TextStyle(color: Colors.black, fontSize: 15.0));
  }

  // Gestion des Boutons
  IconButton bouton(IconData icone, double taille, ActionMusique action) {
    return new IconButton(
        icon: new Icon(icone),
        iconSize: taille,
        color: Colors.white,
        onPressed: () {
          switch (action) {
            case ActionMusique.PLAY:
              play();
              break;
            case ActionMusique.PAUSE:
              pause();
              break;
            case ActionMusique.REWIND:
              rewind();
              break;
            case ActionMusique.FORWARD:
              forward();
              break;
            default:
              break;
          }
        });
  }

  // Configuration de l'AudioPlayer
  void configAudioPlayer() {
    audioPlayer = new AudioPlayer();
    positionSubscription = audioPlayer.onAudioPositionChanged.listen((pos) {
      setState(() {
        position = pos;
      });

      if (position >= duree) {
        position = new Duration(seconds: 0); // Passer à la musique suivante
      }
    });

    StateSubscription = audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == AudioPlayerState.PLAYING) {
        setState(() {
          duree = audioPlayer.duration;
        });
      } else if (state == AudioPlayerState.STOPPED) {
        setState(() {
          statut = PlayerState.STOPPED;
        });
      }
    }, onError: (message) {
      // Si il y a une erreur cela affichera l'erreur et arretera TOUT
      print(message); //
      setState(() {
        statut = PlayerState.STOPPED;
        duree = new Duration(seconds: 0);
        position = new Duration(seconds: 0);
      });
    });
  }

  // Async permet de ne pas attendre qu'une partie soit chager pour charger le reste du code
  // cette fonction permet de récuper et de lancer la musique
  Future play() async {
    await audioPlayer.play(actualMusique.musiqueURL);
    setState(() {
      statut = PlayerState.PLAYING;
    });
  }

// cette fonction permet de mettre en pause la musique
  Future pause() async {
    await audioPlayer.pause();
    setState(() {
      statut = PlayerState.PAUSED;
    });
  }

// cette fonction permet de récuper et de muter la musique
  Future muted() async {
    // Différent de la valeur mute ( variable tout en haut)
    await audioPlayer.mute(!mute);
    setState(() {
      mute = !mute;
    });
  }

// Si la position de la musique est supérieur à 3sec alors on la remet au début
// Sinon on retourne à la musique d'avant
  void rewind() {
    if (position > Duration(seconds: 3)) {
      audioPlayer.seek(0.0); // Remet la musique à zéro
    } else {
      if (index == 0) {
        index = musiqueListe.length - 1;
      } else {
        index--;
      }
      actualMusique = musiqueListe[index];
      audioPlayer.stop();
      configAudioPlayer();
      play();
    }
  }

// Si c'est la première musique de la liste on la remet au début
// Sinon on passe à la musique suivante
  void forward() {
    if (index == musiqueListe.length - 1) {
      index = 0;
    } else {
      index++;
    }
    actualMusique = musiqueListe[index];
    audioPlayer.stop();
    configAudioPlayer();
    play();
  }

  String fromDuration(Duration duree) {
    return duree.toString().split('.').first;
  }
}

// Action sur la musique en cours
enum ActionMusique {
  PLAY, // Démarrer
  PAUSE, // Pause
  REWIND, // Musique d'avant
  FORWARD // Musique d'aprés
}

// Statut que peut avoir la musique
enum PlayerState {
  PLAYING, //
  STOPPED,
  PAUSED
}
