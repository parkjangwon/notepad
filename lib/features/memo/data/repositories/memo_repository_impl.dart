import 'package:dartz/dartz.dart';
import 'package:notepad/core/error/failures.dart';
import 'package:notepad/features/memo/data/datasources/local/memo_local_data_source.dart';
import 'package:notepad/features/memo/domain/entities/memo.dart';
import 'package:notepad/features/memo/domain/repositories/memo_repository.dart';

class MemoRepositoryImpl implements MemoRepository {
  final MemoLocalDataSource localDataSource;

  MemoRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<Memo>>> getAllMemos() async {
    try {
      final memos = await localDataSource.getAllMemos();
      List<Memo> memoList = [];
      for (final json in memos) {
        try {
          memoList.add(Memo.fromSqlite(json));
        } catch (e) {
          // row별 파싱 실패 로그
          print('Memo 파싱 실패: $json, error: $e');
        }
      }
      return Right(memoList);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Memo>> getMemoById(String id) async {
    try {
      final memo = await localDataSource.getMemoById(id);
      if (memo == null) {
        return Left(CacheFailure());
      }
      return Right(Memo.fromSqlite(memo));
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> saveMemo(Memo memo) async {
    try {
      await localDataSource.insertMemo(memo);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteMemo(String id) async {
    try {
      await localDataSource.deleteMemo(id);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure());
    }
  }
} 