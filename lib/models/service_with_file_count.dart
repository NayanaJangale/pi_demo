import 'package:pulse_india/handlers/string_handlers.dart';

class ServiceWithFileCount {
  int FILECOUNT;
  int SERVICEID;
  String SERVICEENAME;
  String SERVICEAENAME;
  String SERVICETYPE;
  String FILESTATUS;

  ServiceWithFileCount({
    this.FILECOUNT,
    this.SERVICEID,
    this.SERVICEENAME,
    this.SERVICEAENAME,
    this.SERVICETYPE,
    this.FILESTATUS,
  });

  ServiceWithFileCount.fromMap(Map<String, dynamic> map) {
    FILECOUNT = map[ServiceWithFileCountConst.FILECOUNTConst] ?? 0;
    SERVICEID = map[ServiceWithFileCountConst.SERVICEIDConst] ?? 0;
    SERVICEENAME = map[ServiceWithFileCountConst.SERVICEENAMEConst] ??
        StringHandlers.NotAvailable;
    SERVICEAENAME = map[ServiceWithFileCountConst.SERVICEAENAMEConst] ??
        StringHandlers.NotAvailable;
    SERVICETYPE = map[ServiceWithFileCountConst.SERVICETYPEConst] ??
        StringHandlers.NotAvailable;
    FILESTATUS = map[ServiceWithFileCountConst.FILESTATUSConst] ??
        StringHandlers.NotAvailable;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        ServiceWithFileCountConst.FILECOUNTConst: FILECOUNT,
        ServiceWithFileCountConst.SERVICEIDConst: SERVICEID,
        ServiceWithFileCountConst.SERVICEENAMEConst: SERVICEENAME,
        ServiceWithFileCountConst.SERVICEAENAMEConst: SERVICEAENAME,
        ServiceWithFileCountConst.SERVICETYPEConst: SERVICETYPE,
        ServiceWithFileCountConst.FILESTATUSConst: FILESTATUS,
      };
}

class ServiceWithFileCountConst {
  static const String FILECOUNTConst = "FILECOUNT";
  static const String SERVICEIDConst = "SERVICEID";
  static const String SERVICEENAMEConst = "SERVICEENAME";
  static const String SERVICEAENAMEConst = "SERVICEAENAME";
  static const String SERVICETYPEConst = "SERVICETYPE";
  static const String FILESTATUSConst = "FILESTATUS";
}

class ServiceWithFileCountUrls {
  static const String GETSERVICEWISEALLYFILES =
      "TallyFile/GETSERVICEWISETALLYFILES";
}
