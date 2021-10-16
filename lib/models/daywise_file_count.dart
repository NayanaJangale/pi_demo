import 'package:pulse_india/handlers/string_handlers.dart';

class DaywiseFIlesCount {
  DateTime PROCESSDATE;
  int USERNO;
  String USERNAME;
  int FILECOUNT;

  DaywiseFIlesCount({
    this.PROCESSDATE,
    this.USERNO,
    this.USERNAME,
    this.FILECOUNT,
  });

  DaywiseFIlesCount.fromMap(Map<String, dynamic> map) {
    PROCESSDATE = map[DaywiseFIlesCountConst.PROCESSDATEConst] != null
        ? DateTime.parse(map[DaywiseFIlesCountConst.PROCESSDATEConst])
        : null;
    USERNO = map[DaywiseFIlesCountConst.USERNOConst] ?? 0;
    USERNAME = map[DaywiseFIlesCountConst.USERNAMEConst] ??
        StringHandlers.NotAvailable;
    FILECOUNT = map[DaywiseFIlesCountConst.FILECOUNTConst] ?? 0;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        DaywiseFIlesCountConst.PROCESSDATEConst: PROCESSDATE,
        DaywiseFIlesCountConst.USERNOConst: USERNO,
        DaywiseFIlesCountConst.USERNAMEConst: USERNAME,
        DaywiseFIlesCountConst.FILECOUNTConst: FILECOUNT,
      };
}

class DaywiseFIlesCountConst {
  static const String PROCESSDATEConst = "PROCESSDATE";
  static const String USERNOConst = "USERNO";
  static const String USERNAMEConst = "USERNAME";
  static const String FILECOUNTConst = "FILECOUNT";
}

class DaywiseFIlesCountUrls {
  static const String GetDatewiseTallyFiles = "TallyFile/GetDatewiseTallyFiles";
}
