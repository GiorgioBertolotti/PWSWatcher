class ApplicationState {
  ApplicationState({
    this.settingsOpen = false,
    this.countID = 0,
    this.updateSources = true,
    this.updatePreferences = true,
    this.prefWindUnit = "km/h",
    this.prefRainUnit = "mm",
    this.prefPressUnit = "mb",
    this.prefTempUnit = "°C",
    this.prefDewUnit = "°C",
  });

  bool updateSources;
  bool updatePreferences;
  bool settingsOpen;
  int countID;
  String prefWindUnit;
  String prefRainUnit;
  String prefPressUnit;
  String prefTempUnit;
  String prefDewUnit;
}
