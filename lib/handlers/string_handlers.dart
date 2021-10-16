import 'package:intl/intl.dart';

class StringHandlers {
  static const String NotAvailable = 'n/a';

  static String capitalizeWords(String inputString) {
    try {
      String outputString = '';
      inputString =
          inputString.toLowerCase().replaceAll(',', ', ').replaceAll('.', '. ');
      List<String> words = inputString.split(' ');

      for (String word in words) {
        if (word.trim() != '') {
          word = word.trim();
          word = '${word[0].toUpperCase()}${word.substring(1)}';

          if (outputString != '') outputString += ' ';
          outputString += word;
        }
      }

      return outputString.trim();
    } catch (ex) {
      return '';
    }
  }

  static String getFirstWord(String inputString) {
    List<String> wordList = inputString.split(" ");
    if (wordList.isNotEmpty) {
      return wordList[0];
    } else {
      return ' ';
    }
  }

  static String getApiFormattedDate(DateTime dte) {
    return DateFormat('yyyy-MM-dd').format(dte);
  }

  static String getDisplayFormattedDate(DateTime dte) {
    return DateFormat('dd/MM/yyyy').format(dte);
  }

  static String getDayMonthFormattedDate(DateTime dte) {
    return DateFormat('d/M').format(dte);
  }

  static String getDisplayFormattedTime(DateTime dte) {
    return DateFormat('hh:mm aaa').format(dte);
  }

  static String getDisplayFormattedDateTime(DateTime dte) {
    return DateFormat('dd-MM-yyyy hh:mm aaa').format(dte);
  }
}
