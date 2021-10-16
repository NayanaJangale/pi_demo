import 'package:pulse_india/handlers/string_handlers.dart';
import 'package:pulse_india/models/json_file.dart';

class TallyFile {
  int FILEID;
  int SERVICEID;
  int PROCESSID;
  String FILENAME;
  String CONTAINER_NO;
  String WEIGHT;
  String FOLDER_PATH;
  String SERVICENAME;
  String FILESTATUS;
  String FILECOMMENT;
  DateTime STATUSTIME;
  String Filedate;
  bool ISAUDIT;
  int TOTALSTEPS;
  int PROCESSEDSTEPS;
  double PROCESSPERCENTAGE;
  List<ItemDetails> Details;

  TallyFile({
    this.FILEID,
    this.SERVICEID,
    this.PROCESSID,
    this.FILENAME,
    this.CONTAINER_NO,
    this.WEIGHT,
    this.FOLDER_PATH,
    this.SERVICENAME,
    this.FILESTATUS,
    this.FILECOMMENT,
    this.Filedate,
    this.STATUSTIME,
    this.ISAUDIT,
    this.TOTALSTEPS,
    this.PROCESSEDSTEPS,
    this.PROCESSPERCENTAGE,
    this.Details,
  });

  TallyFile.fromMap(Map<String, dynamic> map) {
    FILEID = map[TallyFileConst.FILEIDConst] ?? 0;
    SERVICEID = map[TallyFileConst.SERVICEIDConst] ?? 0;
    PROCESSID = map[TallyFileConst.PROCESSIDConst] ?? 0;
    FILENAME = map[TallyFileConst.FILENAMEConst] ?? StringHandlers.NotAvailable;
    CONTAINER_NO =
        map[TallyFileConst.CONTAINER_NOConst] ?? StringHandlers.NotAvailable;
    WEIGHT = map[TallyFileConst.WEIGHTConst] ?? StringHandlers.NotAvailable;
    FOLDER_PATH =
        map[TallyFileConst.FOLDER_PATHConst] ?? StringHandlers.NotAvailable;
    SERVICENAME =
        map[TallyFileConst.SERVICENAMEConst] ?? StringHandlers.NotAvailable;
    FILESTATUS =
        map[TallyFileConst.FILESTATUSConst] ?? StringHandlers.NotAvailable;
    FILECOMMENT =
        map[TallyFileConst.FILECOMMENTConst] ?? StringHandlers.NotAvailable;
    STATUSTIME = map[TallyFileConst.STATUSTIMEConst] != null
        ? DateTime.parse(map[TallyFileConst.STATUSTIMEConst])
        : null;
    Filedate = map[TallyFileConst.FiledateConst] ?? StringHandlers.NotAvailable;
    ISAUDIT = map[TallyFileConst.ISAUDITConst] ?? false;
    TOTALSTEPS = map[TallyFileConst.TOTALSTEPSConst] ?? 0;
    PROCESSEDSTEPS = map[TallyFileConst.PROCESSEDSTEPSConst] ?? 0;
    PROCESSPERCENTAGE = map[TallyFileConst.PROCESSPERCENTAGEConst] ?? 0;
    Details = map[TallyFileConst.DetailsConst] != null
        ? (map[TallyFileConst.DetailsConst] as List)
            .map((e) => ItemDetails.fromMap(e))
            .toList()
        : null;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        TallyFileConst.FILEIDConst: FILEID,
        TallyFileConst.SERVICEIDConst: SERVICEID,
        TallyFileConst.PROCESSIDConst: PROCESSID,
        TallyFileConst.FILENAMEConst: FILENAME,
        TallyFileConst.CONTAINER_NOConst: CONTAINER_NO,
        TallyFileConst.WEIGHTConst: WEIGHT,
        TallyFileConst.FOLDER_PATHConst: FOLDER_PATH,
        TallyFileConst.SERVICENAMEConst: SERVICENAME,
        TallyFileConst.FILESTATUSConst: FILESTATUS,
        TallyFileConst.FILECOMMENTConst: FILECOMMENT,
        TallyFileConst.STATUSTIMEConst: STATUSTIME.toIso8601String(),
        TallyFileConst.FiledateConst: Filedate,
        TallyFileConst.ISAUDITConst: ISAUDIT,
        TallyFileConst.TOTALSTEPSConst: TOTALSTEPS,
        TallyFileConst.PROCESSEDSTEPSConst: PROCESSEDSTEPS,
        TallyFileConst.PROCESSPERCENTAGEConst: PROCESSPERCENTAGE,
      };
}

class TallyFileConst {
  static const String FILEIDConst = "FILEID";
  static const String SERVICEIDConst = "SERVICEID";
  static const String PROCESSIDConst = "PROCESSID";
  static const String FILENAMEConst = "FILE_NAME";
  static const String CONTAINER_NOConst = "CONTAINER_NO";
  static const String WEIGHTConst = "WEIGHT";
  static const String FOLDER_PATHConst = "FOLDER_PATH";
  static const String SERVICENAMEConst = "SERVICENAME";
  static const String FILESTATUSConst = "FILESTATUS";
  static const String FILECOMMENTConst = "FILECOMMENT";
  static const String FiledateConst = "Filedate";
  static const String STATUSTIMEConst = "STATUSTIME";
  static const String ISAUDITConst = "ISAUDIT";
  static const String TOTALSTEPSConst = "TOTALSTEPS";
  static const String PROCESSEDSTEPSConst = "PROCESSEDSTEPS";
  static const String PROCESSPERCENTAGEConst = "PROCESSPERCENTAGE";
  static const String DetailsConst = "Details";
}

class TallyFileUrls {
  static const String DownloadTallyFile = "TallyFile/DownloadTallyFile/";
  static const String GetTallyFiles = "TallyFile/GetTallyFiles";
  static const String GETSTEPCOMPLETEFILE_WITHPARTIALSTATUS =
      "TallyFile/GETSTEPCOMPLETEFILE_WITHPARTIALSTATUS";
}
