import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pulse_india/components/custom_list_separator.dart';

class SearchInDropdown<T> extends StatefulWidget {
  final List<int> showIndexes;
  final Function updateList;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T> onChanged;
  final T value;
  final TextStyle style;
  final Widget searchHint;
  final Widget hint;
  final Widget disabledHint;
  final Widget icon;
  final Widget underline;
  final Color iconEnabledColor;
  final Color iconDisabledColor;
  final double iconSize;
  final bool isExpanded;

  SearchInDropdown({
    Key key,
    @required this.items,
    @required this.onChanged,
    this.value,
    this.style,
    this.searchHint,
    this.hint,
    this.disabledHint,
    this.icon,
    this.underline,
    this.iconEnabledColor,
    this.iconDisabledColor,
    this.iconSize = 24.0,
    this.isExpanded = false,
    this.showIndexes,
    this.updateList,
  })  : assert(items != null),
        assert(iconSize != null),
        assert(isExpanded != null),
        super(key: key);

  @override
  _SearchInDropdownState<T> createState() => new _SearchInDropdownState();
}

class _SearchInDropdownState<T> extends State<SearchInDropdown<T>> {
  bool _tapInProgress = false;

  void _tapDown(TapDownDetails details) {
    setState(() {
      _tapInProgress = true;
    });
  }

  void _tapUp(TapUpDetails details) {
    setState(() {
      _tapInProgress = false;
    });
  }

  void _tapCancel() {
    setState(() {
      _tapInProgress = false;
    });
  }

  TextStyle get _textStyle =>
      widget.style ??
      Theme.of(context).textTheme.subtitle2.copyWith(
            color: Colors.black54,
          );
  bool get _enabled =>
      widget.items != null &&
      widget.items.isNotEmpty &&
      widget.onChanged != null;
  int _selectedIndex;

  Icon defaultIcon = Icon(Icons.arrow_drop_down);

  Color get _iconColor {
    // These colors are not defined in the Material Design spec.
    if (_enabled) {
      if (widget.iconEnabledColor != null) {
        return widget.iconEnabledColor;
      }

      switch (Theme.of(context).brightness) {
        case Brightness.light:
          return Colors.grey.shade700;
        case Brightness.dark:
          return Colors.white70;
      }
    } else {
      if (widget.iconDisabledColor != null) {
        return widget.iconDisabledColor;
      }

      switch (Theme.of(context).brightness) {
        case Brightness.light:
          return Colors.grey.shade400;
        case Brightness.dark:
          return Colors.white10;
      }
    }

    assert(false);
    return null;
  }

  void _updateSelectedIndex() {
    if (!_enabled) {
      return;
    }

    assert(widget.value == null ||
        widget.items
                .where((DropdownMenuItem<T> item) => item.value == widget.value)
                .length ==
            1);
    _selectedIndex = null;
    for (int itemIndex = 0; itemIndex < widget.items.length; itemIndex++) {
      if (widget.items[itemIndex].value == widget.value) {
        _selectedIndex = itemIndex;
        return;
      }
    }
  }

  @override
  void initState() {
    _updateSelectedIndex();
    super.initState();
  }

  @override
  void didUpdateWidget(SearchInDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateSelectedIndex();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> items =
        _enabled ? List<Widget>.from(widget.items) : <Widget>[];
    int hintIndex;
    if (widget.hint != null || (!_enabled && widget.disabledHint != null)) {
      final Widget emplacedHint = _enabled
          ? Padding(
              padding: const EdgeInsets.only(
                left: 8.0,
                right: 8.0,
              ),
              child: widget.hint,
            )
          : DropdownMenuItem<Widget>(
              child: widget.disabledHint ??
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 8.0,
                      right: 8.0,
                    ),
                    child: widget.hint,
                  ));
      hintIndex = items.length;
      items.add(
        DefaultTextStyle(
          style: _textStyle.copyWith(
            color: Colors.black54,
          ),
          child: IgnorePointer(
            child: emplacedHint,
            ignoringSemantics: false,
          ),
        ),
      );
    }
    final int index = _enabled ? (_selectedIndex ?? hintIndex) : hintIndex;
    Widget innerItemsWidget;
    if (items.isEmpty) {
      innerItemsWidget = Container();
    } else {
      innerItemsWidget = IndexedStack(
        index: index,
        alignment: AlignmentDirectional.centerStart,
        children: items,
      );
    }

    Widget result = GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: _tapDown,
      onTapUp: _tapUp,
      onTapCancel: _tapCancel,
      onTap: () async {
        print('called');
        T value = await showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) {
            return widget.items.length == 0
                ? Card(
                    child: Text(
                      'Not Available',
                      style: Theme.of(context).textTheme.bodyText2.copyWith(
                            color: Colors.black54,
                          ),
                    ),
                  )
                : DropdownDialog(
                    items: widget.items,
                    hint: widget.searchHint,
                    indexes: widget.showIndexes,
                    updateList: widget.updateList,
                  );
          },
        );
        if (widget.onChanged != null && value != null) {
          widget.onChanged(value);
        }
        print(value);
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Container(
          height: 40.0,
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).accentColor,
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(5.0),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              widget.isExpanded
                  ? Expanded(child: innerItemsWidget)
                  : innerItemsWidget,
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconTheme(
                  data: IconThemeData(
                    color: _iconColor,
                    size: widget.iconSize,
                  ),
                  child: widget.icon ?? defaultIcon,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final double bottom = 8.0;
    return result; // widget.isDense ? 0.0 : 8.0;
  }
}

class DropdownDialog<T> extends StatefulWidget {
  final Function updateList;
  final List<int> indexes;
  final List<DropdownMenuItem<T>> items;
  final Widget hint;
  final bool isCaseSensitiveSearch;

  DropdownDialog({
    Key key,
    this.items,
    this.hint,
    this.isCaseSensitiveSearch = false,
    this.indexes,
    this.updateList,
  })  : assert(items != null),
        super(key: key);

  _DropdownDialogState createState() => new _DropdownDialogState();
}

class _DropdownDialogState extends State<DropdownDialog> {
  TextEditingController txtSearch = new TextEditingController();
  TextStyle defaultButtonStyle = new TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );
  // List<int> shownIndexes = [];

  /*void _updateShownIndexes(String keyword) {
    widget.indexes.clear();
    int i = 0;
    widget.items.forEach((item) {
      bool isContains = false;
      isContains =
          item.value.toString().toLowerCase().contains(keyword.toLowerCase());
      if (keyword.isEmpty || isContains) {
        widget.indexes.add(i);
      }
      i++;
    });
  }*/

  @override
  void initState() {
    widget.updateList('');
    // _updateShownIndexes('');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            titleBar(),
            searchBar(),
            list(),
            buttonWrapper(),
          ],
        ),
      ),
    );
  }

  Widget titleBar() {
    return widget.hint != null
        ? new Container(
            margin: EdgeInsets.only(
              bottom: 8,
            ),
            child: widget.hint,
          )
        : new Container();
  }

  Widget searchBar() {
    return new Container(
      child: new Stack(
        children: <Widget>[
          new Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: new Center(
              child: new Icon(
                Icons.search,
                size: 24,
              ),
            ),
          ),
          new TextField(
            controller: txtSearch,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 5,
              ),
            ),
            style: Theme.of(context).textTheme.bodyText2.copyWith(
                  color: Colors.black54,
                ),
            //  autofocus: true,
            onChanged: (value) {
              widget.updateList(value);
              //_updateShownIndexes(value);
              setState(() {});
            },
          ),
          txtSearch.text.isNotEmpty
              ? new Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: new Center(
                    child: new InkWell(
                      onTap: () {
                        widget.updateList('');
                        //_updateShownIndexes('');
                        setState(() {
                          txtSearch.text = '';
                        });
                      },
                      borderRadius: BorderRadius.all(Radius.circular(32)),
                      child: new Container(
                        width: 32,
                        height: 32,
                        child: new Center(
                          child: new Icon(
                            Icons.close,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : new Container(),
        ],
      ),
    );
  }

  Widget list() {
    print('items length : ${widget.indexes.length}');
    return Expanded(
      child: CupertinoScrollbar(
        child: ListView.separated(
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            DropdownMenuItem item = widget.items[widget.indexes[index]];
            return GestureDetector(
              onTap: () {
                Navigator.pop(context, item.value);
              },
              child: item,
            );
          },
          itemCount: widget.indexes.length,
          separatorBuilder: (context, index) {
            return CustomListSeparator();
          },
        ),
      ),
    );
  }

  Widget buttonWrapper() {
    return new Container(
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          new FlatButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: new Text('Close', style: defaultButtonStyle),
          )
        ],
      ),
    );
  }
}
