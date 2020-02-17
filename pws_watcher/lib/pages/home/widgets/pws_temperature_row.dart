import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PWSTemperatureRow extends StatelessWidget {
  PWSTemperatureRow(this.temperature, {this.asset});

  final String temperature;
  final String asset;

  @override
  Widget build(BuildContext context) {
    if (asset != null) {
      return _rowWithAsset(context);
    } else {
      return _rowWithoutAsset(context);
    }
  }

  _rowWithAsset(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
            child: AutoSizeText(
              this.temperature,
              minFontSize: 60.0,
              maxFontSize: 72.0,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.w900,
                color: Theme.of(context).accentColor,
              ),
            ),
          ),
          SvgPicture.asset(
            asset,
            width: 70.0,
            height: 70.0,
          ),
        ],
      ),
    );
  }

  _rowWithoutAsset(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Center(
        child: AutoSizeText(
          this.temperature,
          minFontSize: 60.0,
          maxFontSize: 72.0,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.w900,
            color: Theme.of(context).accentColor,
          ),
        ),
      ),
    );
  }
}
