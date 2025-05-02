import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:notepad/features/memo/data/datasources/local/memo_local_data_source.dart';
import 'package:notepad/features/memo/data/repositories/memo_repository_impl.dart';
import 'package:notepad/features/memo/domain/repositories/memo_repository.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  getIt.registerSingleton<MemoLocalDataSource>(MemoLocalDataSource());
  getIt.registerSingleton<MemoRepository>(
    MemoRepositoryImpl(getIt<MemoLocalDataSource>()),
  );
} 