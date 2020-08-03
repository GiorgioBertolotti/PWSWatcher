import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pws_watcher/model/pws.dart';
import 'package:pws_watcher/model/state.dart';
import 'package:pws_watcher/pages/snapshot/snapshot.dart';

class SnapshotPreview extends StatelessWidget {
  SnapshotPreview(this.pws);

  final PWS pws;
  final double borderRadius = 15.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      height: 100.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: Colors.transparent,
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(this.pws.snapshotUrl),
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromRGBO(0, 0, 0, 0.2),
                  Color.fromRGBO(0, 0, 0, 0.8),
                ],
              ),
            ),
          ),
          Positioned(
            left: 20.0,
            bottom: 10.0,
            child: Text(
              "Webcam Preview",
              style: Theme.of(context)
                  .textTheme
                  .bodyText2
                  .copyWith(color: Colors.white),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => Provider<ApplicationState>.value(
                      value:
                          Provider.of<ApplicationState>(context, listen: false),
                      child: SnapshotPage(
                        this.pws.snapshotUrl,
                        this.pws.name,
                        backgroundColor: Colors.black,
                        download: true,
                        downloadName: "snapshot_" + this.pws.name,
                      ),
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(borderRadius),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }
}
