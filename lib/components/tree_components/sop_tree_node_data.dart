import 'package:pulse_india/components/tree_components/TreeView.dart';
import 'package:pulse_india/models/sop.dart';

class SopTreeNodeData extends TreeNodeData<SopTree> {
  SopTreeNodeData.root(SopTree data)
      : super.root(data.Item, data.FullPath, data.FullPath, data);

  SopTreeNodeData.node(SopTree data, SopTreeNodeData parent)
      : super.node(parent, data.Item, data.FullPath, data.FullPath, data);

  @override
  SopTreeNodeData createChild(
      String title, String subTitle, String id, SopTree data,
      [bool expanded = false]) {
    var child = new SopTreeNodeData.node(data, this);
    return child;
  }

  @override
  String get title => data.Item;

  @override

  ///String get subTitle => "${data.SerialNo}";
  String get subTitle => "";

  @override
  String toString() {
    return "${super.toString()}"
        "\nfullpath:${data.FullPath} belongs to:${data.Parent}";
  }

  @override
  Iterable<SopTreeNodeData> operator |(String textToSearch) sync* {
    String cat = "${data.Item}";
    if (cat.toLowerCase().indexOf(textToSearch.toLowerCase()) > -1) {
      hilited = true;
      yield this;
    }
    if (hasChildren)
      for (SopTreeNodeData account in children) yield* account | textToSearch;
  }
}
