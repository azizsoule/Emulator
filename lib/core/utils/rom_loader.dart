import 'package:file_picker/file_picker.dart';

class RomLoader {
  static Future<List<int>?> loadROM() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      return result.files.first.bytes;
    }

    return null;
  }
}
