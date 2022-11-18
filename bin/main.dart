import 'dart:io';
import 'package:dart_console/dart_console.dart';
import 'package:path/path.dart' as p;

import 'line.dart';

List<Line> lines = [];
late final File transcript;
final String emptyScreen = List.generate(20, (_) => "").join('\n');

void main(List<String> arguments) async {
  try {
    final console = Console();

    print("Transcript to Subtitle\nby Benedek Fodor in 2022\n");

    if (arguments.isEmpty) {
      print("Please drag and drop a file onto the executable to load it.");
      softExit(1);
    }

    transcript = File(arguments[0]);

    lines.addAll(transcript.readAsLinesSync().map((e) => Line(e)));

    print("Starting in...");
    for (var i = 5; i > 0; i--) {
      print(i);
      await Future.delayed(Duration(seconds: 1));
    }

    DateTime startTime = DateTime.now();

    bool currentlyEmpty = true;
    for (var i = 0; i < lines.length; i++) {
      while (true) {
        Line? prevLine;
        try {
          prevLine = lines[i - 1];
        } catch (_) {}
        List<Line> nextLines = [];
        try {
          nextLines = lines.sublist(i + 1,
              (i + 3) > (lines.length - 1) ? (lines.length - 1) : (i + 3));
        } catch (_) {}
        print(
            """$emptyScreen
  ${prevLine?.timesString() ?? ""}
  ${prevLine ?? "(Sync the the first line:)"}

  $i
  ${lines[i].timesString()}
${currentlyEmpty ? ">>\n  ${lines[i]}" : ">>${lines[i]}\n"}

  ${nextLines.join('\n  ')}

| next: down arrow ${currentlyEmpty ? "" : "| empty: space"}""");
        Key pressedKey = console.readKey();
        if (pressedKey.controlChar == ControlCharacter.arrowDown) {
          if (currentlyEmpty) {
            lines[i].start = DateTime.now().difference(startTime);
            currentlyEmpty = false;
          } else {
            try {
              lines[i].end = DateTime.now().difference(startTime);
            } catch (_) {}
            try {
              lines[i + 1].start = DateTime.now()
                  .difference(startTime.subtract(Duration(milliseconds: 10)));
            } catch (_) {}
            currentlyEmpty = false;
            break;
          }
        } else if (pressedKey.char == " " && !currentlyEmpty) {
          lines[i].end = DateTime.now().difference(startTime);
          currentlyEmpty = true;
          break;
        } else {
          print("Invalid input!");
          await Future.delayed(Duration(milliseconds: 50));
        }
      }
    }

    print(
        """$emptyScreen
Done! Saving ${p.basenameWithoutExtension(transcript.path)}.srt""");
    File srtFile = File(p.basenameWithoutExtension(transcript.path) + ".srt");
    srtFile.createSync();
    srtFile.writeAsStringSync(lines
        .map((e) =>
            """
${lines.indexOf(e) + 1}
${e.timesString()}
${e.content}

""")
        .join());

    print("\nDone. Goodbye!");
    softExit(0);
  } catch (e, s) {
    print("Error: $e\n$s");
    softExit(1);
  }
}

void softExit(int code) {
  print("\n---\nPress Enter to exit.");
  stdin.readLineSync();
  exit(code);
}
