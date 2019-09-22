import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pws_watcher/resources/state.dart';

class DetailPage extends StatefulWidget {
  DetailPage(this.data);

  final Map<String, String> data;

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final TextEditingController controller = TextEditingController();
  String filter;

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
    return Theme(
      data: ThemeData(
          primarySwatch: Provider.of<ApplicationState>(context).mainColor),
      child: WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Scaffold(
          backgroundColor:
              Provider.of<ApplicationState>(context).theme == PWSTheme.Blacked
                  ? Colors.black
                  : null,
          appBar: AppBar(
            brightness: Brightness.dark,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            backgroundColor: Provider.of<ApplicationState>(context).mainColor,
            title: Text(
              "Detail page",
              maxLines: 1,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                child: Provider.of<ApplicationState>(context).theme ==
                        PWSTheme.Blacked
                    ? _blackedSearch()
                    : TextField(
                        decoration: InputDecoration(
                          labelText: "Search",
                          labelStyle: TextStyle(fontSize: 20.0),
                        ),
                        controller: controller,
                        cursorColor:
                            Provider.of<ApplicationState>(context).mainColor,
                        style: TextStyle(fontSize: 20.0),
                      ),
              ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.data.length,
                  itemBuilder: (context, position) {
                    String key = widget.data.entries.elementAt(position).key;
                    if ((filter == null || filter.trim().isEmpty) ||
                        (filter != null &&
                            filter.trim().isNotEmpty &&
                            key.contains(filter.trim())))
                      return ListTile(
                        title: Text(
                          key,
                          style: TextStyle(
                            fontSize: 20.0,
                            color:
                                Provider.of<ApplicationState>(context).theme ==
                                        PWSTheme.Blacked
                                    ? Colors.white
                                    : null,
                          ),
                        ),
                        subtitle: Text(
                          widget.data.entries.elementAt(position).value,
                          style: TextStyle(
                            fontSize: 16.0,
                            color:
                                Provider.of<ApplicationState>(context).theme ==
                                        PWSTheme.Blacked
                                    ? Colors.white
                                    : null,
                          ),
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

  Widget _blackedSearch() {
    const MaterialColor white = const MaterialColor(
      0xFFFFFFFF,
      const <int, Color>{
        50: const Color(0xFFFFFFFF),
        100: const Color(0xFFFFFFFF),
        200: const Color(0xFFFFFFFF),
        300: const Color(0xFFFFFFFF),
        400: const Color(0xFFFFFFFF),
        500: const Color(0xFFFFFFFF),
        600: const Color(0xFFFFFFFF),
        700: const Color(0xFFFFFFFF),
        800: const Color(0xFFFFFFFF),
        900: const Color(0xFFFFFFFF),
      },
    );
    return Theme(
      data: ThemeData(primarySwatch: white),
      child: TextField(
        decoration: InputDecoration(
          labelText: "Search",
          labelStyle: TextStyle(
            fontSize: 20.0,
            color: Colors.white,
          ),
          suffixStyle: TextStyle(color: Colors.white),
          counterStyle: TextStyle(color: Colors.white),
          errorStyle: TextStyle(color: Colors.white),
          helperStyle: TextStyle(color: Colors.white),
          hintStyle: TextStyle(color: Colors.white),
          prefixStyle: TextStyle(color: Colors.white),
          fillColor: Colors.white,
          focusColor: Colors.white,
          hoverColor: Colors.white,
        ),
        controller: controller,
        cursorColor: Colors.white,
        style: TextStyle(
          fontSize: 20.0,
          color: Colors.white,
        ),
      ),
    );
  }
}
