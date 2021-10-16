import 'package:pulse_india/handlers/string_handlers.dart';
import 'package:pulse_india/models/file_details.dart';

class FileDetailsReport {
  int FILECOUNT;
  DateTime ENTDATETIME;
  int USERNO;
  String USERNAME;
  String SERVICENAME;
  int SERVICEID;
  List<FileDetails> Details;

  FileDetailsReport({
    this.FILECOUNT,
    this.ENTDATETIME,
    this.USERNO,
    this.USERNAME,
    this.SERVICENAME,
    this.SERVICEID,
    this.Details,
  });

  FileDetailsReport.fromMap(Map<String, dynamic> map) {
    FILECOUNT = map[FileDetailsReportConst.FILECOUNTConst] ?? 0;
    ENTDATETIME = map[FileDetailsReportConst.ENTDATETIMEConst] != null
        ? DateTime.parse(map[FileDetailsReportConst.ENTDATETIMEConst])
        : null;
    USERNO = map[FileDetailsReportConst.USERNOConst] ?? 0;
    USERNAME = map[FileDetailsReportConst.USERNAMEConst] ??
        StringHandlers.NotAvailable;
    SERVICENAME = map[FileDetailsReportConst.SERVICENAMEConst] ??
        StringHandlers.NotAvailable;
    SERVICEID = map[FileDetailsReportConst.SERVICEIDConst] ?? 0;
    Details = map[FileDetailsReportConst.DetailsConst] != null
        ? (map[FileDetailsReportConst.DetailsConst] as List)
            .map((e) => FileDetails.fromMap(e))
            .toList()
        : null;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        FileDetailsReportConst.FILECOUNTConst: FILECOUNT,
        FileDetailsReportConst.ENTDATETIMEConst: ENTDATETIME,
        FileDetailsReportConst.USERNOConst: USERNO,
        FileDetailsReportConst.USERNAMEConst: USERNAME,
        FileDetailsReportConst.SERVICENAMEConst: SERVICENAME,
        FileDetailsReportConst.SERVICEIDConst: SERVICEID,
        FileDetailsReportConst.DetailsConst: Details,
      };
}

class FileDetailsReportConst {
  static const String FILECOUNTConst = "FILECOUNT";
  static const String ENTDATETIMEConst = "ENTDATETIME";
  static const String USERNOConst = "USERNO";
  static const String USERNAMEConst = "USERNAME";
  static const String SERVICENAMEConst = "SERVICENAME";
  static const String SERVICEIDConst = "SERVICEID";
  static const String DetailsConst = "Details";
}

class FileDetailsReportUrls {
  static const String GetDatewiseProceedTallyFiles =
      "TallyFile/GetDatewiseProceedTallyFiles";
}
