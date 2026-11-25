import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'storage_service.dart';

class BackupService {
  BackupService._();

  static Future<String> exportBackupToFile(StorageService storage) async {
    final data = storage.exportAllData();
    final jsonString = const JsonEncoder.withIndent('  ').convert(data);

    if (kIsWeb) {
      await Share.share(
        jsonString,
        subject: 'CN159E Mechatronics English Backup',
      );
      return 'Đã chia sẻ dữ liệu JSON';
    }

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
      withData: kIsWeb,
    );
    if (result == null) return false;

    String? raw;
    final picked = result.files.single;
    if (kIsWeb && picked.bytes != null) {
      raw = utf8.decode(picked.bytes!);
    } else if (picked.path != null) {
      raw = await File(picked.path!).readAsString(encoding: utf8);
    }

    if (raw == null) return false;
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    await storage.importAllData(decoded);
    return true;
  }
}
