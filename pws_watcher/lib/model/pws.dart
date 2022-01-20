class PWS {
  int id;
  String name;
  String url;
  String? snapshotUrl;
  int autoUpdateInterval;

  PWS(this.id, this.name, this.url, {this.snapshotUrl, this.autoUpdateInterval = 0});

  toJson() {
    return {
      'id': this.id,
      'name': this.name,
      'url': this.url,
      'snapshotUrl': this.snapshotUrl,
      'autoUpdateInterval': this.autoUpdateInterval
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
