import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import '../main.dart';
import 'HomePage.dart' show MatButton;
import 'dart:async';
import 'PlayerPage.dart';

final txtFile = File("/sdcard/txtFle.txt");

class ShowPage extends StatefulWidget {
  late List<Map<String, String>> songList;

  ShowPage(List<Map<String, String>> songs) {
    songList = songs;
  }

  @override
  State<ShowPage> createState() => ShowPageState(songs: songList);
}

class ShowPageState extends State<ShowPage> {
  final player = AudioPlayer();
  late var artist = "by rahul";
  late var title = "MusicX";
  int _currentIndex = 0;
  var _currentIcon = Icons.play_arrow;
  late List<Map<String, String>> songdetails;
  late Timer timer;

  ShowPageState({List<Map<String, String>> songs = const []}) {
    songdetails = songs;
  }
  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        actions: [
          MatButton(() {
            prev();
          }, Icons.skip_previous_rounded),
          IconButton(
            splashColor: Colors.blue,
            
            onPressed: () {
              playorpause();
            },
            icon: Icon(_currentIcon,),
          ),
          MatButton(() {
            next();
          }, Icons.skip_next_rounded),
        ],
        title: InkWell(
          onTap: () {
            if (txtFile.existsSync()) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          PlayerPage(player, songdetails))).then((value) {
                var data = loadSavedDetails();
                setState(() {
                  artist = data["artist"];
                  title = data["title"];
                });

                if (player.playing) {
                  setState(() {
                    _currentIcon = Icons.pause_rounded;
                  });
                } else {
                  setState(() {
                    _currentIcon = Icons.play_arrow_rounded;
                  });
                }
              });
            }
          },
          child: Container(
            width: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),
                const SizedBox(
                  height: 7,
                ),
                Text(
                  artist,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: WillPopScope(
          onWillPop: () {
            SystemNavigator.pop();
            return Future.value(false);
          },
          child: Column(
            children: [
              Expanded(
                child: SizedBox(
                  height: double.maxFinite,
                  width: double.maxFinite,
                  child: RefreshIndicator(
                    onRefresh: () {
                      RestartWidget.restartApp(context);
                      player.dispose();
                      return Future.value();
                    },
                    child: ListView.builder(
                      itemCount: songdetails.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          onTap: () {
                            _currentIndex = index;
                            loadSong(songdetails[index]);
                            saveDetails(
                                {...songdetails[index], 'index': index});
                          },
                          title: Text(songdetails[index]["title"]!),
                          subtitle: Text(songdetails[index]["artist"]!),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {


    if (txtFile.existsSync()) {
      String content = txtFile.readAsStringSync();
      Map data = jsonDecode(content);
      artist = data["artist"];
      title = data["title"];
      _currentIndex = data["index"];
      setState(() {});
      loadSong(data, autostart: false);
    }

    super.initState();
  }

  void next() {
    if (_currentIndex >= (songdetails.length - 1)) {
      _currentIndex = -1;
    }
    ++_currentIndex;
    loadSong(songdetails[_currentIndex]);
  }

  void prev() {
    if (_currentIndex == 0) {
      _currentIndex = songdetails.length;
    }
    --_currentIndex;
    loadSong(songdetails[_currentIndex]);
  }

  void loadSong(Map detail, {bool autostart = true}) {
    player.setUrl(detail["path"]!);
    if (autostart) {
      player.play();
      setState(() {
        _currentIcon = Icons.pause;
      });
    }
    setState(() {
      artist = detail["artist"]!;
      title = detail["title"]!;
    });
    saveDetails({...detail, "index": _currentIndex});
  }

  void playorpause() {
    if (player.playing) {
      player.pause();
      setState(() {
        _currentIcon = Icons.play_arrow;
      });
    } else {
      setState(() {
        _currentIcon = Icons.pause;
      });

      player.play();
    }
  }

}

void saveDetails(songdetail) {
  if (!txtFile.existsSync()) {
    txtFile.createSync();
  }
  String data = jsonEncode(songdetail);
  txtFile.writeAsStringSync(data);
}

Map loadSavedDetails() {
  Map data = jsonDecode(txtFile.readAsStringSync()) as Map;
  return data;
}
