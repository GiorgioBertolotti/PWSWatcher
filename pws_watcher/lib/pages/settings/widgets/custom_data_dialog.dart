import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:pws_watcher/model/custom_data.dart';

enum CustomDataDialogMode { ADD, EDIT }

const double inputHeight = 59.0;

class CustomDataDialog extends StatefulWidget {
  final CustomDataDialogMode mode;
  final CustomData original;
  final ThemeData theme;

  CustomDataDialog({
    @required this.mode,
    this.original,
    this.theme,
  }) {
    if (this.mode == CustomDataDialogMode.EDIT && this.original == null) {
      throw Exception(
        'If the mode is EDIT you should set the original custom data',
      );
    }
  }

  @override
  _CustomDataDialogState createState() => _CustomDataDialogState();
}

class _CustomDataDialogState extends State<CustomDataDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _unitController = TextEditingController();
  IconData _icon;

  FocusNode _nameFocusNode = FocusNode();
  FocusNode _unitFocusNode = FocusNode();

  @override
  void initState() {
    if (widget.mode == CustomDataDialogMode.EDIT) {
      _nameController.text = widget.original.name;
      _unitController.text = widget.original.unit;
      _icon = widget.original.icon;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final CustomDataDialogMode mode = widget.mode;

    return AlertDialog(
      title: Text(mode == CustomDataDialogMode.ADD
          ? "Add custom data"
          : "Edit ${widget.original.name}"),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("You can add a new custom data to show in home."),
              Text(
                  "You can find all the variable names by opening the Detail Page from pressing the \"SEE ALL\" button in home."),
              SizedBox(height: 16.0),
              Container(
                height: inputHeight,
                width: screenWidth,
                margin: const EdgeInsets.only(bottom: 12.0),
                child: TextFormField(
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return "You must set the variable name.";
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "Variable name *",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 1,
                  focusNode: _nameFocusNode,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (value) =>
                      FocusScope.of(context).requestFocus(_unitFocusNode),
                ),
              ),
              Container(
                height: inputHeight,
                width: screenWidth,
                margin: const EdgeInsets.only(bottom: 12.0),
                child: TextFormField(
                  controller: _unitController,
                  decoration: InputDecoration(
                    labelText: "Unit of measure",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 1,
                  focusNode: _unitFocusNode,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (value) => _save(),
                ),
              ),
              _icon != null
                  ? FlatButton.icon(
                      icon: Icon(_icon),
                      textColor: Colors.white,
                      color: widget.theme.primaryColor,
                      label: Text("Change icon"),
                      onPressed: _pickIcon,
                    )
                  : FlatButton(
                      textColor: Colors.white,
                      color: widget.theme.primaryColor,
                      child: Text("Add an icon"),
                      onPressed: _pickIcon,
                    ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        FlatButton(
          textColor: widget.theme.buttonColor,
          child: Text("Close"),
          onPressed: () => Navigator.of(context).pop(),
        ),
        FlatButton(
          textColor: Colors.white,
          color: widget.theme.primaryColor,
          child: Text(mode == CustomDataDialogMode.ADD ? "Add" : "Edit"),
          onPressed: _save,
        ),
      ],
    );
  }

  // FUNCTIONS

  _pickIcon() async {
    IconData icon = await FlutterIconPicker.showIconPicker(
      context,
      iconPackMode: IconPack.lineAwesomeIcons,
      iconColor: Colors.black,
      showTooltips: true,
    );

    _icon = icon;
    setState(() {});
  }

  _save() {
    // Closes keyboard
    FocusScope.of(context).requestFocus(FocusNode());

    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      CustomData customData;

      if (widget.mode == CustomDataDialogMode.ADD) {
        customData = CustomData(
          name: _nameController.text,
          unit: _unitController.text,
          icon: _icon,
        );
      } else {
        customData = widget.original;

        customData.name = _nameController.text;
        customData.unit = _unitController.text;
        customData.icon = _icon;
      }

      Navigator.of(context).pop(customData);
    }
  }
}
