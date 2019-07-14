import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pws_watcher/resources/state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'package:pws_watcher/model/source.dart';
import 'package:highlighter_coachmark/highlighter_coachmark.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final GlobalKey<FormState> _fabKey = GlobalKey<FormState>();
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
  double refreshInterval = 15;

  List<Source> _sources = new List();
  final addNameController = TextEditingController();
  final addUrlController = TextEditingController();
  final editNameController = TextEditingController();
  final editUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getSettings();
    _retrieveSources();
  }

  Future<bool> _onWillPop() async {
    //triggered on device's back button click
    Provider.of<ApplicationState>(context).settingsOpen = false;
    setState(() {
      Provider.of<ApplicationState>(context).updateSources = true;
    });
    return true;
  }

  void closeSettings() {
    //triggered on AppBar back button click
    Provider.of<ApplicationState>(context).settingsOpen = false;
    Navigator.of(context).pop(false);
    setState(() {
      Provider.of<ApplicationState>(context).updateSources = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => closeSettings(),
          ),
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
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _addSource,
          elevation: 2,
          icon: Icon(Icons.add),
          label: Text("add"),
          key: _fabKey,
        ),
        body: Builder(
          builder: (context) => ListView(
            children: <Widget>[
              Card(
                elevation: 2,
                margin:
                    new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
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
                              Provider.of<ApplicationState>(context)
                                  .updateVisibilities = true;
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
                              Provider.of<ApplicationState>(context)
                                  .updateVisibilities = true;
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
                              Provider.of<ApplicationState>(context)
                                  .updateVisibilities = true;
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
                              Provider.of<ApplicationState>(context)
                                  .updateVisibilities = true;
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
                              Provider.of<ApplicationState>(context)
                                  .updateVisibilities = true;
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
                              Provider.of<ApplicationState>(context)
                                  .updateVisibilities = true;
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
                              Provider.of<ApplicationState>(context)
                                  .updateVisibilities = true;
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
                              Provider.of<ApplicationState>(context)
                                  .updateVisibilities = true;
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
                              Provider.of<ApplicationState>(context)
                                  .updateVisibilities = true;
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
                              Provider.of<ApplicationState>(context)
                                  .updateVisibilities = true;
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
                              Provider.of<ApplicationState>(context)
                                  .updateVisibilities = true;
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
                              Provider.of<ApplicationState>(context)
                                  .updateVisibilities = true;
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              prefs.setBool("visibilityMoonset", value);
                            },
                            activeTrackColor: Colors.lightBlueAccent,
                            activeColor: Colors.blue,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            "Widget refresh interval (min):",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Container(
                            margin: EdgeInsets.only(
                              right: 15,
                            ),
                            child: Text(
                              '${refreshInterval.toInt()}',
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Flexible(
                            flex: 1,
                            child: Slider(
                              value: refreshInterval,
                              activeColor: Colors.lightBlue,
                              onChanged: (value) async {
                                setState(() => refreshInterval = value);
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                prefs.setInt(
                                    "widget_refresh_interval", value.toInt());
                              },
                              min: 1,
                              max: 60,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(),
              Padding(
                padding: EdgeInsets.only(bottom: 65),
                child: ListView.builder(
                  physics: ScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: _sources.length,
                  itemBuilder: (context, position) {
                    return Card(
                      elevation: 2,
                      margin: new EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 6.0),
                      child: ListTile(
                          title: Text(
                            _sources[position].name,
                            style: TextStyle(fontSize: 20.0),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            _sources[position].url,
                            style: TextStyle(fontSize: 12.0),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Container(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
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
                          )),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _addSource() {
    showDialog(
      context: context,
      builder: (ctx) => Provider<ApplicationState>.value(
        value: Provider.of<ApplicationState>(context),
        child: AlertDialog(
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
                      return null;
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
                      return null;
                    },
                    decoration: InputDecoration.collapsed(
                        hintText: "Realtime file URL",
                        border: UnderlineInputBorder()),
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
                Navigator.of(ctx).pop();
              },
            ),
            new FlatButton(
              child: new Text("Add"),
              onPressed: () async {
                FocusScope.of(ctx).requestFocus(new FocusNode());
                if (_addFormKey.currentState.validate()) {
                  _addFormKey.currentState.save();
                  Source source = new Source(
                      Provider.of<ApplicationState>(context).countID++,
                      addNameController.text,
                      addUrlController.text);
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  _sources.add(source);
                  List<String> sourcesJSON = new List();
                  for (Source source in _sources) {
                    String sourceJSON = jsonEncode(source);
                    sourcesJSON.add(sourceJSON);
                  }
                  prefs.setStringList("sources", sourcesJSON);
                  prefs.setInt("count_id",
                      Provider.of<ApplicationState>(context).countID);
                  _retrieveSources();
                  Navigator.of(ctx).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
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
                        return null;
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
                        return null;
                      },
                      decoration: InputDecoration.collapsed(
                        hintText: "Realtime file URL",
                        border: UnderlineInputBorder(),
                      ),
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
                SharedPreferences prefs = await SharedPreferences.getInstance();
                List<String> sourcesJSON = new List();
                int index = prefs.getInt("last_used_source") ?? -1;
                if (index == _sources[position].id)
                  prefs.remove("last_used_source");
                _sources.removeAt(position);
                for (Source source in _sources) {
                  String sourceJSON = jsonEncode(source);
                  sourcesJSON.add(sourceJSON);
                }
                prefs.setStringList("sources", sourcesJSON);
                _retrieveSources();
                Navigator.of(context).pop();
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

  Future<Null> _getSettings() async {
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
      refreshInterval = prefs.getInt("widget_refresh_interval").toDouble();
    });
  }

  _retrieveSources() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _sources = new List();
      List<String> sources = prefs.getStringList("sources");
      if (sources == null || sources.length == 0) {
        _showCoachMarkFAB();
      } else
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

  _showCoachMarkFAB() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool("coach_mark_shown") ?? false)) {
      CoachMark coachMarkFAB = CoachMark();
      RenderBox target = _fabKey.currentContext.findRenderObject();
      Rect markRect = target.localToGlobal(Offset.zero) & target.size;
      markRect = Rect.fromCircle(
          center: markRect.center, radius: markRect.longestSide * 0.6);
      coachMarkFAB.show(
          targetContext: _fabKey.currentContext,
          markRect: markRect,
          children: [
            Center(
                child: Text("Tap here\nto add a source",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    )))
          ],
          duration: null,
          onClose: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setBool("coach_mark_shown", true);
          });
    }
  }
}