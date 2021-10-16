import '../handlers/string_handlers.dart';

class Service {
  int ServiceId;
  String ServiceEName;
  String ServiceAEName;
  String ServiceType;

  Service({
    this.ServiceId,
    this.ServiceEName,
    this.ServiceAEName,
    this.ServiceType,
  });

  Service.fromMap(Map<String, dynamic> map) {
    ServiceId = map[ServiceConst.ServiceIdConst] ?? 0;
    ServiceEName =
        map[ServiceConst.ServiceENameConst] ?? StringHandlers.NotAvailable;
    ServiceAEName =
        map[ServiceConst.ServiceAENameConst] ?? StringHandlers.NotAvailable;
    ServiceType =
        map[ServiceConst.ServiceTypeConst] ?? StringHandlers.NotAvailable;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        ServiceConst.ServiceIdConst: ServiceId,
        ServiceConst.ServiceENameConst: ServiceEName,
        ServiceConst.ServiceAENameConst: ServiceAEName,
        ServiceConst.ServiceTypeConst: ServiceType,
      };
}

class ServiceConst {
  static const String ServiceIdConst = "ServiceId";
  static const String ServiceENameConst = "ServiceEName";
  static const String ServiceAENameConst = "ServiceAEName";
  static const String ServiceTypeConst = "ServiceType";
}

class ServiceUrls {
  static const String GetServices = "ServiceStep/GetServices";
}
