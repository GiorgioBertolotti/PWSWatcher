import 'package:flutter/material.dart';

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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
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
            child: TextField(
              decoration: InputDecoration(labelText: "Search"),
              controller: controller,
            ),
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.data.length,
              itemBuilder: (context, position) {
                print(position);
                String key = widget.data.entries.elementAt(position).key;
                if ((filter == null || filter.trim().isEmpty) ||
                    (filter != null &&
                        filter.trim().isNotEmpty &&
                        key.contains(filter.trim())))
                  return ListTile(
                    title: Text(key),
                    subtitle:
                        Text(widget.data.entries.elementAt(position).value),
                  );
                else
                  return Container();
              },
            ),
          ),
        ],
      ),
    );
  }
}
