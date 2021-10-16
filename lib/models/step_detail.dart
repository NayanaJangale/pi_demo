import 'dart:io';

import 'package:pulse_india/handlers/string_handlers.dart';

class StepDetail {
  int ServiceStepId;
  int SSDetailId;
  int ProductNo;
  String StepSubEName;
  String StepSubAEName;
  String FileType;
  String ITEM_NAME;
  String ProductId;
  bool IsCompulsory;
  bool IsProductStep;
  File file;

  StepDetail({
    this.ServiceStepId,
    this.SSDetailId,
    this.ProductNo,
    this.StepSubEName,
    this.StepSubAEName,
    this.FileType,
    this.ITEM_NAME,
    this.ProductId,
    this.IsCompulsory,
    this.IsProductStep,
    this.file,
  });

  StepDetail.fromMap(Map<String, dynamic> map) {
    ServiceStepId = map[StepDetailConst.ServiceStepIdConst] ?? 0;
    SSDetailId = map[StepDetailConst.SSDetailIdConst] ?? 0;
    ProductNo = map[StepDetailConst.ProductNoConst] ?? 0;
    StepSubEName =
        map[StepDetailConst.StepSubENameConst] ?? StringHandlers.NotAvailable;
    StepSubAEName =
        map[StepDetailConst.StepSubAENameConst] ?? StringHandlers.NotAvailable;
    FileType =
        map[StepDetailConst.FileTypeConst] ?? StringHandlers.NotAvailable;
    ITEM_NAME =
        map[StepDetailConst.ITEM_NAMEConst] ?? StringHandlers.NotAvailable;
    ProductId =
        map[StepDetailConst.ProductIdConst] ?? StringHandlers.NotAvailable;
    IsCompulsory = map[StepDetailConst.IsCompulsoryConst] ?? false;
    IsProductStep = map[StepDetailConst.IsProductStepConst] ?? false;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        StepDetailConst.ServiceStepIdConst: ServiceStepId,
        StepDetailConst.SSDetailIdConst: SSDetailId,
        StepDetailConst.ProductNoConst: ProductNo,
        StepDetailConst.StepSubENameConst: StepSubEName,
        StepDetailConst.StepSubAENameConst: StepSubAEName,
        StepDetailConst.FileTypeConst: FileType,
        StepDetailConst.ITEM_NAMEConst: ITEM_NAME,
        StepDetailConst.ProductIdConst: ProductId,
        StepDetailConst.IsCompulsoryConst: IsCompulsory,
        StepDetailConst.IsProductStepConst: IsProductStep,
      };
}

class StepDetailConst {
  static const String ServiceStepIdConst = "ServiceStepId";
  static const String SSDetailIdConst = "SSDetailId";
  static const String StepSubENameConst = "StepSubEName";
  static const String StepSubAENameConst = "StepSubAEName";
  static const String FileTypeConst = "FileType";
  static const String IsCompulsoryConst = "IsCompulsory";
  static const String IsProductStepConst = "IsProductStep";
  static const String ProductNoConst = "ENTNO";
  static const String ITEM_NAMEConst = "ITEM_NAME";
  static const String ProductIdConst = "ProductId";
}

class StepDetailUrls {
  static const String GetServiceStepDetailByServiceId =
      "ServiceStep/GetServiceStepDetailByServiceId";
}
