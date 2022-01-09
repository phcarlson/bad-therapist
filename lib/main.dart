import 'dart:developer';
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
        primarySwatch: Colors.blue,
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
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
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
  String prompt = 'sad';
  List<Artist> artists = [];
  List<TrackSimple> tracks = [];
  List<PlaylistSimple> playlists = [];
  List<AlbumSimple> albums = [];
 
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

    print("\nSearching for \'Sad\':");
    var search = await spotify.search
        .get(prompt)
        .first(2)
        .catchError((err) => print((err as SpotifyException).message));
    // if (search == null) {
    //   return;
    // }

    search.forEach((pages) {
      pages.items!.forEach((item) {
        if (item is PlaylistSimple) {
          // print('Playlist: \n'
          //     'id: ${item.id}\n'
          //     'name: ${item.name}:\n'
          //     'collaborative: ${item.collaborative}\n'
          //     'href: ${item.href}\n'
          //     'trackslink: ${item.tracksLink!.href}\n'
          //     'owner: ${item.owner}\n'
          //     'public: ${item.owner}\n'
          //     'snapshotId: ${item.snapshotId}\n'
          //     'type: ${item.type}\n'
          //     'uri: ${item.uri}\n'
          //     'images: ${item.images!.length}\n'
          //     '-------------------------------');
          setState(() {
            playlists.add(item);
          });
        }
        if (item is Artist) {
          // print('Artist: \n'
          //     'id: ${item.id}\n'
          //     'name: ${item.name}\n'
          //     'href: ${item.href}\n'
          //     'type: ${item.type}\n'
          //     'uri: ${item.uri}\n'
          //     '-------------------------------');
          setState(() {
            artists.add(item);
          });
        }
        if (item is TrackSimple) {
          // print('Track:\n'
          //     'id: ${item.id}\n'
          //     'name: ${item.name}\n'
          //     'href: ${item.href}\n'
          //     'type: ${item.type}\n'
          //     'uri: ${item.uri}\n'
          //     'isPlayable: ${item.isPlayable}\n'
          //     'artists: ${item.artists!.length}\n'
          //     'availableMarkets: ${item.availableMarkets!.length}\n'
          //     'discNumber: ${item.discNumber}\n'
          //     'trackNumber: ${item.trackNumber}\n'
          //     'explicit: ${item.explicit}\n'
          //     '-------------------------------');
          setState(() {
            tracks.add(item);
          });
        }
        if (item is AlbumSimple) {
          // print('Album:\n'
          //     'id: ${item.id}\n'
          //     'name: ${item.name}\n'
          //     'href: ${item.href}\n'
          //     'type: ${item.type}\n'
          //     'uri: ${item.uri}\n'
          //     'albumType: ${item.albumType}\n'
          //     'artists: ${item.artists!.length}\n'
          //     'availableMarkets: ${item.availableMarkets!.length}\n'
          //     'images: ${item.images!.length}\n'
          //     'releaseDate: ${item.releaseDate}\n'
          //     'releaseDatePrecision: ${item.releaseDatePrecision}\n'
          //     '-------------------------------');
          setState(() {
            albums.add(item);
            name = item.name;
            this.busy = false;
          });
        }
      });
    });
  }

  void getMood(prompt){
     Map resultingMood = sentiment.analysis(prompt);
    String mood = "";
    double comp = resultingMood['comparative'];
    if(comp == 1){
      mood = 'psyched';
    }
    else if (comp < 1 && comp >= 0.9){
      mood = 'great';
    }
    else if (comp < 0.9 && comp >= 0.7){
      mood = 'feeling good';
    }
    else if (comp < 0.7 && comp >= 0.5){
      mood = 'doing well';
    }
    else if (comp < 0.5 && comp >= 0.3){
      mood = 'okey dokey';
    }
    else if (comp < 0.3 && comp >= 0.1){
      mood = 'shrug';
    }
    else if (comp < 0.1 && comp >= 0){
      mood = 'whatever';
    }
    else if (comp < 0 && comp >= -0.1){
      mood = 'meh';
    }
    else if (comp < -0.1 && comp >= -0.3){
      mood = 'bluh';
    }
    else if (comp < -0.3 && comp >= -0.5){
      mood = 'doing poor';
    }
    else if (comp < -0.5 && comp >= -0.7){
      mood = 'not well';
    }
    else if (comp < -0.7 && comp >= -0.9){
      mood = 'bad times';
    }
    else{
      mood = "horrible";
    }
    changePrompt(mood);
    _getRecommendations();
  }

  void changePrompt(newprompt) {
    setState(() {
      this.prompt = newprompt;
      artists = [];
      tracks = [];
      playlists = [];
      albums = [];
    });
  }

  Text getCurrentTimeText() {
    TimeOfDay now = TimeOfDay.now();
    if (now.hour < 12) {
      return const Text("Good morning!");
    } else if (now.hour >= 12 && now.hour <= 18) {
      return const Text("Good afternoon!");
    } else {
      return const Text("Good evening!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome To Today's Therapy Session"),
      ),
      body: Center(
        child:
            // Row(mainAxisAlignment: MainAxisAlignment.center,
            //     children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              myTherapist,
              getCurrentTimeText(),
              // ElevatedButton(
              //     child: Text('Hate me?'), onPressed: _getNewTherapist),
              busy ? CircularProgressIndicator() : Text(name ?? 'unknown'),
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
        // ]),
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
