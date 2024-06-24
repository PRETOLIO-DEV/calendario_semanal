class WeekItem {
  final String month;
  final int year;
  final List<String> dayOfWeek;
  final List<DateTime?> days;

  WeekItem({
    this.month = '',
    this.year = 0,
    this.dayOfWeek = const [],
    this.days = const []
  });
}
