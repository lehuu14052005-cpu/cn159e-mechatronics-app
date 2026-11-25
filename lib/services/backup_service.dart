import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'storage_service.dart';

class BackupService {
  BackupService._();

  static Future<String> exportBackupToFile(StorageService storage) async {
    final data = storage.exportAllData();
    final jsonString = const JsonEncoder.withIndent('  ').convert(data);
    final dir = await getApplicationDocumentsDirectory();
    final ts = DateTime.now().millisecondsSinceEpoch;
    final file = File('${dir.path}/cn159e_backup_$ts.json');
    await file.writeAsString(jsonString, encoding: utf8);
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'CN159E Mechatronics English Backup',
    );
    return file.path;
  }

  static Future<bool> importBackupFromFile(StorageService storage) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.single.path == null) {
      return false;
    }
    final file = File(result.files.single.path!);
    final raw = await file.readAsString(encoding: utf8);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    await storage.importAllData(decoded);
    return true;
  }
}
