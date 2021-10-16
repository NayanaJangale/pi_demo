import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:pulse_india/components/flushbar_message.dart';
import 'package:pulse_india/components/tree_components/TreeView.dart';
import 'package:pulse_india/components/tree_components/sop_tree_node_data.dart';
import 'package:pulse_india/constants/http_status_codes.dart';
import 'package:pulse_india/constants/message_types.dart';
import 'package:pulse_india/constants/project_settings.dart';
import 'package:pulse_india/handlers/network_handler.dart';
import 'package:pulse_india/input_components/custom_app_drawer.dart';
import 'package:pulse_india/input_components/loading_shimmer_effect_widget.dart';
import 'package:pulse_india/localization/app_translations.dart';
import 'package:pulse_india/models/sop.dart';

class ViewSopPage extends StatefulWidget {
  @override
  _ViewSopPageState createState() => _ViewSopPageState();
}

class _ViewSopPageState extends State<ViewSopPage> {
  bool isLoading, isNetwork;
  String loadingText;
  String serviceUrl;
  List<SopTree> _lstAccount = [];

  /*RefreshController _refreshController =
  RefreshController(initialRefresh: false);

  void _onRefresh() async {
    fetchSops().then(
          (result) {
        _lstAccount = result != null ? result : [];
      },
    );
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }
*/
  //Callback as highlighting a node
  void _onHiliteNode(dynamic node) {
    // void _onHiliteNode(AccountNodeData node) {
    assert(null != node);

    bool isExist = _mapHilitedNodes.containsKey(node.id);
    if (isExist)
      // flip/flop hilited state
      _mapHilitedNodes.remove(node.id);
    else if (_mapHilitedNodes.length > 0) {
      _mapHilitedNodes.forEach((key, value) {
        value.hilited = false;
      });
      _treeComponent.broadcast(_mapHilitedNodes);

      _mapHilitedNodes.clear();
      // add it
      // node id is actually the full path
      _mapHilitedNodes[node.id] = node;
    } else
      _mapHilitedNodes[node.id] = node;

//    print("On hilte node call back:${_mapHilitedNodes.length}");
  }

  //Callback as selecting a node by ticking the respective checkbox
  void _onSelectNode(dynamic node) {
    //void _onSelectNode(AccountNodeData node) {
    assert(null != node);
    setState(() {
      bool isExist = _mapSelectNodes.containsKey(node.id);
      if (node.isChecked)
        // add it
        // node id is actually the full path
        _mapSelectNodes[node.id] = node;
      else if (isExist) _mapSelectNodes.remove(node.id);
    });

    print("On select node call back:${_mapSelectNodes.length}");
  }

  void _onSearch(String textToSearch) {
    setState(() {
      isLoading = true;
    });

    Iterable<SopTreeNodeData> foundNodes = this | textToSearch;

    // Turn off hilited nodes
    if (_mapHilitedNodes.length > 0) {
      _mapHilitedNodes.forEach((key, value) {
        value.hilited = false;
      });
      _treeComponent.broadcast(_mapHilitedNodes);
    }
    // Hilite new found nodes
    _mapHilitedNodes.clear();
    foundNodes?.forEach((element) {
      _mapHilitedNodes[element.id] = element;
    });

    _treeComponent.broadcast(_mapHilitedNodes);

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    super.initState();

    isLoading = false;
    isNetwork = true;
    loadingText = 'Loading SOP';

    ConnectivityManager().initConnectivity(this.context, this);
    getData();
  }

  getData() {
    fetchSops().then((result) {
      _lstAccount = result;

      // Call API to get the list of shops
      Future<List> future = _getAccountList();

      future.then((value) {
        _treeComponent = new TreeView.multipleRoots(
          _lstTreeNode,
          /*header: new Heading(
            key: new Key("SopHeader"),
            searchCallback: _onSearch,
          ),*/
        );
        _treeComponent.expandIt = false;
        _treeComponent.onSelectNode = _onSelectNode;
        _treeComponent.onEditNode = (dynamic) {};
        _treeComponent.onHiliteNode = _onHiliteNode;

        isLoading = false;
      })
        ..catchError((error) {
          FlushbarMessage.show(
            this.context,
            "Something went wrong .. $error",
            MessageTypes.WARNING,
          );
        });
    });
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppTranslations.of(context).text("key_all_sop"),
        ),
      ),
      drawer: AppDrawer(),
      body:
          /*CustomRefreshIndicator(
        refreshController: _refreshController,
        onRefresh: _onRefresh,
        child: */
          !isLoading
              ? isNetwork
                  ? _lstAccount.isNotEmpty
                      ? _treeComponent
                      : Center(
                          child: Text('Sop Not Available..'),
                        )
                  : Center(
                      child: Text('Network not available..'),
                    )
              : ListView.builder(
                  itemBuilder: (_, __) => LoadingShimmerWidget(
                    enabled: isLoading,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 48.0,
                            height: 48.0,
                            color: Colors.white,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  width: double.infinity,
                                  height: 8.0,
                                  color: Colors.white,
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 2.0),
                                ),
                                Container(
                                  width: double.infinity,
                                  height: 8.0,
                                  color: Colors.white,
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 2.0),
                                ),
                                Container(
                                  width: 40.0,
                                  height: 8.0,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  itemCount: 6,
                ), /*Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Swipe down to load SOP',
                  style: Theme.of(context).textTheme.body2.copyWith(
                        color: Colors.black45,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),*/
      //   ),
    );
  }

  TreeView _treeComponent;
  List<SopTreeNodeData> _lstTreeNode = [];

  Map<String, SopTreeNodeData> _mapSelectNodes = {};
  Map<String, SopTreeNodeData> get selectedNodes => _mapSelectNodes;

  Map<String, SopTreeNodeData> _mapHilitedNodes = {};
  Map<String, SopTreeNodeData> get hilitedNodes => _mapHilitedNodes;

  _AccountMap _mapAccount;
  // API calls
  Future<Null> _getAccountList() async {
    setState(() => isLoading = true);

    _mapAccount = new _AccountMap(_lstAccount);

    _processTreeData();
  }

  void _processTreeData() {
    // Make sure the list is empty
    if (_lstTreeNode != null) {
      _lstTreeNode.clear();
      _lstTreeNode = null;
    }
    _lstTreeNode = [];

    // Get all roots first
    _mapAccount.interMap?.forEach((String key, SopTree account) {
      // if (account.Parent == null || account.Parent.isEmpty ) {
      if (account.Parent == '0') {
        // root _lstTreeNode: e.g. "$1"
        SopTreeNodeData root = new SopTreeNodeData.root(account);
        _lstTreeNode.add(root);
      }
    });

    if (_lstTreeNode.isNotEmpty) {
      _lstTreeNode.forEach((node) => _continueBuildTree(node));
    }
  }

  void _continueBuildTree(SopTreeNodeData node) {
    List<SopTreeNodeData> lstSopTreeNodeDataTemp = [];
    print(node.id);
    Iterable<SopTree> children = _mapAccount ^ node.id;

    children?.forEach((SopTree sopTree) {
      var theChild = node.createChild(
          sopTree.Item, sopTree.SerialNo.toString(), sopTree.FullPath, sopTree);
      lstSopTreeNodeDataTemp.add(theChild);
    });

    if (children.isNotEmpty) {
      // Recursively build tree.
      lstSopTreeNodeDataTemp.forEach((node) => _continueBuildTree(node));
    }
  }

  // Util
  // Search the tree for the text
  Iterable<SopTreeNodeData> operator |(String textToSearch) sync* {
    if (_lstTreeNode?.length > 0) {
      for (SopTreeNodeData account in _lstTreeNode) {
        String cat = "${account.data.Item}";
        if (cat.toLowerCase().indexOf(textToSearch.toLowerCase()) > -1) {
          account.hilited = true;
          yield account;
        }
        if (account.hasChildren)
          for (SopTreeNodeData acc in account.children)
            yield* acc | textToSearch;
      }
    } else
      yield null;
  }

  Future<List<SopTree>> fetchSops() async {
    List<SopTree> sops = [];
    setState(() {
      isLoading = true;
      isNetwork = true;
    });

    try {
      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        if (connectionServerMsg != "key_no_server" &&
            connectionServerMsg != '') {
          serviceUrl = connectionServerMsg;
          Uri fetchSOPsUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                SopTreeUrls.GET_SOP_TREE,
            {},
          );

          print(fetchSOPsUri);

          http.Response response = await http.get(
            fetchSOPsUri,
            headers: NetworkHandler.getHeader(),
          );

          var data = json.decode(response.body);

          if (response.statusCode == HttpStatusCodes.OK) {
            if (data["Status"] != HttpStatusCodes.OK) {
              FlushbarMessage.show(
                context,
                data["Message"],
                MessageTypes.ERROR,
              );
            } else {
              List responseData = data["Data"];
              sops = responseData.map((item) => SopTree.fromMap(item)).toList();
            }
          } else {
            FlushbarMessage.show(
              this.context,
              'Invalid response received (${response.statusCode})',
              MessageTypes.ERROR,
            );
          }
        } else {
          FlushbarMessage.show(
            this.context,
            AppTranslations.of(context).text("key_no_server"),
            MessageTypes.WARNING,
          );
        }
      } else {
        sops = [];

        setState(() {
          isNetwork = false;
        });

        FlushbarMessage.show(
          context,
          AppTranslations.of(context).text("key_check_internet"),
          MessageTypes.WARNING,
        );
      }
    } on SocketException catch (error, stackTrace) {
      FlushbarMessage.show(
        context,
        AppTranslations.of(context).text("key_socket_error"),
        MessageTypes.WARNING,
      );
    } catch (error, stackTrace) {
      print(error);
      FlushbarMessage.show(
        context,
        AppTranslations.of(context).text("key_api_error"),
        MessageTypes.WARNING,
      );
      sops = [];
    }
    print(sops);
    isLoading = false;
    return sops;
  }
}

class _AccountMap {
  Map<String, SopTree> _mAccount;

  _AccountMap(List<SopTree> lstAccount) {
    if (lstAccount?.length > 0) {
      _mAccount = new Map.fromIterable(
        lstAccount,
        key: (sopTree) => sopTree.FullPath.toString(),
      );
    }
  }
  // Return all the direct children of this key
  Iterable<SopTree> operator ^(String thisKey) sync* {
    if (_mAccount?.length > 0) {
      if (_mAccount[thisKey] == null) yield null;
      String pattern = "$thisKey\$";

      for (SopTree sopTree in _mAccount.values) {
        if (sopTree.FullPath.replaceFirst(pattern, '') == sopTree.ChoiceStatus)
          yield sopTree;
      }
    } else
      yield null;
  }

  SopTree operator [](String key) {
    if (_mAccount?.length > 0)
      return _mAccount[key];
    else
      return null;
  }

  void operator []=(String key, SopTree value) {
    if (_mAccount != null) _mAccount[key] = value;
  }

  void clear() {
    if (_mAccount != null) {
      _mAccount.clear();
      _mAccount = null;
    }
  }

  void remove(String key) {
    if (_mAccount != null) _mAccount.remove(key);
  }

  int get length => _mAccount?.length;

  Map<String, SopTree> get interMap => _mAccount;
}
