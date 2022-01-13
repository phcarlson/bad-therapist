import 'dart:developer';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/image.dart' as Image;
import 'package:http/http.dart' as http;
import 'package:dart_sentiment/dart_sentiment.dart';
import 'package:spotify/spotify.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_2.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bad Therapist',
      theme: ThemeData(primarySwatch: Colors.brown),
      initialRoute: '/',
      routes: {
        // When navigating to the "/" route, build the MyHomePage widget.
        '/': (context) => const MyHomePage(title: "How Can You Find Relief?"),
        '/second': (context) => const TherapyPage(),
        // When navigating to the "/second" route, build the TherapyPage widget.
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      //TODO: create official layout to home page
      body: Center(
        child: Column(
          children: [
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, "/second");
              },
              child: Text("Therapy Now"),
            ),
          ],
        ),
      ),
    );
  }
}

class TherapyPage extends StatelessWidget {
  const TherapyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Therapy();
  }
}

class Therapy extends StatefulWidget {
  const Therapy({Key? key}) : super(key: key);

  @override
  _TherapyState createState() => _TherapyState();
}

class _TherapyState extends State<Therapy> {
  bool _sent = false;
  final _sentiment = Sentiment();
  String? _name;
  int _encounter = 1;
  bool _isBusy = true;
  String _prompt = 'whatever';
  String _mood = 'average';
  List<Artist> _artists = [];
  List<TrackSimple> _tracks = [];
  List<PlaylistSimple> _playlists = [];
  List<AlbumSimple> _albums = [];
  Color _color = Colors.grey; //grey when neutral initially
  String _whatYouSaid = "";
  final CircleAvatar _myTherapist = const CircleAvatar(
    radius: 80.0,
    backgroundImage:
        NetworkImage('https://thispersondoesnotexist.com/image?=0'),
    backgroundColor: Colors.transparent,
  );

  final _spotify = SpotifyApi(SpotifyApiCredentials(
      "277c67cd809041edaa8e85f4f130e29f", "b1c4ab57b7794f7d8ee81fea5ff52c85"));

  //the actual act of searching for the tracks based on the fresh prompt
  _getRecommendations() async {
    setState(() {
      _isBusy = true;
    });

    print("\nSearching for $_prompt:");
    var search = await _spotify.search
        .get(_prompt)
        .first(15)
        .catchError((err) => print((err as SpotifyException).message));
    if (search == null) {
      return;
    }

    for (var pages in search) {
      for (var item in pages.items!) {
        if (item is PlaylistSimple) {
          _playlists.add(item);
        }
        if (item is Artist) {
          _artists.add(item);
        }
        if (item is TrackSimple) {
          _tracks.add(item);
        }
        if (item is AlbumSimple) {
          _albums.add(item);
        }
      }
    }
    setState(() {
      _tracks = _tracks.map((e) => e).toList();
      _playlists = _playlists.map((e) => e).toList();
      final _random = Random();
      _name = _tracks[_random.nextInt(_tracks.length)].name;
      _isBusy = false;
    });
  }
//TODO: change conditions
  void _getMood(prompt) {
    Map resultingMood = _sentiment.analysis(prompt);
    double comp = resultingMood['comparative'];
    //determine what list of tracks to suggest from
    if (comp >= 1) {
      setState(() {
        _mood = 'are at the top of the world';
        prompt = 'powerful songs';
        _color = Color(0xE8FF9B00);
      });
    } else if (comp < 1 && comp >= 0.9) {
      setState(() {
        _mood = 'are more than great';
        prompt = 'feel good songs';
        _color = Color(0xE8FAA61E);
      });
    } else if (comp < 0.9 && comp >= 0.7) {
      setState(() {
        _mood = 'are feeling great';
        prompt = 'positive songs';
        _color = Color(0xE8E3AF54);
      });
    } else if (comp < 0.7 && comp >= 0.5) {
      setState(() {
        _mood = 'doing well';
        prompt = '60s pop';
        _color = Color(0xE8BFA173);
      });
    } else if (comp < 0.5 && comp >= 0.3) {
      setState(() {
        _mood = 'better than usual';
        prompt = 'the beatles';
        _color = Color(0xE88D765B);
      });
    } else if (comp < 0.3 && comp >= 0.1) {
      setState(() {
        _mood = 'one big shrug, but not bad';
        prompt = 'mood boosters';
        _color = Color(0xE88D7F60);
      });
    } else if (comp < 0.1 && comp >= 0) {
      setState(() {
        _mood = 'feeling whatever';
        prompt = 'daily';
        _color = Color(0xE88B8173);
      });
    } else if (comp < 0 && comp >= -0.1) {
      setState(() {
        _mood = 'doing meh';
        prompt = 'neutral tracks';
        _color = Color(0xE846505F);
      });
    } else if (comp < -0.1 && comp >= -0.3) {
      setState(() {
        _mood = 'feeling off';
        prompt = 'mac demarco';
        _color = Color(0xE8293544);
      });
    } else if (comp < -0.3 && comp >= -0.5) {
      _mood = 'a bit worse than usual';
      setState(() {
        prompt = 'sad pop';
        _color = Color(0xE8212834);
      });
    } else if (comp < -0.5 && comp >= -0.7) {
      setState(() {
        _mood = 'not doing well';
        prompt = 'sad songs';
        _color = Color(0xE8241C1F);
      });
    } else if (comp < -0.7 && comp >= -0.9) {
      setState(() {
        _mood = 'going through bad times';
        prompt = 'depressing music';
        _color = Color(0xE8230007);
      });
    } else {
      setState(() {
        _mood = "feeling horrible";
        prompt = 'forever alone';
        _color = Color(0xE8680000);
      });
    }
    _changePrompt(prompt);
    _getRecommendations();
  }

  //wipes the lists for the next prompt which could be a different emotion
  void _changePrompt(String newprompt) {
    setState(() {
      _prompt = newprompt;
      _artists = [];
      _tracks = [];
      _playlists = [];
      _albums = [];
    });
  }

  //specialize the conversation based on time of day
  String _getCurrentTimeText() {
    String response;
    TimeOfDay _now = TimeOfDay.now();
    // print("THE HOUR IS ${now.hour}");
    if (_now.hour < 12) {
      switch (_encounter) {
        case 1:
          {
            response =
                "Good morning! Ya awake enough? Tell me how you're feeling.";
          }
          break;
        case 2:
          {
            response = "Now we're waking up. Keep going.";
          }
          break;
        case 3:
          {
            response = "All this and the day just started, uhuh.";
          }
          break;
        default:
          response = "Mhm....";
      }
    } else if (_now.hour >= 12 && _now.hour < 18) {
      switch (_encounter) {
        case 1:
          {
            response =
                "Good afternoon! Hope things are good so far. Let it all out to me.";
          }
          break;
        case 2:
          {
            response = "Ready for lunch yet? I'm kidding, keep talking.";
          }
          break;
        case 3:
          {
            response =
                "There's a lot left to the day if you wanted to leave. Or keep going.";
          }
          break;
        default:
          response = "Mhm....mhm.......";
      }
    } else {
      switch (_encounter) {
        case 1:
          {
            response = "Good evening! Long day? Lemme hear it.";
          }
          break;
        case 2:
          {
            response = "Ready for dinner yet? Bed? I'm kidding, keep talking.";
          }
          break;
        case 3:
          {
            response = "Yeah so uhhh anything else...? Kid's waiting at home.";
          }
          break;
        default:
          response = "Mhm....mhm.....yawn..";
      }
    }
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _color,
      appBar: AppBar(
        title: const Text("Welcome To Today's Therapy Session"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _myTherapist,
          ChatBubble(
            clipper: ChatBubbleClipper2(type: BubbleType.receiverBubble),
            alignment: Alignment.topLeft,
            margin: EdgeInsets.only(top: 20),
            backGroundColor: Colors.blue,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              child: Text(_getCurrentTimeText()),
            ),
          ),
          _sent
              ? ChatBubble(
                  clipper: ChatBubbleClipper2(type: BubbleType.sendBubble),
                  alignment: Alignment.topRight,
                  margin: EdgeInsets.only(top: 20),
                  backGroundColor: Colors.blue,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    child: Text(
                      _whatYouSaid,
                      // style: const TextStyle(fontSize: 20)),
                    ),
                  ),
                )
              : const SizedBox(
                  width: 200.0,
                  height: 20,
                ),
          _isBusy
              ? const SizedBox(
                  width: 200.0,
                  height: 20,
                )
              : ChatBubble(
                  clipper: ChatBubbleClipper2(type: BubbleType.receiverBubble),
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.only(top: 20),
                  backGroundColor: Colors.blue,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    child: Text(
                      "It sounds like you are $_mood. Might I recommend you amplify that feeling with " +
                          (_name == null
                              ? "uhhh well your feelings are complicated"
                              : _name!),
                      // style: const TextStyle(fontSize: 20)),
                    ),
                  ),
                ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            child: TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Spill what you feel',
                ),
                controller: _controller,
                onSubmitted: (String value) {
                  _whatYouSaid = value;
                  _getMood(value);
                  setState(() {
                    _sent = true;
                    _encounter++;
                  });
                  // changePrompt(value);
                  // _getRecommendations();
                }),
          ),
        ],
      ),
    );
  }

  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
