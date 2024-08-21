import 'package:flutter/material.dart';
import 'package:flutter_calendar_week/src/cache_stream_widget.dart';
import 'package:flutter_calendar_week/src/utils/cache_stream.dart';
import 'package:flutter_calendar_week/src/utils/compare_date.dart';
import 'dart:math' as math;

class DateItem extends StatelessWidget {
  /// Today
  final DateTime today;

  /// Date of item
  final DateTime? date;

  /// Style of [date]
  final TextStyle? dateStyle;

  /// Style of day after pressed
  final TextStyle? pressedDateStyle;

  /// Background
  final Color? backgroundColor;

  /// Specify a background if [date] is [today]
  final Color? todayBackgroundColor;

  /// Specify a background after pressed
  final Color? pressedBackgroundColor;

  /// Alignment a decoration
  final Alignment? decorationAlignment;

  final double? size;

  /// Specify a shape
  final BoxShape? dayShapeBorder;

  /// [Callback] function for press event
  final void Function(DateTime)? onDatePressed;

  /// [Callback] function for long press event
  final void Function(DateTime)? onDateLongPressed;

  /// Decoration widget
  final Widget? decoration;

  /// [cacheStream] for emit date press event
  final CacheStream<DateTime?> cacheStream;

  final bool showWeek;

  final bool showColorToday;

  final List<String> daysOfWeek;

  final bool showPinDate;

  DateItem({
    required this.today,
    required this.date,
    required this.cacheStream,
    this.dateStyle,
    this.size,
    this.pressedDateStyle,
    this.backgroundColor = Colors.transparent,
    this.todayBackgroundColor = Colors.orangeAccent,
    this.pressedBackgroundColor,
    this.decorationAlignment = FractionalOffset.center,
    this.dayShapeBorder,
    this.onDatePressed,
    this.onDateLongPressed,
    this.decoration,
    this.showWeek = false,
    required this.daysOfWeek,
    required this.showColorToday,
    this.showPinDate = false,
  });

  /// Default background
  late Color? _defaultBackgroundColor;

  /// Default style
  late TextStyle? _defaultTextStyle;

  bool selectData = false;

  @override
  Widget build(BuildContext context) => date != null
      ? CacheStreamBuilder<DateTime?>(
    cacheStream: cacheStream,
    cacheBuilder: (_, data) {
      /// Set default each [builder] is called
      _defaultBackgroundColor = backgroundColor;

      /// Set default style each [builder] is called
      _defaultTextStyle = dateStyle;
      selectData = false;
      bool isAdjacentDate = false;
      /// Check and set [Background] of today
      if (showColorToday && compareDate(date, today)) {
        _defaultBackgroundColor = todayBackgroundColor;
      } else if (!data.hasError && data.hasData) {
        final DateTime? dateSelected = data.data;

        if (compareDate(date, dateSelected)) {
          selectData = true;
          _defaultBackgroundColor = pressedBackgroundColor;
          _defaultTextStyle = pressedDateStyle;
        }else if (dateSelected != null &&
            (compareDate(date, dateSelected.subtract(Duration(days: 1))) ||
                compareDate(date, dateSelected.add(Duration(days: 1))))) {
          isAdjacentDate = true;
        }
      }else{
        if (compareDate(date, today)) {
          selectData = true;
          _defaultBackgroundColor = pressedBackgroundColor;
          _defaultTextStyle = pressedDateStyle;
        }
      }
      return Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: size ?? 50.0,
            height: size ?? 50.0,
            alignment: FractionalOffset.center,
            child: GestureDetector(
              onTap: _onPressed,
              onLongPress: _onLongPressed,
              child: Container(
                  decoration: BoxDecoration(
                    color: _defaultBackgroundColor!,
                    border: Border.fromBorderSide(BorderSide.none),
                    shape: dayShapeBorder!,
                    borderRadius: showPinDate && selectData
                        ? BorderRadius.only(
                        topRight: Radius.circular(12),
                        topLeft: Radius.circular(12))
                        : BorderRadius.circular(12),
                  ),
                  padding: showPinDate && selectData
                      ? EdgeInsets.only(top: 5,
                      left: isAdjacentDate ? 0 : 5,
                      right: isAdjacentDate ? 0 :  5)
                      : EdgeInsets.all(5),
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(weekDay + '${date!.day}',
                            style: _defaultTextStyle!,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        top: showWeek ? 0 : null,
                        left: showWeek ? null : 0,
                        right: 0,
                        child: Container(
                            width: 12,
                            height: 12,
                            alignment: decorationAlignment,
                            child: decoration != null
                                ? FittedBox(
                              fit: BoxFit.scaleDown,
                              child: decoration!,
                            ) : Container()
                        ),
                      )
                    ],
                  )),
            ),
          ),

          if(showPinDate && selectData) ...[
            Padding(
              padding: EdgeInsets.only(top: (size ?? 50.0) - 1),
              child: Stack(
                alignment:Alignment.center,
                children: [
                  Positioned(top: -10,
                      child: Container(width: size, height: (size ?? 50.0)/2, color: _defaultBackgroundColor,)),
                  CurvadaLateralWidget(
                    color: _defaultBackgroundColor!, size: size ?? 50.0,
                  ),
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 5),
                      decoration: BoxDecoration(
                          color: _defaultBackgroundColor == Colors.white ? Colors.black : Colors.white,
                          borderRadius: BorderRadius.circular(100)
                      ),
                      height: 8, width: 8,
                    ),
                  ),
                ],
              ),
            )
          ]
        ],
      );
    },
  )
      : Container(
    width: size ?? 50.0,
    height: size ?? 50.0,
  );

  String get weekName => daysOfWeek.elementAt(date!.weekday - 1);

  String get weekDay => (showWeek ? weekName[0] + '\n' : '');

  /// Handler press event
  void _onPressed() {
    if (date != null) {
      cacheStream.add(date);
      onDatePressed!(date!);
    }
  }

  /// Handler long press event
  void _onLongPressed() {
    if (date != null) {
      cacheStream.add(date);
      onDateLongPressed!(date!);
    }
  }
}


class CurvadaLateralWidget extends StatelessWidget {
  const CurvadaLateralWidget({required this.color, this.size = 50});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: Size(10, size/2.5), // Ajuste o tamanho conforme necessário
          painter: LateralPainter(color),
        ),
        Container(width: size, height: size/2.5, color: color,),
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationY(math.pi),
          child: CustomPaint(
            size: Size(10, size/2.5), // Ajuste o tamanho conforme necessário
            painter: LateralPainter(color),
          ),
        ),
      ],
    );
  }
}

class LateralPainter extends CustomPainter {
  final Color color;

  const LateralPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 0
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height) // Início no canto inferior esquerdo
      ..lineTo(size.width * 0.2, size.height) // Linha até o ponto de controle inferior
      ..quadraticBezierTo(size.width , size.height , size.width, 0) // Curva de Bézier cúbica
      ..lineTo(size.width , size.height) // Linha até o canto inferior direito
      ..close(); // Fecha o caminho

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}