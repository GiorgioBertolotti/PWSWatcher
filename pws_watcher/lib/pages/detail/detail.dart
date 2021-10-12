import 'package:flutter/material.dart';
import 'package:pws_watcher/get_it_setup.dart';
import 'package:pws_watcher/services/theme_service.dart';

class DetailPage extends StatefulWidget {
  DetailPage(this.data);

  final Map<String?, String> data;
  final ThemeService? themeService = getIt<ThemeService>();

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final TextEditingController controller = TextEditingController();
  String? filter;

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      setState(() {
        filter = controller.text;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData data = Theme.of(context);
    if (Theme.of(context).brightness == Brightness.light) {
      data = data.copyWith(scaffoldBackgroundColor: Colors.white);
    }
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Theme(
        data: data,
        child: Scaffold(
          appBar: AppBar(
            brightness: Brightness.dark,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            title: Text(
              "Detail page",
              maxLines: 1,
              style: Theme.of(context)
                  .textTheme
                  .headline5!
                  .copyWith(color: Colors.white),
            ),
            centerTitle: true,
          ),
          body: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: "Search",
                    labelStyle: TextStyle(
                      fontSize: Theme.of(context).textTheme.headline6!.fontSize,
                    ),
                  ),
                  controller: controller,
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.headline6!.fontSize,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.data.length,
                  itemBuilder: (context, position) {
                    String? key = widget.data.entries.elementAt(position).key;
                    if ((filter == null || filter!.trim().isEmpty) ||
                        (filter != null &&
                            filter!.trim().isNotEmpty &&
                            key!
                                .toLowerCase()
                                .contains(filter!.trim().toLowerCase())))
                      return ListTile(
                        title: Text(
                          key!,
                          style: Theme.of(context)
                              .textTheme
                              .headline6!
                              .copyWith(fontWeight: FontWeight.normal),
                        ),
                        subtitle: Text(
                          widget.data.entries.elementAt(position).value,
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                      );
                    else
                      return Container();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
