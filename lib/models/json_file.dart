import 'package:pulse_india/handlers/string_handlers.dart';

class JFile {
  int JSONFILEID;
  int FILEID;
  String FILE_NAME;
  DateTime Filedate;
  String CONTAINER_NO;
  String WEIGHT;
  String FOLDER_PATH;
  DateTime ENTDATETIME;
  List<ItemDetails> Details;

  JFile({
    this.JSONFILEID,
    this.FILEID,
    this.FILE_NAME,
    this.Filedate,
    this.CONTAINER_NO,
    this.WEIGHT,
    this.FOLDER_PATH,
    this.ENTDATETIME,
    this.Details,
  });

  JFile.fromMap(Map<String, dynamic> map) {
    JSONFILEID = map[JFileConst.JSONFILEIDConst] ?? 0;
    FILEID = map[JFileConst.FILEIDConst] ?? 0;
    FILE_NAME = map[JFileConst.FILE_NAMEConst] ?? StringHandlers.NotAvailable;
    Filedate = map[JFileConst.FiledateConst] != null
        ? DateTime.parse(map[JFileConst.FiledateConst])
        : null;
    CONTAINER_NO =
        map[JFileConst.CONTAINER_NOConst] ?? StringHandlers.NotAvailable;
    WEIGHT = map[JFileConst.WEIGHTConst] ?? StringHandlers.NotAvailable;
    FOLDER_PATH =
        map[JFileConst.FOLDER_PATHConst] ?? StringHandlers.NotAvailable;
    ENTDATETIME = map[JFileConst.ENTDATETIMEConst] != null
        ? DateTime.parse(map[JFileConst.ENTDATETIMEConst])
        : null;
    Details = map[JFileConst.DetailsConst] != null
        ? (map[JFileConst.DetailsConst] as List)
            .map((e) => ItemDetails.fromMap(e))
            .toList()
        : null;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        JFileConst.JSONFILEIDConst: JSONFILEID,
        JFileConst.FILEIDConst: FILEID,
        JFileConst.FILE_NAMEConst: FILE_NAME,
        JFileConst.FiledateConst: Filedate?.toIso8601String(),
        JFileConst.CONTAINER_NOConst: CONTAINER_NO,
        JFileConst.WEIGHTConst: WEIGHT,
        JFileConst.FOLDER_PATHConst: FOLDER_PATH,
        JFileConst.ENTDATETIMEConst: ENTDATETIME?.toIso8601String(),
        JFileConst.DetailsConst: Details,
      };
}

class JFileConst {
  static const String JSONFILEIDConst = "JSONFILEID";
  static const String FILEIDConst = "FILEID";
  static const String FILE_NAMEConst = "FILE_NAME";
  static const String FiledateConst = "Filedate";
  static const String CONTAINER_NOConst = "CONTAINER_NO";
  static const String WEIGHTConst = "WEIGHT";
  static const String FOLDER_PATHConst = "FOLDER_PATH";
  static const String ENTDATETIMEConst = "ENTDATETIME";
  static const String DetailsConst = "Details";
}

class JFileUrls {
  static const String GetJsonFileMaster = "TallyFile/GetJsonFileMaster";
}

class ItemDetails {
  int ENTNO;
  String ITEM_NAME;
  String ITEM_QTY;
  String ITEM_WT;
  String ITEM_BATCH_NO;

  ItemDetails({
    this.ENTNO,
    this.ITEM_NAME,
    this.ITEM_QTY,
    this.ITEM_WT,
    this.ITEM_BATCH_NO,
  });

  ItemDetails.fromMap(Map<String, dynamic> map) {
    ENTNO = map[ItemDetailsConst.ENTNOConst];
    ITEM_NAME = map[ItemDetailsConst.ITEM_NAMEConst];
    ITEM_QTY = map[ItemDetailsConst.ITEM_QTYConst];
    ITEM_WT = map[ItemDetailsConst.ITEM_WTConst];
    ITEM_BATCH_NO = map[ItemDetailsConst.ITEM_BATCH_NOConst];
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        ItemDetailsConst.ENTNOConst: ENTNO,
        ItemDetailsConst.ITEM_NAMEConst: ITEM_NAME,
        ItemDetailsConst.ITEM_QTYConst: ITEM_QTY,
        ItemDetailsConst.ITEM_WTConst: ITEM_WT,
        ItemDetailsConst.ITEM_BATCH_NOConst: ITEM_BATCH_NO,
      };
}

class ItemDetailsConst {
  static const String ENTNOConst = "ENTNO";
  static const String ITEM_NAMEConst = "ITEM_NAME";
  static const String ITEM_QTYConst = "ITEM_QTY";
  static const String ITEM_WTConst = "ITEM_WT";
  static const String ITEM_BATCH_NOConst = "ITEM_BATCH_NO";
}
