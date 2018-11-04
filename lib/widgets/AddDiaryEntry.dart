import 'package:flutter/material.dart';
import '../models/DiaryEntry.dart';

class AddDiaryEntry extends StatefulWidget {
  AddDiaryEntry({Key key, this.title, this.entry, this.time, this.recordKey}) : super(key: key);
  final String title;
  final String entry;
  final DateTime time;
  final int recordKey;

  @override
  AddDiaryEntryState createState() => new AddDiaryEntryState();
}

class AddDiaryEntryState extends State<AddDiaryEntry> {
  TextEditingController _titleTextController;
  TextEditingController _entryTextController;
  String _appbarTitle = "New entry";
  String _title;
  String _entry;
  DateTime _time;
  int _key;

  @override
  void initState() {
    super.initState();
    _appbarTitle = widget.title == null ? "New entry" : "Edit entry";
    _title = widget.title;
    _entry = widget.entry;
    _time = widget.time == null ? DateTime.now() : widget.time;
    _key = widget.recordKey;
    _titleTextController = new TextEditingController(text: widget.title);
    _entryTextController = new TextEditingController(text: widget.entry);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(_appbarTitle),
        actions: [
          new FlatButton(
              onPressed: () {
                Navigator
                    .of(context)
                    .pop(new DiaryEntry(_time, _title, _entry, _key));
              },
              child: new Text('SAVE',
                  style: Theme
                      .of(context)
                      .textTheme
                      .subhead
                      .copyWith(color: Colors.white))),
        ],
      ),
      body:
        new Column(
          children: [
            new ListTile(
              leading: new Icon(Icons.label, color: Colors.grey[500]),
              title: new TextField(
                decoration: new InputDecoration(
                  hintText: 'Title',
                ),
                controller: _titleTextController,
                onChanged: (value) => _title = value,
              ),
            ),
            new ListTile(
              leading: new Icon(Icons.subject, color: Colors.grey[500]),
              title: new TextField(
                decoration: new InputDecoration(
                  hintText: 'Entry',
                ),
                keyboardType: TextInputType.multiline,
                maxLines: 10,
                controller: _entryTextController,
                onChanged: (value) => _entry = value,
              ),
            ),
        ]
      )
    );
  }
}