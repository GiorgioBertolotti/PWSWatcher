import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:pws_watcher/pws_state.dart';
import 'package:pws_watcher/main.dart';
import 'package:pws_watcher/source.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key, this.url, this.index}) : super(key: key);

  int index = -1;
  String url;

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final GlobalKey<FormState> _addFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _editFormKey = GlobalKey<FormState>();

  var visibilityWindSpeed = true;
  var visibilityPressure = true;
  var visibilityWindDirection = true;
  var visibilityHumidity = true;
  var visibilityTemperature = true;
  var visibilityWindChill = true;
  var visibilityRain = true;
  var visibilityDew = true;
  var visibilitySunrise = true;
  var visibilitySunset = true;
  var visibilityMoonrise = true;
  var visibilityMoonset = true;

  List<Source> _sources = new List();
  final addNameController = TextEditingController();
  final addUrlController = TextEditingController();
  final editNameController = TextEditingController();
  final editUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setVisibilities();
    _retrieveSources();
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
        builder: (context) => ListView(
              children: <Widget>[
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const ListTile(
                          title: Text(
                            'Generic settings',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text("Wind speed visibility"),
                            Switch(
                              value: visibilityWindSpeed,
                              onChanged: (value) async {
                                setState(() {
                                  visibilityWindSpeed = value;
                                });
                                PWSStatusPage.updateVisibilities = true;
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                prefs.setBool("visibilityWindSpeed", value);
                              },
                              activeTrackColor: Colors.lightBlueAccent,
                              activeColor: Colors.blue,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text("Pressure visibility"),
                            Switch(
                              value: visibilityPressure,
                              onChanged: (value) async {
                                setState(() {
                                  visibilityPressure = value;
                                });
                                PWSStatusPage.updateVisibilities = true;
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                prefs.setBool("visibilityPressure", value);
                              },
                              activeTrackColor: Colors.lightBlueAccent,
                              activeColor: Colors.blue,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text("Wind direction visibility"),
                            Switch(
                              value: visibilityWindDirection,
                              onChanged: (value) async {
                                setState(() {
                                  visibilityWindDirection = value;
                                });
                                PWSStatusPage.updateVisibilities = true;
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                prefs.setBool("visibilityWindDirection", value);
                              },
                              activeTrackColor: Colors.lightBlueAccent,
                              activeColor: Colors.blue,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text("Humidity visibility"),
                            Switch(
                              value: visibilityHumidity,
                              onChanged: (value) async {
                                setState(() {
                                  visibilityHumidity = value;
                                });
                                PWSStatusPage.updateVisibilities = true;
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                prefs.setBool("visibilityHumidity", value);
                              },
                              activeTrackColor: Colors.lightBlueAccent,
                              activeColor: Colors.blue,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text("Temperature (small) visibility"),
                            Switch(
                              value: visibilityTemperature,
                              onChanged: (value) async {
                                setState(() {
                                  visibilityTemperature = value;
                                });
                                PWSStatusPage.updateVisibilities = true;
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                prefs.setBool("visibilityTemperature", value);
                              },
                              activeTrackColor: Colors.lightBlueAccent,
                              activeColor: Colors.blue,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text("Wind chill visibility"),
                            Switch(
                              value: visibilityWindChill,
                              onChanged: (value) async {
                                setState(() {
                                  visibilityWindChill = value;
                                });
                                PWSStatusPage.updateVisibilities = true;
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                prefs.setBool("visibilityWindChill", value);
                              },
                              activeTrackColor: Colors.lightBlueAccent,
                              activeColor: Colors.blue,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text("Rain visibility"),
                            Switch(
                              value: visibilityRain,
                              onChanged: (value) async {
                                setState(() {
                                  visibilityRain = value;
                                });
                                PWSStatusPage.updateVisibilities = true;
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                prefs.setBool("visibilityRain", value);
                              },
                              activeTrackColor: Colors.lightBlueAccent,
                              activeColor: Colors.blue,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text("Dew visibility"),
                            Switch(
                              value: visibilityDew,
                              onChanged: (value) async {
                                setState(() {
                                  visibilityDew = value;
                                });
                                PWSStatusPage.updateVisibilities = true;
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                prefs.setBool("visibilityDew", value);
                              },
                              activeTrackColor: Colors.lightBlueAccent,
                              activeColor: Colors.blue,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text("Sunrise hour visibility"),
                            Switch(
                              value: visibilitySunrise,
                              onChanged: (value) async {
                                setState(() {
                                  visibilitySunrise = value;
                                });
                                PWSStatusPage.updateVisibilities = true;
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                prefs.setBool("visibilitySunrise", value);
                              },
                              activeTrackColor: Colors.lightBlueAccent,
                              activeColor: Colors.blue,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text("Sunset hour visibility"),
                            Switch(
                              value: visibilitySunset,
                              onChanged: (value) async {
                                setState(() {
                                  visibilitySunset = value;
                                });
                                PWSStatusPage.updateVisibilities = true;
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                prefs.setBool("visibilitySunset", value);
                              },
                              activeTrackColor: Colors.lightBlueAccent,
                              activeColor: Colors.blue,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text("Moonrise hour visibility"),
                            Switch(
                              value: visibilityMoonrise,
                              onChanged: (value) async {
                                setState(() {
                                  visibilityMoonrise = value;
                                });
                                PWSStatusPage.updateVisibilities = true;
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                prefs.setBool("visibilityMoonrise", value);
                              },
                              activeTrackColor: Colors.lightBlueAccent,
                              activeColor: Colors.blue,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text("Moonset hour visibility"),
                            Switch(
                              value: visibilityMoonset,
                              onChanged: (value) async {
                                setState(() {
                                  visibilityMoonset = value;
                                });
                                PWSStatusPage.updateVisibilities = true;
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                prefs.setBool("visibilityMoonset", value);
                              },
                              activeTrackColor: Colors.lightBlueAccent,
                              activeColor: Colors.blue,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                ListView.builder(
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
              ],
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
                    _retrieveSources();
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
                    _retrieveSources();
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
                _retrieveSources();
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

  Future<Null> _setVisibilities() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      visibilityWindSpeed = prefs.getBool("visibilityWindSpeed");
      visibilityPressure = prefs.getBool("visibilityPressure");
      visibilityWindDirection = prefs.getBool("visibilityWindDirection");
      visibilityHumidity = prefs.getBool("visibilityHumidity");
      visibilityTemperature = prefs.getBool("visibilityTemperature");
      visibilityWindChill = prefs.getBool("visibilityWindChill");
      visibilityRain = prefs.getBool("visibilityRain");
      visibilityDew = prefs.getBool("visibilityDew");
      visibilitySunrise = prefs.getBool("visibilitySunrise");
      visibilitySunset = prefs.getBool("visibilitySunset");
      visibilityMoonrise = prefs.getBool("visibilityMoonrise");
      visibilityMoonset = prefs.getBool("visibilityMoonset");
      visibilityWindSpeed ??= true;
      visibilityPressure ??= true;
      visibilityWindDirection ??= true;
      visibilityHumidity ??= true;
      visibilityTemperature ??= true;
      visibilityWindChill ??= true;
      visibilityRain ??= true;
      visibilityDew ??= true;
      visibilitySunrise ??= true;
      visibilitySunset ??= true;
      visibilityMoonrise ??= true;
      visibilityMoonset ??= true;
    });
  }

  _retrieveSources() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _sources = new List();
      List<String> sources = prefs.getStringList("sources");
      if (sources != null)
        for (String sourceJSON in sources) {
          try {
            dynamic source = jsonDecode(sourceJSON);
            _sources
                .add(new Source(source["id"], source["name"], source["url"]));
          } catch (Exception) {
            prefs.setStringList("sources", null);
          }
        }
    });
  }
}
