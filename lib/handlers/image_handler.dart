import 'package:pulse_india/constants/project_settings.dart';
import 'package:pulse_india/handlers/network_handler.dart';
import 'package:pulse_india/models/file.dart';
import 'package:pulse_india/models/process_detail.dart';

class ImageHandler {
  static Future<String> getProcessLogImageUrl(String processLogId) =>
      NetworkHandler.getServerWorkingUrl().then((connectionServerMsg) {
        if (connectionServerMsg != "key_check_internet" &&
            connectionServerMsg != "key_no_internet") {
          String url = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                ProcessLogUrls.GetProcessLogImage,
            {
              "ProcessLogId": processLogId,
            },
          ).toString();
          Uri u = Uri.parse(url);
          print(url);
          return url;
        } else {
          return '';
        }
      });
  static Future<String> getVoucherImageUrl(String fileId) =>
      NetworkHandler.getServerWorkingUrl().then((connectionServerMsg) {
        if (connectionServerMsg != "key_check_internet" &&
            connectionServerMsg != "key_no_internet") {
          String url = Uri.parse(connectionServerMsg +
                  ProjectSettings.rootUrl +
                  TallyFileUrls.DownloadTallyFile +
                  fileId)
              .toString();
          Uri u = Uri.parse(url);
          print(url);
          return url;
        } else {
          return '';
        }
      });
}
