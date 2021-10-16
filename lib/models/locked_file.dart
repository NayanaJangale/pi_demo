import '../handlers/string_handlers.dart';

class LockedFile {
  int PROCESSID;
  int SERVICEID;
  String SERVICEENAME;
  int FILEID;
  String FILE_NAME;
  String CONTAINER_NO;
  bool SIGNSUBMIT;
  String PROCESSFLAG;
  DateTime PROCESSSTART;
  DateTime PROCESSEND;

  LockedFile({
    this.PROCESSID,
    this.SERVICEID,
    this.SERVICEENAME,
    this.FILEID,
    this.FILE_NAME,
    this.CONTAINER_NO,
    this.SIGNSUBMIT,
    this.PROCESSFLAG,
    this.PROCESSSTART,
    this.PROCESSEND,
  });

  LockedFile.fromMap(Map<String, dynamic> map) {
    PROCESSID = map[LockedFileConst.PROCESSIDConst] ?? 0;
    SERVICEID = map[LockedFileConst.SERVICEIDConst] ?? 0;
    SERVICEENAME =
        map[LockedFileConst.SERVICEENAMEConst] ?? StringHandlers.NotAvailable;
    FILEID = map[LockedFileConst.FILEIDConst] ?? 0;
    FILE_NAME =
        map[LockedFileConst.FILE_NAMEConst] ?? StringHandlers.NotAvailable;
    CONTAINER_NO =
        map[LockedFileConst.CONTAINER_NOConst] ?? StringHandlers.NotAvailable;
    SIGNSUBMIT = map[LockedFileConst.SIGNSUBMITConst] ?? false;
    PROCESSFLAG =
        map[LockedFileConst.PROCESSFLAGConst] ?? StringHandlers.NotAvailable;
    PROCESSSTART = map[LockedFileConst.PROCESSSTARTConst] != null
        ? DateTime.parse(map[LockedFileConst.PROCESSSTARTConst])
        : null;
    PROCESSEND = map[LockedFileConst.PROCESSENDConst] != null
        ? DateTime.parse(map[LockedFileConst.PROCESSENDConst])
        : null;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        LockedFileConst.PROCESSIDConst: PROCESSID,
        LockedFileConst.SERVICEIDConst: SERVICEID,
        LockedFileConst.SERVICEENAMEConst: SERVICEENAME,
        LockedFileConst.FILEIDConst: FILEID,
        LockedFileConst.FILE_NAMEConst: FILE_NAME,
        LockedFileConst.CONTAINER_NOConst: CONTAINER_NO,
        LockedFileConst.SIGNSUBMITConst: SIGNSUBMIT,
        LockedFileConst.PROCESSFLAGConst: PROCESSFLAG,
        LockedFileConst.PROCESSSTARTConst: PROCESSSTART?.toIso8601String(),
        LockedFileConst.PROCESSENDConst: PROCESSEND?.toIso8601String(),
      };
}

class LockedFileConst {
  static const String PROCESSIDConst = "PROCESSID";
  static const String SERVICEIDConst = "SERVICEID";
  static const String SERVICEENAMEConst = "SERVICEENAME";
  static const String FILEIDConst = "FILEID";
  static const String FILE_NAMEConst = "FILE_NAME";
  static const String CONTAINER_NOConst = "CONTAINER_NO";
  static const String SIGNSUBMITConst = "SIGNSUBMIT";
  static const String PROCESSFLAGConst = "PROCESSFLAG";
  static const String PROCESSSTARTConst = "PROCESSSTART";
  static const String PROCESSENDConst = "PROCESSEND";
}

class LockedFileUrls {
  static const String GETPROCESSBYSTATUS = "Process/GETPROCESSBYSTATUS";
}
