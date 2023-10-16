class Calendar {
  final String startTime;
  final String endTime;
  final String debutPause;
  final String finPause;
  String duration;
  final String weekend;
  final List<dynamic> freeDates;
  Calendar(
    this.startTime,
    this.endTime,
    this.debutPause,
    this.finPause,
    this.duration,
    this.weekend,
    this.freeDates,
  );
}
