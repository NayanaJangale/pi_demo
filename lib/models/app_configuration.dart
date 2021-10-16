class AppConfiguration {
  String ConfigurationGroup;
  String ConfigurationName;
  String ConfigurationValue;
  bool Deleted;

  AppConfiguration({
    this.ConfigurationGroup,
    this.ConfigurationName,
    this.ConfigurationValue,
    this.Deleted,
  });

  AppConfiguration.fromMap(Map<String, dynamic> map) {
    ConfigurationGroup =
        map[AppConfigurationConst.ConfigurationGroupConst] ?? 'NA';
    ConfigurationName =
        map[AppConfigurationConst.ConfigurationNameConst] ?? 'NA';
    ConfigurationValue =
        map[AppConfigurationConst.ConfigurationValueConst] ?? 'NA';
    Deleted = map[AppConfigurationConst.DeletedConst] ?? false;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        AppConfigurationConst.ConfigurationGroupConst: ConfigurationGroup,
        AppConfigurationConst.ConfigurationNameConst: ConfigurationName,
        AppConfigurationConst.ConfigurationValueConst: ConfigurationValue,
        AppConfigurationConst.DeletedConst: Deleted,
      };
}

class AppConfigurationConst {
  static const String ConfigurationGroupConst = "ConfigurationGroup";
  static const String ConfigurationNameConst = "ConfigurationName";
  static const String ConfigurationValueConst = "ConfigurationValue";
  static const String DeletedConst = "Deleted";
}

class AppConfigurationUrls {
  static final String GET_LATEST_APP_VERSION =
      'Configration/GetConfigurationByGroup';
}
