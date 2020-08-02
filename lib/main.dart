import 'dart:convert';
// import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:random_color/random_color.dart';
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:http/http.dart' as http;
import 'package:faker/faker.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Jokes and Ninjas',
        home: MyHomePage(title: 'Get Random Jokes'),
        theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            scaffoldBackgroundColor: Colors.black87));
  }
}

// RANDOM JOKE
Future<RandomJoke> fetchRandomJoke() async {
  final response =
      await http.get('https://official-joke-api.appspot.com/random_joke');
  if (response.statusCode == 200) {
    return RandomJoke.fromJson(json.decode(response.body));
  } else
    throw Exception('Failed to get Joke');
}

class RandomJoke {
  final int id;
  final String type;
  final String jokeSetup;
  final String jokePunchline;
  RandomJoke({this.id, this.type, this.jokeSetup, this.jokePunchline});
  factory RandomJoke.fromJson(Map<String, dynamic> json) {
    return RandomJoke(
        id: json['id'],
        type: json['type'],
        jokeSetup: json['setup'],
        jokePunchline: json['punchline']);
  }
}

// DAD JOKE
// Future<DadJoke> fetchDadJoke() async {
//   final response = await http.get('https://icanhazdadjoke.com/',
//       headers: {HttpHeaders.acceptHeader: "application/json"});
//   if (response.statusCode == 200) {
//     return DadJoke.fromJson(json.decode(response.body));
//   } else
//     throw Exception('Failed to get Joke');
// }

// class DadJoke {
//   final String id;
//   final String joke;
//   DadJoke({this.id, this.joke});
//   factory DadJoke.fromJson(Map<String, dynamic> json) {
//     return DadJoke(id: json['id'], joke: json['joke']);
//   }
// }

///////// HomePage ///////////////

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _wordPair = WordPair.random().asPascalCase;
  Future<RandomJoke> futureJoke;
  final RandomColor colorGenerator = RandomColor();
  final japsuffix = ['san', 'sama', 'kun', 'chan'];
  String copytext = '';

  @override
  void initState() {
    super.initState();
    futureJoke = fetchRandomJoke();
  }

  void _getNewWordPair() {
    setState(() {
      _wordPair = WordPair.random().asPascalCase;
      futureJoke = fetchRandomJoke();
    });
  }

  void copyJoketoClip() {
    Clipboard.setData(ClipboardData(text: copytext));
    Fluttertoast.showToast(
        msg: "Copied",
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        textColor: Colors.black87,
        fontSize: 16.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // JOKE ID
              FutureBuilder<RandomJoke>(
                future: futureJoke,
                builder: (context, snapshot) {
                  if (snapshot.hasData)
                    return Text(
                        '${faker.internet.userName()}\'s joke no.${snapshot.data.id}',
                        style: TextStyle(fontSize: 20, color: Colors.grey));
                  else if (snapshot.hasError) return Text("${snapshot.error}");
                  return CircularProgressIndicator();
                },
              ),
              SizedBox(height: 32),
              // JOKE
              FutureBuilder<RandomJoke>(
                future: futureJoke,
                builder: (context, snapshot) {
                  if (snapshot.hasData &&
                      snapshot.connectionState == ConnectionState.done) {
                    copytext = snapshot.data.jokeSetup +
                        '\n\n' +
                        snapshot.data.jokePunchline;
                    return Text(
                      copytext,
                      style: TextStyle(
                        fontSize: 35,
                        color: colorGenerator.randomColor(
                            colorBrightness: ColorBrightness.veryLight),
                      ),
                    );
                  } else if (snapshot.hasError)
                    return Text("${snapshot.error}");
                  return LinearProgressIndicator();
                },
              ),
              SizedBox(height: 48),
              Text(
                '\nYour secret Ninja codename is...\n',
                style: TextStyle(color: Colors.grey),
              ),
              Text(
                '$_wordPair-' + japsuffix[Random().nextInt(4)],
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                    fontSize: 20),
              ),
              SizedBox(height: 96),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Row(
            textDirection: TextDirection.rtl,
            children: <Widget>[
              FloatingActionButton(
                onPressed: _getNewWordPair,
                tooltip: 'Get a new Random Joke',
                child: Icon(Icons.fiber_new),
              ),
              SizedBox(width: 16),
              FloatingActionButton(
                onPressed: copyJoketoClip,
                tooltip: 'Copy Joke to Clipboard',
                child: Icon(Icons.content_copy),
              ),
            ],
          )),
    );
  }
}
