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

  bool isEqual(Source other) {
    return this.id == other.id &&
        this.name == other.name &&
        this.url == other.url &&
        this.autoUpdateInterval == other.autoUpdateInterval;
  }
}
