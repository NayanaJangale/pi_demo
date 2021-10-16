import 'package:pulse_india/handlers/string_handlers.dart';

class UploadedProcess {
  int PROCESSID;
  int PROCESSLOGID;
  String PROCESSDESCRIPTION;
  String UPLOADSTATUS;
  String STEPSUBENAME;
  String STEPSUBAENAME;
  String PRODUCTENAME;
  String FILETYPE;

  UploadedProcess({
    this.PROCESSID,
    this.PROCESSLOGID,
    this.PROCESSDESCRIPTION,
    this.UPLOADSTATUS,
    this.STEPSUBENAME,
    this.STEPSUBAENAME,
    this.PRODUCTENAME,
    this.FILETYPE,
  });

  UploadedProcess.fromMap(Map<String, dynamic> map) {
    PROCESSID = map[UploadedProcessConst.PROCESSIDConst] ?? 0;
    PROCESSLOGID = map[UploadedProcessConst.PROCESSLOGIDConst] ?? 0;
    PROCESSDESCRIPTION = map[UploadedProcessConst.PROCESSDESCRIPTIONConst] ??
        StringHandlers.NotAvailable;
    UPLOADSTATUS = map[UploadedProcessConst.UPLOADSTATUSConst] ??
        StringHandlers.NotAvailable;
    STEPSUBENAME = map[UploadedProcessConst.STEPSUBENAMEConst] ??
        StringHandlers.NotAvailable;
    STEPSUBAENAME = map[UploadedProcessConst.STEPSUBAENAMEConst] ??
        StringHandlers.NotAvailable;
    PRODUCTENAME = map[UploadedProcessConst.PRODUCTENAMEConst] ??
        StringHandlers.NotAvailable;
    FILETYPE =
        map[UploadedProcessConst.FILETYPEConst] ?? StringHandlers.NotAvailable;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        UploadedProcessConst.PROCESSIDConst: PROCESSID,
        UploadedProcessConst.PROCESSLOGIDConst: PROCESSLOGID,
        UploadedProcessConst.PROCESSDESCRIPTIONConst: PROCESSDESCRIPTION,
        UploadedProcessConst.UPLOADSTATUSConst: UPLOADSTATUS,
        UploadedProcessConst.STEPSUBENAMEConst: STEPSUBENAME,
        UploadedProcessConst.STEPSUBAENAMEConst: STEPSUBAENAME,
        UploadedProcessConst.PRODUCTENAMEConst: PRODUCTENAME,
        UploadedProcessConst.FILETYPEConst: FILETYPE,
      };
}

class UploadedProcessConst {
  static const String PROCESSIDConst = "PROCESSID";
  static const String PROCESSLOGIDConst = "PROCESSLOGID";
  static const String PROCESSDESCRIPTIONConst = "PROCESSDESCRIPTION";
  static const String UPLOADSTATUSConst = "UPLOADSTATUS";
  static const String STEPSUBENAMEConst = "STEPSUBENAME";
  static const String STEPSUBAENAMEConst = "STEPSUBAENAME";
  static const String PRODUCTENAMEConst = "PRODUCTENAME";
  static const String FILETYPEConst = "FILETYPE";
}

class UploadedProcessUrls {
  static const String GetprocessDetails = "Process/GetprocessDetails";
}
