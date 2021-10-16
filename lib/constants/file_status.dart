class FileStatus {
  static const String pending = 'Pending';
  static const String in_process = 'Partial';
  static const String processed = 'Audit Ready';
  static const String audited = 'Audited';
  static const String rejected = 'Rejected';
  static const String completed = 'Completed';
}

class FStatus {
  String label, value;
  FStatus({
    this.label,
    this.value,
  });

  static List<FStatus> fileStatusList = [
    FStatus(
      label: 'All',
      value: '%',
    ),
    FStatus(
      label: 'In Process',
      value: FileStatus.in_process,
    ),
    FStatus(
      label: FileStatus.pending,
      value: FileStatus.pending,
    ),
    FStatus(
      label: 'Processed',
      value: FileStatus.processed,
    ),
    FStatus(
      label: FileStatus.audited,
      value: FileStatus.audited,
    ),
    FStatus(
      label: FileStatus.rejected,
      value: FileStatus.rejected,
    ),
    FStatus(
      label: FileStatus.completed,
      value: FileStatus.completed,
    ),
  ];
}
