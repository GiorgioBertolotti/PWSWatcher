class PWS {
  int id;
  String name;
  String url;
  int autoUpdateInterval;
  String? snapshotUrl;
  String? parsingDateFormat;

  PWS(
    this.id,
    this.name,
    this.url, {
    this.autoUpdateInterval = 0,
    this.snapshotUrl,
    this.parsingDateFormat,
  });

  toJson() {
    return {
      'id': this.id,
      'name': this.name,
      'url': this.url,
      'autoUpdateInterval': this.autoUpdateInterval,
      'snapshotUrl': this.snapshotUrl,
      'parsingDateFormat': this.parsingDateFormat
    };
  }

  bool operator ==(o) =>
      o is PWS &&
      this.id == o.id &&
      this.name == o.name &&
      this.url == o.url &&
      this.snapshotUrl == o.snapshotUrl &&
      this.autoUpdateInterval == o.autoUpdateInterval;

  int get hashCode =>
      this.id.hashCode ^
      this.name.hashCode ^
      this.url.hashCode ^
      this.snapshotUrl.hashCode ^
      this.autoUpdateInterval.hashCode;
}
