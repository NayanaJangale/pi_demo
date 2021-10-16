class Process {
  int ProcessId;
  int UserNo;
  int ServiceId;
  int FileId;
  bool SignSubmit;
  DateTime ProcessStart;
  DateTime ProcessEnd;

  Process({
    this.ProcessId,
    this.UserNo,
    this.ServiceId,
    this.FileId,
    this.SignSubmit,
    this.ProcessStart,
    this.ProcessEnd,
  });

  Process.fromMap(Map<String, dynamic> map) {
    ProcessId = map[ProcessConst.ProcessIdConst] ?? 0;
    UserNo = map[ProcessConst.UserNoConst] ?? 0;
    ServiceId = map[ProcessConst.ServiceIdConst] ?? 0;
    FileId = map[ProcessConst.FileIdConst] ?? 0;
    SignSubmit = map[ProcessConst.SignSubmitConst] ?? false;
    ProcessStart = map[ProcessConst.ProcessStartConst] != null
        ? DateTime.parse(map[ProcessConst.ProcessStartConst])
        : null;
    ProcessEnd = map[ProcessConst.ProcessEndConst] != null
        ? DateTime.parse(map[ProcessConst.ProcessEndConst])
        : null;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        ProcessConst.ProcessIdConst: ProcessId,
        ProcessConst.UserNoConst: UserNo,
        ProcessConst.ServiceIdConst: ServiceId,
        ProcessConst.FileIdConst: FileId,
        ProcessConst.SignSubmitConst: SignSubmit,
        ProcessConst.ProcessStartConst: ProcessStart?.toIso8601String(),
        ProcessConst.ProcessEndConst: ProcessEnd?.toIso8601String(),
      };
}

class ProcessConst {
  static const String ProcessIdConst = "ProcessId";
  static const String UserNoConst = "UserNo";
  static const String ServiceIdConst = "ServiceId";
  static const String FileIdConst = "FileId";
  static const String SignSubmitConst = "SignSubmit";
  static const String ProcessStartConst = "ProcessStart";
  static const String ProcessEndConst = "ProcessEnd";
}

class ProcessUrls {
  static const String PostProcessMaster = "Process/PostProcessMaster";
  static const String PostProcessMasterImage = "Process/PostProcessMasterImage";
  static const String PutProcessMaster = "Process/PutProcessMaster";
}
