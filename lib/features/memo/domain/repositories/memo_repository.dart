import 'package:dartz/dartz.dart';
import 'package:notepad/core/error/failures.dart';
import 'package:notepad/features/memo/domain/entities/memo.dart';

abstract class MemoRepository {
  Future<Either<Failure, List<Memo>>> getAllMemos();
  Future<Either<Failure, Memo>> getMemoById(String id);
  Future<Either<Failure, Unit>> saveMemo(Memo memo);
  Future<Either<Failure, Unit>> deleteMemo(String id);
} 