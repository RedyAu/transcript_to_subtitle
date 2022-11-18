class Line {
  String content;
  Duration? start;
  Duration? end;

  Line(this.content, [this.start, this.end]);

  @override
  String toString() => '"$content"';

  String timesString() =>
      "${(start != null) ? "${start?.srt}" : ""}${(end != null) ? " --> ${end?.srt}" : ""}"
          .replaceAll('.', ',');
}

extension SrtDuration on Duration {
  String get srt =>
      "${this.inHours.toString().padLeft(2, '0')}:${(this.inMinutes % 60).toString().padLeft(2, '0')}:${(this.inSeconds % 60).toString().padLeft(2, '0')},${(this.inMilliseconds % 1000).toString().padLeft(3, '0')}";
}
