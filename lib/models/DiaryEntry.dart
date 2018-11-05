class DiaryEntry {
  bool deleted;
  DateTime time;
  String title;
  String entry;
  int key;

  DiaryEntry(this.time, this.title, this.entry, this.key, this.deleted);
}