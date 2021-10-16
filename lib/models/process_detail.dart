class ProcessLog {
  int ProcessId;
  int SSDetailId;
  int EntryNo;
  int ProcessLogId;
  String ProductId;
  String ProcessDescription;
  String UploadStatus;

  ProcessLog({
    this.ProcessId,
    this.SSDetailId,
    this.EntryNo,
    this.ProcessLogId,
    this.ProductId,
    this.ProcessDescription,
    this.UploadStatus,
  });

  ProcessLog.fromMap(Map<String, dynamic> map) {
    ProcessId = map[ProcessLogConst.ProcessIdConst];
    SSDetailId = map[ProcessLogConst.SSDetailIdConst];
    EntryNo = map[ProcessLogConst.EntryNoConst];
    ProcessLogId = map[ProcessLogConst.ProcessLogIdConst];
    ProductId = map[ProcessLogConst.ProductIdConst];
    ProcessDescription = map[ProcessLogConst.ProcessDescriptionConst];
    UploadStatus = map[ProcessLogConst.UploadStatusConst];
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        ProcessLogConst.ProcessIdConst: ProcessId,
        ProcessLogConst.SSDetailIdConst: SSDetailId,
        ProcessLogConst.EntryNoConst: EntryNo,
        ProcessLogConst.ProcessLogIdConst: ProcessLogId,
        ProcessLogConst.ProductIdConst: ProductId,
        ProcessLogConst.ProcessDescriptionConst: ProcessDescription,
        ProcessLogConst.UploadStatusConst: UploadStatus,
      };
}

class ProcessLogConst {
  static const String ProcessIdConst = "ProcessId";
  static const String SSDetailIdConst = "SSDetailId";
  static const String EntryNoConst = "EntryNo";
  static const String ProcessLogIdConst = "ProcessLogId";
  static const String ProductIdConst = "ProductId";
  static const String ProcessDescriptionConst = "ProcessDescription";
  static const String UploadStatusConst = "UploadStatus";
}

class ProcessLogUrls {
  static const String PostProcessLogMaster = "Process/PostProcessLogMaster";
  static const String PostProcessLogImage = "Process/PostProcessLogImage";
  static const String GetProcessLogImage = "Process/GetProcessLogImage";
}
