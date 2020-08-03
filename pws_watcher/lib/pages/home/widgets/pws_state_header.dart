import 'package:auto_size_text/auto_size_text.dart';
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
      return _headerWithAsset(context);
    } else {
      return _headerWithoutAsset(context);
    }
  }

  _headerWithAsset(BuildContext context) {
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
                AutoSizeText(
                  this.name,
                  minFontSize: 30.0,
                  maxFontSize: 40.0,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .headline3
                      .copyWith(color: Theme.of(context).accentColor),
                ),
                Text(
                  this.datetime,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.bodyText2.copyWith(
                        color: Theme.of(context).accentColor.withOpacity(0.8),
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
  }

  _headerWithoutAsset(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AutoSizeText(
            this.name,
            minFontSize: 30.0,
            maxFontSize: 40.0,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headline3
                .copyWith(color: Theme.of(context).accentColor),
          ),
          Text(
            this.datetime,
            maxLines: 1,
            style: Theme.of(context).textTheme.bodyText2.copyWith(
                  color: Theme.of(context).accentColor.withOpacity(0.8),
                ),
          ),
        ],
      ),
    );
  }
}
