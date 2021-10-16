import 'package:pulse_india/handlers/string_handlers.dart';

class SopTree {
  int SerialNo;
  String Item;
  String Parent;
  String FullPath;
  String ChoiceStatus;

  SopTree({
    this.SerialNo,
    this.Item,
    this.Parent,
    this.FullPath,
    this.ChoiceStatus,
  });

  SopTree.fromMap(Map<String, dynamic> map) {
    SerialNo = map[SopTreeConst.SerialNoConst] ?? 0;
    Item = map[SopTreeConst.ItemConst] ?? StringHandlers.NotAvailable;
    Parent =
        map[SopTreeConst.ParentConst].toString() ?? StringHandlers.NotAvailable;
    FullPath = map[SopTreeConst.FullPathConst] ?? StringHandlers.NotAvailable;
    ChoiceStatus =
        map[SopTreeConst.ChoiceStatusConst] ?? StringHandlers.NotAvailable;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        SopTreeConst.SerialNoConst: SerialNo,
        SopTreeConst.ItemConst: Item,
        SopTreeConst.ParentConst: Parent,
        SopTreeConst.FullPathConst: FullPath,
        SopTreeConst.ChoiceStatusConst: ChoiceStatus,
      };
}

class SopTreeConst {
  static const String SerialNoConst = "SerialNo";
  static const String ItemConst = "Item";
  static const String ParentConst = "Parent";
  static const String FullPathConst = "FullPath";
  static const String ChoiceStatusConst = "ChoiceStatus";
}

class SopTreeUrls {
  static const String GET_SOP_TREE = "SOPMasters/GetSOPTree";
}
