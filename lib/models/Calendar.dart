import 'package:mongo_dart/mongo_dart.dart';

class Calendar {
  final ObjectId id;
  final String startTime;
  final String endTime;
  final String pause;
  String duration;
  final String weekend;
  Calendar(
    this.id,
    this.startTime,
    this.endTime,
    this.pause,
    this.duration,
    this.weekend,
  );
}
