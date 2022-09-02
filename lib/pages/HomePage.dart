import 'dart:io';
import 'package:audiotagger/audiotagger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'ShowPage.dart';
import 'package:permission_handler/permission_handler.dart';
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var songs = <String>[];
  final tagger = Audiotagger();

  // late Directory card;
  @override
  void initState() {
    () async {
      if (await Permission.storage.isDenied) {
        PermissionStatus result = await Permission.storage.request();
        if (result == PermissionStatus.permanentlyDenied) {
          openAppSettings();
           Fluttertoast.showToast(msg: "Please grant the permission");
        }
        if (result == PermissionStatus.granted) {
          startFinding();
        } else {
          SystemNavigator.pop();
          Fluttertoast.showToast(msg: "Permission is required!");
        }
      } else {
        startFinding();
      }
    }();

    super.initState();
  }

  void startFinding() {
    Directory("/storage/emulated/0/").listSync(recursive: true).forEach((f) {
      if (f.path.endsWith("mp3")) {
        songs.add(f.path);
      }
    });

    createatracklist(songs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: CircularProgressIndicator(),
    ));
  }

  void createatracklist(List<String> songs) {
    List<Map<String, String>> arrvalue = <Map<String, String>>[];
    for (var path in songs) {
      var objvalue = <String, String>{};
      final String filePath = path;
      tagger.readTags(path: filePath).then((tag) {
        objvalue["artist"] = tag?.artist ?? "unknown";
        objvalue["title"] = tag?.title ?? "unknown";
        objvalue["album"] = tag?.album ?? "unknown";
        objvalue["genre"] = tag?.genre ?? "unknown";
        objvalue["year"] = tag?.year ?? "unknown";
        objvalue["path"] = path;

        arrvalue.add(objvalue);
      });
    }

    // Fluttertoast.showToast(msg: arrvalue.toString());
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => ShowPage(arrvalue)));
    });
  }
}

Widget MatButton(onPressed, IconData icon,{String tooltip=""}) {
  return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onPressed,
      child: Container(
        width: 50,
        height: 50,
        child: Icon(icon,),
      ));
}
