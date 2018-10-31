import 'package:flutter/material.dart';
import '../models/DiaryEntry.dart';

class AddDiaryEntry extends StatefulWidget {
  @override
  AddDiaryEntryState createState() => new AddDiaryEntryState();
}

class AddDiaryEntryState extends State<AddDiaryEntry> {
  String _title;
  TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = new TextEditingController(text: _title);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('New entry'),
        actions: [
          new FlatButton(
              onPressed: () {
                Navigator
                    .of(context)
                    .pop(new DiaryEntry(new DateTime.now(), _title));
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
            new Text("Adding a diary entry"),
            new ListTile(
              leading: new Icon(Icons.speaker_notes, color: Colors.grey[500]),
              title: new TextField(
                decoration: new InputDecoration(
                  hintText: 'Title',
                ),
                controller: _textController,
                onChanged: (value) => _title = value,
              ),
            ),
        ]
      )
    );
  }
}