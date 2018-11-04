import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/DiaryEntry.dart';

class DiaryEntryItem extends StatelessWidget {
  final DiaryEntry diaryEntry;

  DiaryEntryItem(this.diaryEntry);

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: new EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          new Text(diaryEntry.title == null ? "" : diaryEntry.title),
          new Expanded(
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                new Text(
                  new DateFormat.MMMEd().format(diaryEntry.time),
                  textScaleFactor: 0.9,
                  textAlign: TextAlign.left,
                ),
              ]
            )
          )
        ],
      ),
    );
  }

}