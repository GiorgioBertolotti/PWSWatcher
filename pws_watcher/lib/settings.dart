import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:pws_watcher/pwsstate.dart';
import 'package:pws_watcher/main.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key, this.url, this.index}) : super(key: key);

  final String title = "PWS Watcher";
  int index = -1;
  String url;

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final GlobalKey<FormState> _addFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _editFormKey = GlobalKey<FormState>();

  List<Source> _sources = new List();
  final addNameController = TextEditingController();
  final addUrlController = TextEditingController();
  final editNameController = TextEditingController();
  final editUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    retrieveSources();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: Text(
          "Settings",
          maxLines: 1,
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSource,
        elevation: 2,
        child: Icon(Icons.add),
      ),
      body: Builder(
        builder: (context) => ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: _sources.length,
              itemBuilder: (context, position) {
                return Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              _sources[position].name,
                              style: TextStyle(fontSize: 20.0),
                            ),
                            Text(
                              _sources[position].url,
                              style: TextStyle(fontSize: 12.0),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            IconButton(
                              icon: Icon(
                                Icons.edit,
                                color: Colors.lightBlue[700],
                              ),
                              onPressed: () {
                                _editSource(position);
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red[700],
                              ),
                              onPressed: () {
                                _deleteSource(position);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  _addSource() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Add new source"),
            content: Form(
              key: _addFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: addNameController,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return "You must set a source name.";
                      },
                      decoration: InputDecoration.collapsed(
                          hintText: "Source name",
                          border: UnderlineInputBorder()),
                      maxLines: 1,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: TextFormField(
                      keyboardType: TextInputType.url,
                      controller: addUrlController,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return "You must set a source url.";
                      },
                      decoration: InputDecoration.collapsed(
                          hintText: "URL", border: UnderlineInputBorder()),
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text("Add"),
                onPressed: () async {
                  if (_addFormKey.currentState.validate()) {
                    _addFormKey.currentState.save();
                    Source source = new Source(PWSWatcher.countID++,
                        addNameController.text, addUrlController.text);
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    _sources.add(source);
                    List<String> sourcesJSON = new List();
                    for (Source source in _sources) {
                      String sourceJSON = jsonEncode(source);
                      sourcesJSON.add(sourceJSON);
                    }
                    prefs.setStringList("sources", sourcesJSON);
                    prefs.setInt("count_id", PWSWatcher.countID);
                    retrieveSources();
                    Navigator.of(context).pop();
                    PWSStatusPage.updateSources = true;
                  }
                },
              ),
            ],
          );
        });
    addNameController.text = "";
    addUrlController.text = "";
  }

  _editSource(int position) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Edit " + _sources[position].name),
            content: Form(
              key: _editFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: editNameController,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return "You must set a source name.";
                      },
                      decoration: InputDecoration.collapsed(
                          hintText: "Source name",
                          border: UnderlineInputBorder()),
                      maxLines: 1,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: TextFormField(
                      keyboardType: TextInputType.url,
                      controller: editUrlController,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return "You must set a source url.";
                      },
                      decoration: InputDecoration.collapsed(
                          hintText: "URL", border: UnderlineInputBorder()),
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text("Edit"),
                onPressed: () async {
                  if (_editFormKey.currentState.validate()) {
                    _editFormKey.currentState.save();
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    _sources[position].name = editNameController.text;
                    _sources[position].url = editUrlController.text;
                    List<String> sourcesJSON = new List();
                    for (Source source in _sources) {
                      String sourceJSON = jsonEncode(source);
                      sourcesJSON.add(sourceJSON);
                    }
                    prefs.setStringList("sources", sourcesJSON);
                    retrieveSources();
                    Navigator.of(context).pop();
                    PWSStatusPage.updateSources = true;
                  }
                },
              ),
            ],
          );
        });
    setState(() {
      editNameController.text = _sources[position].name;
      editUrlController.text = _sources[position].url;
    });
  }

  _deleteSource(int position) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Delete " + _sources[position].name + "?"),
          content: new Text(
              "This operation is irreversible, if you press Yes this source will be deleted. You really want to delete it?"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Yes"),
              onPressed: () async {
                _sources.removeAt(position);
                SharedPreferences prefs = await SharedPreferences.getInstance();
                List<String> sourcesJSON = new List();
                for (Source source in _sources) {
                  String sourceJSON = jsonEncode(source);
                  sourcesJSON.add(sourceJSON);
                }
                prefs.setStringList("sources", sourcesJSON);
                retrieveSources();
                Navigator.of(context).pop();
                PWSStatusPage.updateSources = true;
              },
            ),
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  retrieveSources() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _sources = new List();
      List<String> sources = prefs.getStringList("sources");
      if (sources != null)
        for (String sourceJSON in sources) {
          try {
            dynamic source = jsonDecode(sourceJSON);
            _sources.add(new Source(source["id"], source["name"], source["url"]));
          } catch (Exception) {
            prefs.setStringList("sources", null);
          }
        }
    });
  }
}

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
