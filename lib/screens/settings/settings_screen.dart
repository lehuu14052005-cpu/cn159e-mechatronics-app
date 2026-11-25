import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../providers/app_provider.dart';
import '../../services/backup_service.dart';
import '../practice/mistakes_review_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();

    final themeColors = <String, int>{
      'Blue': 0xFF1565C0,
      'Cyan': 0xFF00838F,
      'Indigo': 0xFF283593,
      'Teal': 0xFF00695C,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ & Cài đặt')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.error_outline_rounded),
              title: const Text('Mistakes Review'),
              subtitle: Text('${app.wrongTermIds.length} thuật ngữ cần ôn lại'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MistakesReviewScreen(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Giao diện & Hiển thị',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'system', label: Text('Hệ thống')),
                      ButtonSegment(value: 'light', label: Text('Sáng')),
                      ButtonSegment(value: 'dark', label: Text('Tối')),
                    ],
                    selected: {app.themeModeStr},
                    onSelectionChanged: (s) => app.setThemeMode(s.first),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Màu chủ đạo',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    children: themeColors.entries.map((e) {
                      final selected = app.seedColorValue == e.value;
                      return ChoiceChip(
                        label: Text(e.key),
                        selected: selected,
                        avatar: CircleAvatar(
                          backgroundColor: Color(e.value),
                          radius: 8,
                        ),
                        onSelected: (_) => app.setSeedColor(e.value),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Hiển thị phiên âm từ vựng'),
                    value: app.showPhonetic,
                    onChanged: app.setShowPhonetic,
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Âm thanh thông báo'),
                    value: app.soundEnabled,
                    onChanged: app.setSoundEnabled,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Backup & Restore
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.upload_file_rounded),
                  title: const Text('Export dữ liệu (JSON)'),
                  subtitle: const Text('Sao lưu tiến độ và lỗi sai'),
                  onTap: () async {
                    try {
                      final path =
                          await BackupService.exportBackupToFile(app.storage);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Đã xuất backup: $path')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Lỗi export: $e')),
                        );
                      }
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.download_rounded),
                  title: const Text('Import / Restore dữ liệu (JSON)'),
                  subtitle: const Text('Khôi phục dữ liệu từ file backup'),
                  onTap: () async {
                    try {
                      final ok =
                          await BackupService.importBackupFromFile(app.storage);
                      if (ok) {
                        app.reloadAfterImport();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Khôi phục dữ liệu thành công!'),
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Lỗi import: $e')),
                        );
                      }
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_forever_rounded,
                      color: Colors.red),
                  title: const Text('Reset toàn bộ dữ liệu',
                      style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Xác nhận xóa dữ liệu?'),
                        content: const Text(
                          'Toàn bộ tiến độ học tập sẽ bị xóa vĩnh viễn.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Hủy'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Xóa'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await app.resetAllData();
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Card(
            child: ListTile(
              leading: Icon(Icons.info_outline_rounded),
              title: Text(AppConstants.appName),
              subtitle: Text(
                'Phiên bản ${AppConstants.appVersion} • Offline-First\n'
                'Nguồn: CN159E Reading (Ch.4, 5.1, 5.2, 6) – ĐH Cần Thơ',
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
