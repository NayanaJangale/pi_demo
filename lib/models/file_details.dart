import 'package:pulse_india/handlers/string_handlers.dart';

class FileDetails {
  int FILEID;
  String FILENAME;
  String container_no;
  String weight;
  String FILETYPE;
  String FILESTATUS;
  bool ISAUDIT;
  int TOTALSTEPS;
  int PROCESSEDSTEPS;
  int PROCESSPERCENTAGE;

  FileDetails({
    this.FILEID,
    this.FILENAME,
    this.container_no,
    this.weight,
    this.FILETYPE,
    this.FILESTATUS,
    this.ISAUDIT,
    this.TOTALSTEPS,
    this.PROCESSEDSTEPS,
    this.PROCESSPERCENTAGE,
  });

  FileDetails.fromMap(Map<String, dynamic> map) {
    FILEID = map[FileDetailsConst.FILEIDConst] ?? 0;
    FILENAME =
        map[FileDetailsConst.FILENAMEConst] ?? StringHandlers.NotAvailable;
    container_no =
        map[FileDetailsConst.container_noConst] ?? StringHandlers.NotAvailable;
    weight = map[FileDetailsConst.weightConst] ?? StringHandlers.NotAvailable;
    FILETYPE =
        map[FileDetailsConst.FILETYPEConst] ?? StringHandlers.NotAvailable;
    FILESTATUS =
        map[FileDetailsConst.FILESTATUSConst] ?? StringHandlers.NotAvailable;
    ISAUDIT = map[FileDetailsConst.ISAUDITConst] ?? false;
    TOTALSTEPS = map[FileDetailsConst.TOTALSTEPSConst] ?? 0;
    PROCESSEDSTEPS = map[FileDetailsConst.PROCESSEDSTEPSConst] ?? 0;
    PROCESSPERCENTAGE = map[FileDetailsConst.PROCESSPERCENTAGEConst] ?? 0;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        FileDetailsConst.FILEIDConst: FILEID,
        FileDetailsConst.FILENAMEConst: FILENAME,
        FileDetailsConst.weightConst: weight,
        FileDetailsConst.container_noConst: container_no,
        FileDetailsConst.FILETYPEConst: FILETYPE,
        FileDetailsConst.FILESTATUSConst: FILESTATUS,
        FileDetailsConst.ISAUDITConst: ISAUDIT,
        FileDetailsConst.TOTALSTEPSConst: TOTALSTEPS,
        FileDetailsConst.PROCESSEDSTEPSConst: PROCESSEDSTEPS,
        FileDetailsConst.PROCESSPERCENTAGEConst: PROCESSPERCENTAGE,
      };
}

class FileDetailsConst {
  static const String FILEIDConst = "FILEID";
  static const String FILENAMEConst = "FILENAME";
  static const String container_noConst = "container_no";
  static const String weightConst = "weight";
  static const String FILETYPEConst = "FILETYPE";
  static const String FILESTATUSConst = "FILESTATUS";
  static const String ISAUDITConst = "ISAUDIT";
  static const String TOTALSTEPSConst = "TOTALSTEPS";
  static const String PROCESSEDSTEPSConst = "PROCESSEDSTEPS";
  static const String PROCESSPERCENTAGEConst = "PROCESSPERCENTAGE";
}
