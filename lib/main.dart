import 'dart:developer';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/image.dart' as Image;
import 'package:http/http.dart' as http;
import 'package:dart_sentiment/dart_sentiment.dart';
import 'package:spotify/spotify.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Relief',
      theme: ThemeData(
        primarySwatch: Colors.brown
      ),
      home: const MyHomePage(title: "How Can You Find Relief?"),
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
      body: Center(
        child: Column(
          children: [
            TextButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => TherapyPage()));
              },
              child: Text("Therapy Now"),
            )
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
    return const therapy();
  }
}

class therapy extends StatefulWidget {
  const therapy({Key? key}) : super(key: key);

  @override
  _therapyState createState() => _therapyState();
}

class _therapyState extends State<therapy> {
  final sentiment = Sentiment();
  String? name;
  bool hateTherapist = false;
  bool busy = true;
  CircleAvatar myTherapist = const CircleAvatar(
    radius: 80.0,
    backgroundImage:
    NetworkImage('https://thispersondoesnotexist.com/image?=0'),
    backgroundColor: Colors.transparent,
  );
  String prompt = 'neutral';
  List<Artist> artists = [];
  List<TrackSimple> tracks = [];
  List<PlaylistSimple> playlists = [];
  List<AlbumSimple> albums = [];
  Color color = Colors.grey;
  // _getNewTherapist() async{
  //   // var url = Uri.parse('https://thispersondoesnotexist.com/image?=0');
  //   // var response = await http.get(url);
  //   //
  //   //
  //   setState(() {
  //      myTherapist = await const CircleAvatar(
  //       radius: 80.0,
  //       backgroundImage:
  //           NetworkImage('https://thispersondoesnotexist.com/image?=0'),
  //       backgroundColor: Colors.transparent,
  //     );
  //   });
  // }

  _getRecommendations() async {
    setState(() {
      this.busy = true;
    });

    print("\nSearching for $prompt:");
    var search = await spotify.search
        .get(prompt)
        .first(15)
        .catchError((err) => print((err as SpotifyException).message));
    if (search == null) {
      return;
    }

    for (var pages in search) {
      for (var item in pages.items!) {
        if (item is PlaylistSimple) {
          print('Playlist: \n'
              'id: ${item.id}\n'
              'name: ${item.name}:\n'
              'collaborative: ${item.collaborative}\n'
              'href: ${item.href}\n'
              'trackslink: ${item.tracksLink!.href}\n'
              'owner: ${item.owner}\n'
              'public: ${item.owner}\n'
              'snapshotId: ${item.snapshotId}\n'
              'type: ${item.type}\n'
              'uri: ${item.uri}\n'
              'images: ${item.images!.length}\n'
              '-------------------------------');
          // setState(() {
          //   playlists.add(item);
          // });
        }
        if (item is Artist) {
          print('Artist: \n'
              'id: ${item.id}\n'
              'name: ${item.name}\n'
              'href: ${item.href}\n'
              'type: ${item.type}\n'
              'uri: ${item.uri}\n'
              '-------------------------------');
          // setState(() {
          //   artists.add(item);
          // });
        }
        if (item is TrackSimple) {
          tracks.add(item);
        if(tracks.isNotEmpty){print(tracks.elementAt(0).name);}
        print('Track:\n'
              'id: ${item.id}\n'
              'name: ${item.name}\n'
              'href: ${item.href}\n'
              'type: ${item.type}\n'
              'uri: ${item.uri}\n'
              'isPlayable: ${item.isPlayable}\n'
              'artists: ${item.artists!.length}\n'
              'availableMarkets: ${item.availableMarkets!.length}\n'
              'discNumber: ${item.discNumber}\n'
              'trackNumber: ${item.trackNumber}\n'
              'explicit: ${item.explicit}\n'
              '-------------------------------');
          setState(() {
          });
        }
        // if (item is AlbumSimple) {
        //   print('Album:\n'
        //       'id: ${item.id}\n'
        //       'name: ${item.name}\n'
        //       'href: ${item.href}\n'
        //       'type: ${item.type}\n'
        //       'uri: ${item.uri}\n'
        //       'albumType: ${item.albumType}\n'
        //       'artists: ${item.artists!.length}\n'
        //       'availableMarkets: ${item.availableMarkets!.length}\n'
        //       'images: ${item.images!.length}\n'
        //       'releaseDate: ${item.releaseDate}\n'
        //       'releaseDatePrecision: ${item.releaseDatePrecision}\n'
        //       '-------------------------------');
        //   // setState(() {
        //   //   albums.add(item);
        //   //   name = item.name;
        //   //   this.busy = false;
        //   // });
        // }
      }
    }
    setState(() {
      tracks = tracks.map((e) => e).toList();
      final _random = new Random();
       name = tracks[_random.nextInt(tracks.length)].name;
      this.busy = false;
    });
  }

  void getMood(prompt){
    Map resultingMood = sentiment.analysis(prompt);
    String mood = "";
    double comp = resultingMood['comparative'];
    print(comp);
    if(comp >= 1){
      mood = 'psyched';
      setState(() {
        prompt = 'feel good songs';
        color = Color(0xE8FF9B00);
      });
    }
    else if (comp < 1 && comp >= 0.9){
      mood = 'great';
      setState(() {
        prompt = 'the beatles';
        color = Color(0xE8FAA61E);
      });

    }
    else if (comp < 0.9 && comp >= 0.7){
      // mood = 'feeling good';
      setState(() {
        prompt = 'the beatles';
        color = Color(0xE8E3AF54);
      });

    }
    else if (comp < 0.7 && comp >= 0.5){
      mood = 'doing well';
      setState(() {
        color = Color(0xE8BFA173);
      });

    }
    else if (comp < 0.5 && comp >= 0.3){
      // mood = 'okey dokey';
      mood = 'sunshine';
      setState(() {
        prompt = 'the beatles';
        color = Color(0xE88D765B);
      });
    }
    else if (comp < 0.3 && comp >= 0.1){
      mood = 'shrug';
      setState(() {
        prompt = 'the beatles';
        color = Color(0xE88D7F60);
      });
    }
    else if (comp < 0.1 && comp >= 0){
      mood = 'whatever';
      setState(() {
        prompt = 'the beatles';
        color = Color(0xE88B8173);
      });
    }
    else if (comp < 0 && comp >= -0.1){
      mood = 'meh';
      setState(() {
        prompt = 'the beatles';
        color = Color(0xE846505F);
      });
    }
    else if (comp < -0.1 && comp >= -0.3){
      mood = 'bluh';
      setState(() {
        prompt = 'the beatles';
        color = Color(0xE8293544);
      });
    }
    else if (comp < -0.3 && comp >= -0.5){
      mood = 'doing poor';
      setState(() {
        prompt = 'the beatles';
        color = Color(0xE8212834);
      });
    }
    else if (comp < -0.5 && comp >= -0.7){
      mood = 'not well';
      setState(() {
        prompt = 'the beatles';
        color = Color(0xE8241C1F);
      });
    }
    else if (comp < -0.7 && comp >= -0.9){
      mood = 'bad times';
      setState(() {
        prompt = 'the beatles';
        color = Color(0xE8230007);
      });
    }

    else{
      mood = "horrible";
      setState(() {
        prompt = 'the beatles';
        color = Color(0xE8680000);
    });
    }
    changePrompt(prompt);
    _getRecommendations();
  }

  void changePrompt(String newprompt) {
    setState(() {
      this.prompt = newprompt;
      print(this.prompt);
      artists = [];
      tracks = [];
      playlists = [];
      albums = [];
    });
  }

  Text getCurrentTimeText() {
    TimeOfDay now = TimeOfDay.now();

    print("THE HOUR IS ${now.hour}");
    if (now.hour < 12) {
      return const Text("Good morning!");
    } else if (now.hour >= 12 && now.hour <= 18) {
      return const Text("Good afternoon!");
    } else {
      return const Text("Good evening!");
    }
  }

  // Color _getMoodColor(r, g, b){
  //   // return Color.fromRGBO(r, g, b, 1.0);
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color,
      appBar: AppBar(
        title: const Text("Welcome To Today's Therapy Session"),
      ),
      body: Center(
        child:
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            myTherapist,
            getCurrentTimeText(),
            // ElevatedButton(
            //     child: Text('Hate me?'), onPressed: _getNewTherapist),
            busy ? CircularProgressIndicator() : Text(name ?? 'Your feelings are complicated...'),
            TextField(
                controller: _controller,
                onSubmitted: (String value)  {
                  getMood(value);
                  // changePrompt(value);
                  // _getRecommendations();
                }
            ),
          ],
        ),
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