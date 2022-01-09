import 'dart:developer';
import 'package:flutter/material.dart';
// import 'package:sentiment_dart/sentiment_dart.dart';
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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  int _counter = 0;
  String? name;
  bool busy = true;
  String prompt = 'sad';
  List<Artist> artists = [];
  List<TrackSimple> tracks = [];
  List<PlaylistSimple> playlists = [];
  List<AlbumSimple> albums = [];

  _getRecommendations() async{
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

  void changePrompt(newprompt){
    setState(() {
      this.prompt = newprompt;
      artists = [];
      tracks = [];
      playlists = [];
      albums = [];
    });
  }

  Text getCurrentTimeText(){
    TimeOfDay now = TimeOfDay.now();
    if(now.hour < 12){
      return const Text("Good morning!");
    }
    else if (now.hour >= 12 && now.hour <= 18){
      return const Text("Good afternoon!");
    }
    else{
      return const Text("Good evening!");
    }
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

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
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            getCurrentTimeText(),
            ElevatedButton(
              child: Text('Feeling sad?'),
              onPressed: (){changePrompt("sad"); _getRecommendations();},
            ),
            ElevatedButton(
              child: Text('Feeling happy?'),
              onPressed: (){changePrompt("happy");_getRecommendations();},
            ),
            ElevatedButton(
              child: Text('Feeling angry?'),
              onPressed: (){changePrompt("angry");_getRecommendations();},
            ),
            busy ? CircularProgressIndicator() : Text(name ?? 'unknown'),
            // busy ? CircularProgressIndicator() : Text(artist?.name ?? 'unknown'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}