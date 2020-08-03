import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DoubleVariableRow extends StatelessWidget {
  DoubleVariableRow(
    this.labelLeft,
    this.assetLeft,
    this.valueLeft,
    this.unitLeft,
    this.labelRight,
    this.assetRight,
    this.valueRight,
    this.unitRight, {
    this.visibilityLeft = true,
    this.visibilityRight = true,
  });

  final bool visibilityLeft;
  final String labelLeft;
  final String assetLeft;
  final String valueLeft;
  final String unitLeft;
  final bool visibilityRight;
  final String labelRight;
  final String assetRight;
  final String valueRight;
  final String unitRight;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Tooltip(
          message: labelLeft,
          child: visibilityLeft
              ? VariableRow(valueLeft, unitLeft, assetLeft, labelLeft)
              : Container(),
        ),
        Tooltip(
          message: labelRight,
          child: visibilityRight
              ? VariableRow(
                  valueRight,
                  unitRight,
                  assetRight,
                  labelRight,
                  leftAlign: false,
                )
              : Container(),
        ),
      ],
    );
  }
}

class VariableRow extends StatelessWidget {
  VariableRow(this.value, this.unit, this.asset, this.label,
      {this.leftAlign = true});

  final String value;
  final String unit;
  final String asset;
  final String label;
  final bool leftAlign;

  @override
  Widget build(BuildContext context) {
    if (leftAlign)
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: SvgPicture.asset(
              asset,
              width: 30,
              height: 30,
              semanticsLabel: label,
              color: Theme.of(context).accentColor,
            ),
          ),
          Text(
            value,
            maxLines: 1,
            style: Theme.of(context)
                .textTheme
                .headline5
                .copyWith(color: Theme.of(context).accentColor),
          ),
          Text(
            unit,
            maxLines: 1,
            style: Theme.of(context)
                .textTheme
                .subtitle1
                .copyWith(color: Theme.of(context).accentColor),
          ),
        ],
      );
    else
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            value,
            maxLines: 1,
            style: Theme.of(context)
                .textTheme
                .headline5
                .copyWith(color: Theme.of(context).accentColor),
          ),
          Text(
            unit,
            maxLines: 1,
            style: Theme.of(context)
                .textTheme
                .subtitle1
                .copyWith(color: Theme.of(context).accentColor),
          ),
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: SvgPicture.asset(
              asset,
              width: 30,
              height: 30,
              semanticsLabel: label,
              color: Theme.of(context).accentColor,
            ),
          ),
        ],
      );
  }
}
