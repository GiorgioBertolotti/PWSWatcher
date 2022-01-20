class ApplicationState {
  ApplicationState({
    this.countID = 0,
    this.updatePreferences = true,
    this.prefWindUnit = "km/h",
    this.prefRainUnit = "mm",
    this.prefPressUnit = "mb",
    this.prefTempUnit = "°C",
    this.prefDewUnit = "°C",
  });

  bool updatePreferences;
  int countID;
  String? prefWindUnit;
  String? prefRainUnit;
  String? prefPressUnit;
  String? prefTempUnit;
  String? prefDewUnit;
}
