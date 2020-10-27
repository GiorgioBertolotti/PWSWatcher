import 'package:flutter/material.dart';

class ValueSetting {
  String name;
  String asset;
  String valueVarName;
  String unitVarName;
  String visibilityVarName;
  String valueDefaultValue;
  String unitDefaultValue;
  bool visibilityDefaultValue;

  ValueSetting({
    @required this.name,
    @required this.asset,
    @required this.valueVarName,
    @required this.unitVarName,
    @required this.visibilityVarName,
    @required this.valueDefaultValue,
    @required this.unitDefaultValue,
    @required this.visibilityDefaultValue,
  });
}
