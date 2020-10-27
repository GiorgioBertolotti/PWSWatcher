import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pws_watcher/model/pws.dart';
import 'package:pws_watcher/pages/settings/widgets/delete_pws_dialog.dart';
import 'package:pws_watcher/pages/settings/widgets/pws_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SourcesSettingsCard extends StatefulWidget {
  final List<PWS> sources;
  final Function updateCallback;

  SourcesSettingsCard(this.sources, this.updateCallback);

  @override
  _SourcesSettingsCardState createState() => _SourcesSettingsCardState();
}

class _SourcesSettingsCardState extends State<SourcesSettingsCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      child: Column(
        children: [
          SizedBox(height: 24.0),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(bottom: 16.0),
            child: Text(
              "PWS",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          ListView.separated(
            physics: ScrollPhysics(),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: widget.sources.length,
            separatorBuilder: (context, position) => Divider(),
            itemBuilder: (context, position) {
              return ListTile(
                  contentPadding: const EdgeInsets.only(
                    left: 24.0,
                    right: 8.0,
                  ),
                  title: Text(
                    widget.sources[position].name,
                    style: Theme.of(context).textTheme.subtitle1,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    widget.sources[position].url,
                    style: Theme.of(context).textTheme.caption,
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
                          onPressed: () => _editSource(position),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Colors.red[700],
                          ),
                          onPressed: () => _deleteSource(position),
                        ),
                      ],
                    ),
                  ));
            },
          ),
          SizedBox(height: 24.0),
        ],
      ),
    );
  }

  _editSource(int position) async {
    PWS source = await showDialog(
      context: context,
      builder: (BuildContext ctx) => PWSDialog(
        mode: PWSDialogMode.EDIT,
        source: widget.sources[position],
        theme: Theme.of(context),
      ),
    );

    if (source != null) {
      widget.sources[position].name = source.name;
      widget.sources[position].url = source.url;
      widget.sources[position].autoUpdateInterval = source.autoUpdateInterval;
      widget.sources[position].snapshotUrl = source.snapshotUrl;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setStringList("sources", _encodeSources());

      if (widget.updateCallback != null) {
        widget.updateCallback();
      }
    }
  }

  _deleteSource(int position) async {
    bool delete = await showDialog(
      context: context,
      builder: (BuildContext ctx) => DeletePWSDialog(
        widget.sources[position],
        context,
      ),
    );

    if (delete != null && delete) {
      widget.sources.removeAt(position);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setStringList("sources", _encodeSources());

      if (widget.updateCallback != null) {
        widget.updateCallback();
      }
    }
  }

  // Populate sources list as a list of JSONS to be stored in shared prefs
  List<String> _encodeSources() {
    List<String> sourcesJSON = List();

    for (PWS source in widget.sources) {
      String sourceJSON = jsonEncode(source);
      sourcesJSON.add(sourceJSON);
    }

    return sourcesJSON;
  }
}
