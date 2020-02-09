import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PWSStateHeader extends StatelessWidget {
  PWSStateHeader(this.name, this.datetime, {this.asset});

  final String name;
  final String datetime;
  final String asset;

  @override
  Widget build(BuildContext context) {
    if (asset != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    this.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                  Text(
                    this.datetime,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                ],
              ),
            ),
            SvgPicture.asset(
              asset,
              width: 50.0,
              height: 50.0,
            ),
          ],
        ),
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            this.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w900,
              color: Theme.of(context).accentColor,
            ),
          ),
          Text(
            this.datetime,
            maxLines: 1,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Theme.of(context).accentColor,
            ),
          ),
        ],
      );
    }
    return Container();
  }
}
