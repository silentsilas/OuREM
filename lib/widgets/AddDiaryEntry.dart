import 'package:flutter/material.dart';
import 'package:simple_permissions/simple_permissions.dart';
import '../models/DiaryEntry.dart';
import 'package:speech_recognition/speech_recognition.dart';

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
  String _originalEntry; // we keep the original entry while listening
  DateTime _time;
  int _key;
  bool _canDelete = false;
  bool _deleting = false;
  SpeechRecognition _speech;
  bool _speechRecognitionAvailable = false;
  bool _isListening = false;
  String transcription = '';
  String _currentLocale = 'en_US';

  @override
  void initState() {
    super.initState();
    _appbarTitle = widget.title == null ? "New entry" : "Edit entry";
    _title = widget.title;
    _entry = widget.entry;
    _time = widget.time == null ? DateTime.now() : widget.time;
    _key = widget.recordKey;
    _canDelete = widget.title == null ? false : true;
    _titleTextController = new TextEditingController(text: widget.title);
    _entryTextController = new TextEditingController(text: widget.entry);
    _activateSpeechRecognizer();
  }

  void _requestRecordPermission() async {
    PermissionStatus status = await SimplePermissions.requestPermission(Permission.RecordAudio);
    if (status == PermissionStatus.authorized) {
      print("kewl we're able to record");

//      print(_speech);
      _activateSpeechRecognizer();
    }
  }

  void _activateSpeechRecognizer() {
    print('_MyAppState.activateSpeechRecognizer... ');
//    _speechRecognitionAvailable = true;
    _speech = new SpeechRecognition();
    _speech.setAvailabilityHandler(onSpeechAvailability);
    _speech.setCurrentLocaleHandler(onCurrentLocale);
    _speech.setRecognitionStartedHandler(onRecognitionStarted);
    _speech.setRecognitionResultHandler(onRecognitionResult);
    _speech.setRecognitionCompleteHandler(onRecognitionComplete);
    _speech.activate().then((val) {
      print("activated");
      print(val);
    });
  }

  void _deleteEntry(BuildContext context) {
    final NavigatorState navigator = Navigator.of(context);
    navigator.pop();
    navigator.pop(
        new DiaryEntry(_time, _title, _entry, _key, true)
    );
  }

  void _showDeleteEntryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Delete entry?"),
          content: new Text("Please think through this carefully."),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text("Delete"),
              onPressed: () {
                _deleteEntry(context);
              },
            ),
          ],
        );
      },
    );
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
                .pop(new DiaryEntry(_time, _title, _entry, _key, false));
              },
              child: new Text('SAVE',
                style: Theme
                  .of(context)
                  .textTheme
                  .subhead
                  .copyWith(color: Colors.white))),
        ],
      ),
      body: new Column(
        children: [
          new ListTile(
            leading: new Icon(Icons.label, color: Colors.grey[500]),
            title: new TextField(
              decoration: new InputDecoration(
                hintText: 'Title',
              ),
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.sentences,
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
              textCapitalization: TextCapitalization.sentences,
              maxLines: 10,
              controller: _entryTextController,
              onChanged: (value) => setState(() =>_entry = value),
            ),
          ),
          new Expanded(
              child: new Row(
                children: <Widget>[
                  _buildButton(
                    onPressed: _speechRecognitionAvailable && !_isListening
                        ? () => start()
                        : () => print("null"),
                    label: _isListening
                        ? 'Listening...'
                        : 'Listen ($_currentLocale)',
                  ),
                  _buildButton(
                    onPressed: _isListening ? () => cancel() : null,
                    label: 'Cancel',
                  ),
                  _buildButton(
                    onPressed: _isListening ? () => stop() : null,
                    label: 'Stop',
                  ),
                ],
              )
          )
        ]
      ),
      floatingActionButton: !_canDelete ? null : new FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed:() => _showDeleteEntryDialog(context),
        tooltip: 'Delete diary entry',
        child: new Icon(Icons.delete),
      )
    );
  }

  // might use this later for speech recognition
  Widget _buildButton({String label, VoidCallback onPressed}) => new Padding(
      padding: new EdgeInsets.all(12.0),
      child: new RaisedButton(
        color: Theme.of(context).primaryColor,
        onPressed: onPressed,
        child: new Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
      ));

  void start() {
    print (_speech);
    _speech.listen(locale: _currentLocale).then((result) {
      print(result);
    });
  }

  void cancel() =>
      _speech.cancel().then((result) => setState(() => _isListening = result));

  void stop() =>
      _speech.stop().then((result) => setState(() => _isListening = result));

  void onSpeechAvailability(bool result) => setState(() {
        print(result);
        _speechRecognitionAvailable = result;
      });

  void onCurrentLocale(String locale) =>
      setState(() => _currentLocale = locale);

  void onRecognitionStarted() => setState(() {
    _originalEntry = _entry;
    print("started recording");
    _isListening = true;
  });

  void onRecognitionResult(String text) => setState(() {
    _entryTextController.text = _originalEntry + text;
//    _entry = _entryTextController.text;
    print("onReconigitionResult:");
    print(text);
    transcription = text;
  });

  void onRecognitionComplete(String text) => setState(() {
    _entryTextController.text = _originalEntry + text;
//    _entry = _entryTextController.text;
    print(text);
    print("on recognition complete");
    _isListening = false;
  });

}