class Source {
  int id;
  String name;
  String url;

  Source(id, name, url) {
    this.id = id;
    this.name = name;
    this.url = url;
  }

  toJson() {
    return {'id': id, 'name': this.name, 'url': this.url};
  }
}