import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:pws_watcher/get_it_setup.dart';
import 'package:pws_watcher/model/state\.dart';
import 'package:pws_watcher/pages/settings/widgets/pws_dialog.dart';
import 'package:pws_watcher/pages/settings/widgets/sources_settings_card.dart';
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

  List<PWS> _sources = [];
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  BuildContext _showCaseContext;

  @override
  void initState() {
    super.initState();
    _retrieveSources();
  }

  //triggered on device's back button click
  Future<bool> _onWillPop() async {
    if (_sources.isEmpty) {
      _emptySourcesError();
      return false;
    }

    return true;
  }

  //triggered on AppBar back button click
  void _closeSettings() {
    if (_sources.isEmpty) {
      _emptySourcesError();
      return;
    }

    Navigator.of(context).pop(false);
  }

  _emptySourcesError() {
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
                appBar: _buildAppBar(),
                floatingActionButton: _buildFAB(),
                body: _buildBody(),
              ),
            );
          },
        ),
      ),
    );
  }

  // FUNCTIONS

  _addSource() async {
    PWS source = await showDialog(
      context: context,
      builder: (ctx) => provider.Provider<ApplicationState>.value(
        value: provider.Provider.of<ApplicationState>(context, listen: false),
        child: PWSDialog(
          mode: PWSDialogMode.ADD,
          theme: Theme.of(context),
        ),
      ),
    );

    if (source != null) {
      _sources.add(source);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setStringList("sources", _encodeSources());
      prefs.setInt(
        "count_id",
        provider.Provider.of<ApplicationState>(
          context,
          listen: false,
        ).countID,
      );

      _retrieveSources();
    }
  }

  // Populate sources list as a list of JSONS to be stored in shared prefs
  List<String> _encodeSources() {
    List<String> sourcesJSON = List();

    for (PWS source in _sources) {
      String sourceJSON = jsonEncode(source);
      sourcesJSON.add(sourceJSON);
    }

    return sourcesJSON;
  }

  _retrieveSources() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Clear the list of sources before retrieving the new one
    _sources = List();

    List<String> sources = prefs.getStringList("sources");

    if (sources == null || sources.isEmpty) {
      _shouldShowcase().then((shouldShow) {
        if (shouldShow) {
          ShowCaseWidget.of(_showCaseContext).startShowCase([_fabKey]);
        }
      });
    } else {
      for (String sourceJSON in sources) {
        try {
          dynamic source = jsonDecode(sourceJSON);

          _sources.add(PWS(
            source["id"],
            source["name"],
            source["url"],
            autoUpdateInterval: source["autoUpdateInterval"] ?? 0,
            snapshotUrl: source["snapshotUrl"],
          ));
        } catch (Exception) {
          prefs.setStringList("sources", null);
        }
      }
    }

    setState(() {});
  }

  Future<bool> _shouldShowcase() async {
    // showcase_1 indicates whether the showcase around the FAB should be shown
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool shouldShow = !(prefs.getBool("showcase_1") ?? false);

    if (shouldShow) {
      prefs.setBool("showcase_1", true);
    }

    return shouldShow;
  }

  _showShowcase() async {
    // showcase_2 indicates whether the showcase in the PWSDialog should be shown
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("showcase_2", false);

    ShowCaseWidget.of(_showCaseContext).startShowCase([_fabKey]);
  }

  // WIDGETS

  Widget _buildAppBar() {
    return AppBar(
      brightness: Brightness.dark,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => _closeSettings(),
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
        style:
            Theme.of(context).textTheme.headline5.copyWith(color: Colors.white),
      ),
      centerTitle: true,
    );
  }

  Widget _buildFAB() {
    return Showcase(
      onTargetClick: _addSource,
      disposeOnTap: true,
      key: _fabKey,
      title: "Add PWS",
      description: "Tap here to add your PWS info",
      shapeBorder: CircleBorder(),
      child: FloatingActionButton.extended(
        onPressed: _addSource,
        elevation: 2,
        icon: Icon(Icons.add),
        label: Text("add"),
      ),
    );
  }

  Widget _buildBody() {
    return Builder(
      builder: (context) => ListView(
        addAutomaticKeepAlives: true,
        children: <Widget>[
          _sources.isNotEmpty
              ? SourcesSettingsCard(_sources, _retrieveSources)
              : Container(),
          ThemeSettingsCard(),
          UnitSettingsCard(),
          VisibilitySettingsCard(),
          WidgetSettingsCard(),
          SizedBox(height: 65.0),
        ],
      ),
    );
  }
}
