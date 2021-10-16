import 'package:flutter/material.dart';

class ProgressVertical extends StatelessWidget {
  final int value;
  final String date;
  final bool isShowDate;

  ProgressVertical(
      {Key key,
      @required this.value,
      @required this.date,
      @required this.isShowDate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      //   margin: EdgeInsets.only(right: 7),
      width: 30,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(
            child: new LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
              return Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Container(
                    width: 10,
                    decoration: new BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      shape: BoxShape.rectangle,
                      color: Colors.green.withOpacity(0.3),
                    ),
                  ),
                  Positioned(
                    bottom: constraints.maxHeight * (value / 100),
                    child: Text(
                      value.toString(),
                      style: Theme.of(context).textTheme.caption.copyWith(
                            color: Colors.green.shade900,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    child: Container(
                      decoration: new BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        shape: BoxShape.rectangle,
                        color: value == 50
                            ? Colors.green.shade500
                            : value < 50
                                ? Colors.green.shade300
                                : Colors.green.shade700,
                      ),
                      height: constraints.maxHeight * (value / 100),
                      width: constraints.maxWidth,
                    ),
                  ),
                ],
              );
            }),
          ),
          SizedBox(height: 10),
          Text(
            (isShowDate) ? date : "",
            style: Theme.of(context).textTheme.caption.copyWith(
                  color: Colors.black54,
                ),
          ),
        ],
      ),
    );
  }
}
