import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/repositories/content_repository.dart';
import 'providers/app_provider.dart';
import 'services/storage_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = StorageService();
  final repository = ContentRepository();
  final appProvider = AppProvider(repository: repository, storage: storage);

  runApp(
    ChangeNotifierProvider.value(
      value: appProvider,
      child: const Cn159eApp(),
    ),
  );
}
