import 'dart:convert';
import 'dart:math';
import 'package:random_color/random_color.dart';
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:http/http.dart' as http;
import 'package:faker/faker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jokes and Ninjas',
      home: MyHomePage(title: 'Random Jokes and Names'),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}

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
                      snapshot.connectionState == ConnectionState.done)
                    return Stack(
                      children: <Widget>[
                        // Stroked text as border.
                        Text(
                          snapshot.data.jokeSetup +
                              '\n\n' +
                              snapshot.data.jokePunchline,
                          style: TextStyle(
                            fontSize: 35,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 1
                              ..color = Colors.black,
                          ),
                        ),
                        // Solid text as fill.
                        Text(
                          snapshot.data.jokeSetup +
                              '\n\n' +
                              snapshot.data.jokePunchline,
                          style: TextStyle(
                            fontSize: 35,
                            color: colorGenerator.randomColor(),
                          ),
                        ),
                      ],
                    );
                  else if (snapshot.hasError) return Text("${snapshot.error}");
                  return LinearProgressIndicator();
                },
              ),
              SizedBox(height: 64),
              Text(
                '\nYour secret Ninja codename is...\n',
              ),
              Text(
                '$_wordPair-' + japsuffix[Random().nextInt(4)],
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                    fontSize: 20),
              ),
              SizedBox(height: 96)
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getNewWordPair,
        tooltip: 'Get a new Ninja name',
        child: Icon(Icons.fiber_new),
      ),
    );
  }
}
