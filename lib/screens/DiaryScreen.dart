import 'dart:async';
import 'package:flutter/material.dart';
import '../models/DiaryEntry.dart';
import '../widgets/AddDiaryEntry.dart';
import '../widgets/DiaryEntryItem.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:simple_permissions/simple_permissions.dart';
//import 'package:flutter_string_encryption/flutter_string_encryption.dart';
//import 'dart:io' show Platform;

class DiaryScreen extends StatefulWidget {
  DiaryScreen({Key key, this.title}) : super(key: key);

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  @override
  _DiaryScreenState createState() => new _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  double _itemExtent = 50.0;
  Database diaryDb;
  List<DiaryEntry> diarySaves;
  ScrollController _listViewScrollController = new ScrollController();

  void _openAddEntryDialog(BuildContext context) async {
    DiaryEntry save = await Navigator.of(context).push(new MaterialPageRoute(
        builder: (BuildContext context) {
          return new AddDiaryEntry(title: null, entry: null, time: null, recordKey: null);
        },
        fullscreenDialog: true
    ));
    if (save != null) {
      _addDiarySave(save);
    }
  }

  void _openEditEntryDialog(BuildContext context, int entryIndex, DiaryEntry originalSave) async {
    DiaryEntry save = await Navigator.of(context).push(new MaterialPageRoute(
      builder: (BuildContext context) {
        return new AddDiaryEntry(title: originalSave.title, entry: originalSave.entry, time: originalSave.time, recordKey: originalSave.key);
      },
      fullscreenDialog: true
    ));
    if (save != null) {
      if (save.deleted) {
        _deleteDiarySave(entryIndex, save);
      } else {
        _updateDiarySave(entryIndex, save);
      }
    }
  }

  void _addDiarySave (DiaryEntry diarySave) async {
    Store diaryStore = diaryDb.getStore("diary");
    var newRecord = new Record(diaryStore, {
      'title': diarySave.title,
      'entry': diarySave.entry,
      'time': diarySave.time.toIso8601String()
    });
    Record addedRecord = await diaryDb.putRecord(newRecord);
    setState(() {
      if (diaryDb != null) {
        diarySave.key = addedRecord.key;
      }
      diarySaves.add(diarySave);
      _listViewScrollController.animateTo(
        diarySaves.length * _itemExtent,
        duration: const Duration(microseconds: 1),
        curve: new ElasticInCurve(0.01),
      );
    });
  }

  void _deleteDiarySave (int entryIndex, DiaryEntry save) async {
    if (diaryDb != null) {
      Store diaryStore = diaryDb.getStore("diary");
      await diaryStore.delete(save.key);
    }
    setState(() {
      diarySaves.removeAt(entryIndex);
    });
  }

  void _updateDiarySave (int entryIndex, DiaryEntry save) async {
    if (diaryDb != null) {
      Store diaryStore = diaryDb.getStore("diary");
      Record record = await diaryStore.getRecord(save.key);
      record.value['title'] = save.title;
      record.value['entry'] = save.entry;
      record.value['time'] = save.time.toIso8601String();
      diaryDb.putRecord(record);
    }

    setState(() {
      diarySaves[entryIndex] = save;
    });
  }

  Future<Database> _initializeDb() async {
    // File path to a file in the same directory as the current script
    final path = await DiaryScreen._localPath;
    return await databaseFactoryIo
        .openDatabase(join(path, "sample.db"));
  }

  Future<PermissionStatus> _requestFilePermission() async {
    return await SimplePermissions.requestPermission(Permission.WriteExternalStorage);
  }

  @override
  void initState() {
    _requestFilePermission().then( (PermissionStatus status) {
      if (status == PermissionStatus.authorized) {
        _initializeDb().then( (Database db) async {
          diaryDb = db;
          diarySaves = new List<DiaryEntry>();
          Store diaryStore = db.getStore("diary");
          await diaryStore.records.listen((Record diaryRecord) {
            // here we know we have a single record
            DiaryEntry diaryEntry = new DiaryEntry(
              DateTime.parse(diaryRecord.value['time'] as String), diaryRecord.value['title'] as String, diaryRecord.value['entry'] as String, diaryRecord.key as int, diaryRecord.deleted,
            );
            // add that to our list, and update the state
            setState(() {
              diarySaves.add(diaryEntry);
            });
          }).asFuture();
        });
      } else {
        // TODO: make a toast/dialogue that shows errors like this
        print("couldn't get entries from db");
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new ListView.builder(
        shrinkWrap: true,
        reverse: true,
        controller: _listViewScrollController,
        itemCount: diarySaves != null ? diarySaves.length : 0,
        itemBuilder: (buildContext, index) {
          return new InkWell(
              onTap: () => _openEditEntryDialog(context, index, diarySaves[index]),  //() => _editEntry(diarySaves[index]),
              child: new DiaryEntryItem(diarySaves[index]));
        },
      ),
      floatingActionButton: new FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed:() => _openAddEntryDialog(context),
        tooltip: 'Add new diary entry',
        child: new Icon(Icons.add),
      ),
    );
  }
}