import 'package:flutter/material.dart';

class CustomSearchBox extends StatelessWidget {
  const CustomSearchBox({
    Key key,
    @required this.isVisible,
    @required this.hintText,
    @required this.filterController,
  }) : super(key: key);

  final bool isVisible;
  final String hintText;
  final TextEditingController filterController;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isVisible,
      child: Container(
        margin: EdgeInsets.all(5),
        height: 40,
        child: TextField(
          controller: filterController,
          maxLines: 1,
          style: Theme.of(context).textTheme.bodyText1.copyWith(
                color: Colors.black54,
              ),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: hintText,
            hintStyle: Theme.of(context).textTheme.bodyText1.copyWith(
                  color: Colors.black54,
                ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9.0),
              borderSide: BorderSide.none,
            ),
            fillColor: Color(0xffe6e6ec),
            filled: true,
          ),
        ),
      ),
    );
  }
}
/* final Function onCloseButtonTap;
  final TextEditingController searchFieldController;

  CustomSearchBox({
    this.onCloseButtonTap,
    this.searchFieldController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20.0),
          topLeft: Radius.circular(20.0),
          // bottomRight: Radius.circular(3.0),
          // bottomLeft: Radius.circular(3.0),
        ),
      ),
      padding: const EdgeInsets.only(
        top: 15,
        left: 10.0,
        bottom: 10.0,
        right: 10.0,
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.search,
            color: Colors.blue[800],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 10.0,
                right: 10.0,
              ),
              child: TextFormField(
                autofocus: false,
                controller: searchFieldController,
                decoration: InputDecoration.collapsed(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none),
                  hintText: "Search Employee..",
                  hintStyle: Theme.of(context).textTheme.body2.copyWith(
                        color: Colors.blue[800],
                      ),
                ),
                style: TextStyle(
                  color: Colors.blue[800],
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: onCloseButtonTap,
            child: Icon(
              Icons.close,
              color: Colors.blue[800],
            ),
          ),
        ],
      ),
    );
  }
}*/
