import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DoubleVariableRow extends StatelessWidget {
  final bool visibilityLeft;
  final String labelLeft;
  final String assetLeft;
  final IconData iconLeft;
  final String valueLeft;
  final String unitLeft;
  final bool visibilityRight;
  final String labelRight;
  final String assetRight;
  final IconData iconRight;
  final String valueRight;
  final String unitRight;

  DoubleVariableRow({
    @required this.labelLeft,
    this.assetLeft,
    this.iconLeft,
    @required this.valueLeft,
    @required this.unitLeft,
    @required this.labelRight,
    this.assetRight,
    this.iconRight,
    @required this.valueRight,
    @required this.unitRight,
    this.visibilityLeft = true,
    this.visibilityRight = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Tooltip(
          message: labelLeft,
          child: visibilityLeft
              ? VariableRow(
                  value: valueLeft,
                  unit: unitLeft,
                  icon: iconLeft,
                  asset: assetLeft,
                  label: labelLeft,
                )
              : Container(),
        ),
        Tooltip(
          message: labelRight,
          child: visibilityRight
              ? VariableRow(
                  value: valueRight,
                  unit: unitRight,
                  icon: iconRight,
                  asset: assetRight,
                  label: labelRight,
                  leftAlign: false,
                )
              : Container(),
        ),
      ],
    );
  }
}

class VariableRow extends StatelessWidget {
  final String value;
  final String unit;
  final IconData icon;
  final String asset;
  final String label;
  final bool leftAlign;

  VariableRow({
    @required this.value,
    @required this.unit,
    this.icon,
    this.asset,
    @required this.label,
    this.leftAlign = true,
  });

  @override
  Widget build(BuildContext context) {
    if (leftAlign)
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: icon != null
                ? Icon(
                    icon,
                    size: 30,
                    color: Theme.of(context).accentColor,
                  )
                : SvgPicture.asset(
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
            child: icon != null
                ? Icon(
                    icon,
                    size: 30,
                    color: Theme.of(context).accentColor,
                  )
                : SvgPicture.asset(
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
