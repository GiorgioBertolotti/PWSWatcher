import 'package:flutter/material.dart';

class CustomData {
  String name;
  String unit;
  IconData icon;

  CustomData({
    @required this.name,
    this.unit,
    this.icon,
  });

  toJson() {
    return {
      'name': this.name,
      'unit': this.unit,
      'icon': this.icon != null
          ? {
              'codePoint': this.icon.codePoint,
              'fontFamily': this.icon.fontFamily,
              'fontPackage': this.icon.fontPackage,
              'matchTextDirection': this.icon.matchTextDirection,
            }
          : null
    };
  }

  bool operator ==(o) => o is CustomData && this.name == o.name;

  int get hashCode =>
      this.name.hashCode ^ this.unit.hashCode ^ this.icon.hashCode;
}
