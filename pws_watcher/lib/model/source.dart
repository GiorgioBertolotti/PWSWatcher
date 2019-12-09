class Source {
  int id;
  String name;
  String url;
  int autoUpdateInterval;

  Source(this.id, this.name, this.url, {this.autoUpdateInterval = 0});

  toJson() {
    return {
      'id': this.id,
      'name': this.name,
      'url': this.url,
      'autoUpdateInterval': this.autoUpdateInterval
    };
  }

  bool operator ==(o) =>
      o is Source &&
      this.id == o.id &&
      this.name == o.name &&
      this.url == o.url &&
      this.autoUpdateInterval == o.autoUpdateInterval;

  int get hashCode =>
      this.id.hashCode ^
      this.name.hashCode ^
      this.url.hashCode ^
      this.autoUpdateInterval.hashCode;
}
