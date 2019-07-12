class ApplicationState {
  ApplicationState(
      {this.settingsOpen = false,
      this.countID = 0,
      this.updateSources = true,
      this.updateVisibilities = true});
  bool updateSources = true;
  bool updateVisibilities = true;
  bool settingsOpen = false;
  int countID = 0;
}
