import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pws_watcher/get_it_setup.dart';
import 'package:pws_watcher/model/state\.dart';
import 'package:pws_watcher/pages/settings/widgets/add_pws_dialog.dart';
import 'package:pws_watcher/pages/settings/widgets/delete_pws_dialog.dart';
import 'package:pws_watcher/pages/settings/widgets/edit_pws_dialog.dart';
import 'package:pws_watcher/pages/settings/widgets/theme_settings_card.dart';
import 'package:pws_watcher/pages/settings/widgets/unit_settings_card.dart';
import 'package:pws_watcher/pages/settings/widgets/visibility_settings_card.dart';
import 'package:pws_watcher/pages/settings/widgets/widget_settings_card.dart';
import 'package:pws_watcher/services/theme_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'package:pws_watcher/model/pws.dart';
import 'package:showcaseview/showcaseview.dart';

class SettingsPage extends StatefulWidget {
  final ThemeService themeService = getIt<ThemeService>();

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with TickerProviderStateMixin {
  final GlobalKey _fabKey = GlobalKey();

  List<PWS> _sources = List();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  BuildContext _showCaseContext;

  @override
  void initState() {
    super.initState();
    _retrieveSources();
  }

  Future<bool> _onWillPop() async {
    //triggered on device's back button click
    if (_sources.length == 0) {
      _showNoPWSFlushbar();
      return false;
    }
    Provider.of<ApplicationState>(context, listen: false).settingsOpen = false;
    setState(() {
      Provider.of<ApplicationState>(context, listen: false).updateSources =
          true;
    });
    return true;
  }

  void closeSettings() {
    if (_sources.length == 0) {
      _showNoPWSFlushbar();
      return;
    }
    //triggered on AppBar back button click
    Provider.of<ApplicationState>(
      context,
      listen: false,
    ).settingsOpen = false;
    Navigator.of(context).pop(false);
    setState(() {
      Provider.of<ApplicationState>(
        context,
        listen: false,
      ).updateSources = true;
    });
  }

  _showNoPWSFlushbar() {
    Flushbar(
      title: "Wait a second",
      message: "You should add a PWS to monitor",
      duration: Duration(seconds: 3),
      animationDuration: Duration(milliseconds: 350),
      mainButton: FlatButton(
        onPressed: () => _showShowcase(),
        child: Text(
          "HELP",
          style: TextStyle(color: Colors.amber),
        ),
      ),
    )..show(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: ShowCaseWidget(
        builder: Builder(
          builder: (context) {
            _showCaseContext = context;
            return ListTileTheme(
              iconColor: Theme.of(context).iconTheme.color,
              child: Scaffold(
                key: _scaffoldKey,
                appBar: AppBar(
                  brightness: Brightness.dark,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => closeSettings(),
                  ),
                  actions: <Widget>[
                    IconButton(
                      icon: Icon(Icons.help, color: Colors.white),
                      onPressed: () => _showShowcase(),
                      tooltip: "Show tutorial",
                    )
                  ],
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
                floatingActionButton: Showcase(
                  onTargetClick: _addSource,
                  disposeOnTap: true,
                  key: _fabKey,
                  title: "Add PWS",
                  description: "Tap here to add your PWS info",
                  shapeBorder: CircleBorder(),
                  child: FloatingActionButton.extended(
                    onPressed: _addSource,
                    elevation: 2,
                    icon: Icon(
                      Icons.add,
                    ),
                    label: Text(
                      "add",
                    ),
                  ),
                ),
                body: Builder(
                  builder: (context) => ListView(
                    addAutomaticKeepAlives: true,
                    children: <Widget>[
                      ThemeSettingsCard(),
                      UnitSettingsCard(),
                      VisibilitySettingsCard(),
                      WidgetSettingsCard(),
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
                              margin: EdgeInsets.symmetric(
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
          },
        ),
      ),
    );
  }

  _addSource() async {
    var source = await showDialog(
      context: context,
      builder: (ctx) {
        var provider = Provider<ApplicationState>.value(
          value: Provider.of<ApplicationState>(context, listen: false),
          child: AddPWSDialog(_showCaseContext),
        );
        return provider;
      },
    );
    if (source != null && source is PWS) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _sources.add(source);
      List<String> sourcesJSON = List();
      for (PWS source in _sources) {
        String sourceJSON = jsonEncode(source);
        sourcesJSON.add(sourceJSON);
      }
      prefs.setStringList("sources", sourcesJSON);
      prefs.setInt(
          "count_id",
          Provider.of<ApplicationState>(
            context,
            listen: false,
          ).countID);
      _retrieveSources();
    }
  }

  _editSource(int position) async {
    var source = await showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return EditPWSDialog(_sources[position], context);
        });
    if (source != null && source is PWS) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _sources[position].name = source.name;
      _sources[position].url = source.url;
      _sources[position].autoUpdateInterval = source.autoUpdateInterval;
      _sources[position].snapshotUrl = source.snapshotUrl;
      List<String> sourcesJSON = List();
      for (PWS source in _sources) {
        String sourceJSON = jsonEncode(source);
        sourcesJSON.add(sourceJSON);
      }
      prefs.setStringList("sources", sourcesJSON);
      _retrieveSources();
    }
  }

  _deleteSource(int position) async {
    var delete = await showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return DeletePWSDialog(_sources[position], context);
      },
    );
    if (delete != null && delete is bool && delete) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> sourcesJSON = List();
      int index = prefs.getInt("last_used_source") ?? -1;
      if (index == _sources[position].id) prefs.remove("last_used_source");
      _sources.removeAt(position);
      for (PWS source in _sources) {
        String sourceJSON = jsonEncode(source);
        sourcesJSON.add(sourceJSON);
      }
      prefs.setStringList("sources", sourcesJSON);
      _retrieveSources();
    }
  }

  _retrieveSources() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _sources = List();
      List<String> sources = prefs.getStringList("sources");
      if (sources == null || sources.length == 0) {
        _shouldShowcase().then((shouldShow) {
          if (shouldShow) {
            ShowCaseWidget.of(_showCaseContext).startShowCase([_fabKey]);
          }
        });
      } else
        for (String sourceJSON in sources) {
          try {
            dynamic source = jsonDecode(sourceJSON);
            _sources.add(PWS(
              source["id"],
              source["name"],
              source["url"],
              autoUpdateInterval: (source["autoUpdateInterval"] != null)
                  ? source["autoUpdateInterval"]
                  : 0,
              snapshotUrl: source["snapshotUrl"],
            ));
          } catch (Exception) {
            prefs.setStringList("sources", null);
          }
        }
    });
  }

  Future<bool> _shouldShowcase() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool shouldShow = !(prefs.getBool("showcase_1") ?? false);
    if (shouldShow) {
      prefs.setBool("showcase_1", true);
    }
    return shouldShow;
  }

  _showShowcase() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("showcase_2", false);
    ShowCaseWidget.of(_showCaseContext).startShowCase([_fabKey]);
  }
}
