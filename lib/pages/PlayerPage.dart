import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:audiotagger/audiotagger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:just_audio/just_audio.dart';

class PlayerPage extends StatefulWidget {
  late final AudioPlayer pg;
  late final List li;
  PlayerPage(AudioPlayer p, List<Map<String, String>> l) {
    pg = p;
    li = l;
  }
  @override
  State<PlayerPage> createState() => _PlayerPageState(pg, li);
}

class _PlayerPageState extends State<PlayerPage> {
  late final AudioPlayer player;
  late final List songdetails;
  late double _value;

  bool _visible = true;

  _PlayerPageState(AudioPlayer p, List dl) {
    player = p;
    songdetails = dl;
    _value = p.volume;
  }
  late final txtFile = File("/sdcard/txtFle.txt");
  final tagger = Audiotagger();
  late int _currentIndex;
  late IconData _currentIcon;
  late IconData _loopIcon;

  var backBlurImage = const DecorationImage(
    image: ExactAssetImage('image/image1.jpg'),
    fit: BoxFit.cover,
  );

  var duration = "0:00";
  var positon = "0:00";

  var frontImge = const Image(
    height: 270,
    width: 270,
    image: AssetImage("image/image1.jpg"),
  );
  var value = 0.0;
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
    ));
    var screenwidth = MediaQuery.of(context).size.width;
    if (player.playing) {
      setState(() {
        _currentIcon = Icons.pause_rounded;
      });
    } else {
      setState(() {
        _currentIcon = Icons.play_arrow_rounded;
      });
    }

    if (player.loopMode == LoopMode.off) {
      _loopIcon = Icons.repeat_one_sharp;
    } else {
      _loopIcon = Icons.repeat_one_on_rounded;
    }
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        elevation: 0,
        actions: [
          IconButton(
              onPressed: () {
                setuploop();
              },
              icon: Icon(_loopIcon)),
          IconButton(
              tooltip: "Info",
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text(
                          "Properties",
                          style: TextStyle(fontSize: 22),
                        ),
                        content: Container(
                          height: 400,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  "Artist : ${songdetails[_currentIndex]['artist']}"),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                  "Title : ${songdetails[_currentIndex]['title']}"),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                  "Album : ${songdetails[_currentIndex]['album']}"),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                  "Genre : ${songdetails[_currentIndex]['genre']}"),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                  "Year : ${songdetails[_currentIndex]['year']}"),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                  "Path : ${songdetails[_currentIndex]['path']}"),
                              const Spacer(),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  width: 90,
                                  child: ElevatedButton(
                                    child: Row(
                                      children: const [
                                        Icon(Icons.close),
                                        SizedBox(
                                          width: 1,
                                        ),
                                        Text("close")
                                      ],
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    });
              },
              icon: Icon(Icons.info)),
        ],
        backgroundColor: Colors.transparent.withOpacity(0),
      ),
      body: WillPopScope(
        onWillPop: () {
          if (!_visible) {
            setState(() {
              _visible = !_visible;
            });
          } else {
            Navigator.pop(context);
          }
          return Future.value(false);
        },
        child: SafeArea(
          child: Stack(
            children: [
              Container(
                height: double.maxFinite,
                width: double.maxFinite,
                decoration: BoxDecoration(image: backBlurImage),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 50.0, sigmaY: 50.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 186, 184, 184)
                            .withOpacity(0.0)),
                  ),
                ),
              ),
              Positioned(
                top: 50,
                left: (screenwidth / 2) - (frontImge.width!.toInt() / 2),
                child: Visibility(
                  visible: _visible,
                  replacement: Container(
                    color: Colors.transparent,
                    width: 270,
                    child: Slider(
                      max: 1,
                      min: 0,
                      onChanged: (newValue) {
                        setState(() {
                          _value = newValue;
                          player.setVolume(newValue);
                        });
                      },
                      value: _value,
                    ),
                  ),
                  child: Container(
                    alignment: Alignment.topCenter,
                    child: InkWell(
                        child: frontImge,
                        onTap: () {
                          setState(() {
                            _visible = false;
                          });
                        }),
                  ),
                ),
              ),
              Positioned(
                top: 350,
                left: 12,
                child: Row(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      width: 45,
                      child: MidText(positon),
                    ),
                    SizedBox(
                      width: 240,
                      child: Slider(
                        activeColor: Colors.cyan[800],
                        inactiveColor: Colors.white,
                        value: value,
                        max: 100,
                        min: 0,
                        onChanged: (newValue) {
                          if (newValue <= 100) {
                            setState(() => value = newValue);
                          }
                          player.seek(secToMinSec(
                              (player.duration!.inSeconds * newValue) ~/ 100));
                        },
                      ),
                    ),
                    MidText(duration)
                  ],
                ),
              ),
              Positioned(
                bottom: 180,
                left: (screenwidth / 2) - (180 / 2),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        prev();
                      },
                      child:const  Icon(
                        Icons.skip_previous_rounded,
                        color: Color.fromARGB(255, 156, 189, 216),
                        size: 60,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        playorpause();
                      },
                      child: Icon(
                        _currentIcon,
                        color: const Color.fromARGB(255, 156, 189, 216),
                        size: 60,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        next();
                      },
                      child: const Icon(
                        Icons.skip_next_rounded,
                        color: Color.fromARGB(255, 156, 189, 216),
                        size: 60,
                      ),
                    )
                  ],
                ),
              ),
             
            ],
          ),
        ),
      ),
    );
  }

  Map loadSavedDetails() {
    Map data = jsonDecode(txtFile.readAsStringSync()) as Map;
    return data;
  }

  Duration secToMinSec(int seconds) {
    int sec = seconds % 60;
    int min = seconds ~/ 60;

    return Duration(minutes: min, seconds: sec);
  }

  void setupimage() {
    var data = loadSavedDetails();
    () async {
      var bytes = await tagger.readArtwork(path: data["path"]);
      if (bytes != null) {
        setState(() {
          frontImge = Image(
            height: 270,
            width: 270,
            image: MemoryImage(bytes),
          );
          backBlurImage = DecorationImage(
            image: MemoryImage(bytes),
            fit: BoxFit.cover,
          );
        });
      } else {
        setState(() {
          frontImge = const Image(
            height: 270,
            width: 270,
            image: AssetImage("image/image1.jpg"),
          );
          backBlurImage = const DecorationImage(
            image: AssetImage("image/image1.jpg"),
            fit: BoxFit.cover,
          );
        });
      }
    }();
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = loadSavedDetails()["index"];
    setupimage();
    setupduration();
    var time = Timer.periodic(const Duration(seconds: 1), (t) {
      if (player.playing) {
        setState(() {
          value =
              ((player.position.inSeconds * 100) / player.duration!.inSeconds);
          positon = toFormatedString(player.position.inSeconds);
          if ((player.duration!.inSeconds == player.position.inSeconds) &&
              player.loopMode == LoopMode.off) {
            next();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void setupduration() {

    Timer(const Duration(milliseconds: 500), () {

      setState(() {
        duration = toFormatedString(player.duration!.inSeconds);
      });
    });
  }

  void prev() {
    if (_currentIndex == 0) {
      _currentIndex = songdetails.length;
    }
    --_currentIndex;
    loadSong(songdetails[_currentIndex]);
    setupimage();
    setupduration();
  }

  void next() {
    if (_currentIndex >= (songdetails.length - 1)) {
      _currentIndex = -1;
    }
    ++_currentIndex;
    loadSong(songdetails[_currentIndex]);
    setupimage();
    setupduration();
  }

  void loadSong(Map detail, {bool autostart = true}) {
    player.setUrl(detail["path"]!);
    if (autostart) {
      player.play();
      setState(() {
        _currentIcon = Icons.pause;
      });
    }

    saveDetails({...detail, "index": _currentIndex});
  }

  void saveDetails(songdetail) {
    if (!txtFile.existsSync()) {
      txtFile.createSync();
    }
    String data = jsonEncode(songdetail);
    txtFile.writeAsStringSync(data);
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

  String toFormatedString(int seconds) {
    var Ssec = "";
    var Smin = "";
    var sec = seconds % 60;
    var min = seconds ~/ 60;
    if (sec > 9) {
      Ssec = "$sec";
    } else {
      Ssec = "0$sec";
    }
    if (min > 9) {
      Smin = "$min";
    } else {
      Smin = "0$min";
    }

    return "$Smin:$Ssec";
  }

  void setuploop() {
    if (player.loopMode == LoopMode.off) {
      _loopIcon = Icons.repeat_one_on_rounded;
      player.setLoopMode(LoopMode.one);
      Fluttertoast.showToast(msg: "repeat : one");
    } else {
      _loopIcon = Icons.repeat_rounded;
      player.setLoopMode(LoopMode.off);
      Fluttertoast.showToast(msg: "repeat : off");
    }
    setState(() {});
  }
}

pop(String string, {int length = 40}) {
  if (string.length > length) {
    return string.substring(0, length) + "...";
  }
  return string;
}

Text MidText(String data,
        {Color color = const Color.fromARGB(255, 156, 189, 216)}) =>
    Text(data,
        style: TextStyle(
          fontSize: 15,
          color: color,
        ));
