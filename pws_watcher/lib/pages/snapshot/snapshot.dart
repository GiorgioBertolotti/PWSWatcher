import 'dart:async';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:image_downloader/image_downloader.dart';

class SnapshotPage extends StatefulWidget {
  SnapshotPage(
    this.urlImage,
    this.title, {
    this.description,
    this.download = false,
    this.downloadName,
    this.padding,
    this.backgroundColor,
  });

  final String? title;
  final String? urlImage;
  final String? description;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final bool download;
  final String? downloadName;

  @override
  _SnapshotPageState createState() => _SnapshotPageState();
}

class _SnapshotPageState extends State<SnapshotPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  int _requestCounter = 0;

  @override
  void initState() {
    super.initState();
    imageCache!.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('dismissible'),
      direction: DismissDirection.vertical,
      onDismissed: (direction) {
        Navigator.pop(context);
      },
      background: Container(
        color: widget.backgroundColor,
      ),
      movementDuration: Duration(milliseconds: 100),
      resizeDuration: Duration(milliseconds: 100),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: widget.backgroundColor,
        appBar: widget.title != null
            ? AppBar(
                iconTheme: IconThemeData(color: Colors.white),
                backgroundColor: Colors.black,
                title: Text(
                  widget.title!,
                  style: Theme.of(context).textTheme.headline6!.copyWith(color: Colors.white),
                ),
                actions: <Widget>[
                  IconButton(
                      icon: Icon(Icons.refresh),
                      onPressed: () => this.setState(() {
                            _requestCounter++;
                          })),
                  widget.download
                      ? IconButton(icon: Icon(Icons.file_download), onPressed: () => _downloadImageFromUrl())
                      : Container(),
                ],
              )
            : null,
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            _getPhotoView(),
            widget.description != null
                ? Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      color: Colors.black45,
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        widget.description!,
                        textAlign: TextAlign.start,
                        style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.white),
                      ),
                    ),
                  )
                : new Container(),
          ],
        ),
      ),
    );
  }

  Future<Null> _downloadImageFromUrl() async {
    PermissionStatus permission = await Permission.storage.status;

    if (!permission.isGranted) {
      PermissionStatus response = await Permission.storage.request();

      if (!response.isGranted) {
        showSimpleNotification(
          Text("Please grant the permissions to download the image 🙏🏻"),
          background: Colors.grey[800],
          foreground: Colors.white,
          autoDismiss: true,
          duration: Duration(seconds: 2),
          position: NotificationPosition.bottom,
          slideDismissDirection: DismissDirection.down,
        );
        return;
      }
    }
    try {
      var imageId = await ImageDownloader.downloadImage(widget.urlImage!,
          destination:
              AndroidDestinationType.custom(directory: 'Download', subDirectory: widget.downloadName! + ".png"));
      if (imageId == null) {
        return;
      }
    } catch (error) {
      print(error);
    }
  }

  Widget _getPhotoView() {
    String url = widget.urlImage! +
        (widget.urlImage!.contains("?") ? ("&n=" + _requestCounter.toString()) : ("?n=" + _requestCounter.toString()));
    return PhotoView.customChild(
      childSize: const Size(100, 100),
      backgroundDecoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: Container(
        padding: widget.padding,
        color: Colors.transparent,
        child: Image.network(url),
      ),
    );
  }
}
