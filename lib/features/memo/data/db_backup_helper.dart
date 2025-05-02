import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:get_it/get_it.dart';
import 'package:notepad/features/memo/data/datasources/local/memo_local_data_source.dart';

class DbBackupHelper {
  static const String dbFileName = 'memo_database.db';
  static const String legacyTableName = 'memos';
  static const String currentTableName = 'memos';

  /// 현재 DB 파일 경로 반환
  static Future<String> getDbPath() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    return '${appDocDir.path}/$dbFileName';
  }

  /// 백업 파일명 생성 (memos_dump_yyyymmdd.db)
  static String generateBackupFileName() {
    final now = DateTime.now();
    final dateStr = DateFormat('yyyyMMdd').format(now);
    return 'memos_dump_$dateStr.db';
  }

  /// DB 파일을 백업(내보내기)
  static Future<File?> backupDb() async {
    final dbPath = await getDbPath();
    final backupFileName = generateBackupFileName();
    final dbFile = File(dbPath);
    debugPrint('DB 파일 경로: ' + dbPath);
    debugPrint('DB 파일 존재 여부: ' + (await dbFile.exists()).toString());
    if (!await dbFile.exists()) {
      debugPrint('DB 파일이 존재하지 않습니다.');
      return null;
    }

    if (Platform.isAndroid) {
      final outputDir = await getExternalStorageDirectory();
      if (outputDir == null) {
        debugPrint('외부 저장소 경로를 찾을 수 없습니다.');
        return null;
      }
      final backupPath = '${outputDir.path}/$backupFileName';
      return dbFile.copy(backupPath);
    } else if (Platform.isMacOS) {
      try {
        String? savePath = await FilePicker.platform.saveFile(
          dialogTitle: '백업 파일 저장 위치 선택',
          fileName: backupFileName,
        );
        debugPrint('사용자가 선택한 저장 경로: ' + (savePath ?? 'null'));
        if (savePath == null) {
          debugPrint('사용자가 저장 경로를 선택하지 않았습니다.');
          return null;
        }
        final result = await dbFile.copy(savePath);
        debugPrint('백업 성공: ' + savePath);
        return result;
      } catch (e) {
        debugPrint('파일 복사 실패: ' + e.toString());
        return null;
      }
    } else {
      final outputDir = await getApplicationDocumentsDirectory();
      final backupPath = '${outputDir.path}/$backupFileName';
      return dbFile.copy(backupPath);
    }
  }

  /// DB 파일을 복구(가져오기)
  static Future<bool> restoreDb() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['db'],
        dialogTitle: '복구할 DB 파일 선택',
      );

      if (result == null || result.files.isEmpty) {
        debugPrint('파일이 선택되지 않았습니다.');
        return false;
      }

      final file = File(result.files.first.path!);
      if (!await file.exists()) {
        debugPrint('선택된 파일이 존재하지 않습니다.');
        return false;
      }

      final dbPath = await getDbPath();
      final dbFile = File(dbPath);
      
      // 기존 DB 파일이 있다면 백업
      if (await dbFile.exists()) {
        final backupPath = '${dbPath}.backup';
        await dbFile.copy(backupPath);
        debugPrint('기존 DB 파일 백업 완료: $backupPath');
      }

      // 선택된 파일을 현재 DB 파일로 복사
      await file.copy(dbPath);
      debugPrint('DB 파일 복사 완료: $dbPath');

      // DB 스키마 확인 및 마이그레이션
      final db = await openDatabase(dbPath);
      final tables = await db.query('sqlite_master', where: 'type = ?', whereArgs: ['table']);
      
      for (var table in tables) {
        if (table['name'] == legacyTableName) {
          // 테이블 구조 확인
          final columns = await db.rawQuery('PRAGMA table_info($legacyTableName)');
          final columnNames = columns.map((c) => c['name'] as String).toList();

          final isLegacy = columnNames.contains('text') && columnNames.contains('createdTime') && columnNames.contains('editedTime');
          final isNew = columnNames.contains('content') && columnNames.contains('created_at') && columnNames.contains('updated_at');

          if (isLegacy) {
            // 레거시 스키마 발견, 마이그레이션 시작
            debugPrint('레거시 스키마 발견, 마이그레이션 시작');
            // 기존 데이터 백업
            final legacyData = await db.query(legacyTableName);
            debugPrint('레거시 데이터 개수: ${legacyData.length}');
            // 새로운 테이블 생성
            await db.execute('''
              CREATE TABLE ${currentTableName}_new(
                id TEXT PRIMARY KEY,
                title TEXT,
                content TEXT,
                rich_content TEXT,
                created_at TEXT,
                updated_at TEXT,
                is_encrypted INTEGER
              )
            ''');
            // 데이터 마이그레이션
            for (var row in legacyData) {
              try {
                final rawId = row['id']?.toString() ?? '';
                final id = const Uuid().v4();
                final title = row['title']?.toString() ?? '';
                final text = row['text']?.toString() ?? '';
                final safeText = text.replaceAll('\n', '\\n');
                final createdTimeRaw = row['createdTime']?.toString() ?? DateTime.now().toIso8601String();
                final editedTimeRaw = row['editedTime']?.toString() ?? createdTimeRaw;
                final createdTime = toIso8601(createdTimeRaw);
                final editedTime = toIso8601(editedTimeRaw);
                final richContent = '[{"insert":"$safeText\\n"}]';
                await db.insert('${currentTableName}_new', {
                  'id': id,
                  'title': title,
                  'content': text,
                  'rich_content': richContent,
                  'created_at': createdTime,
                  'updated_at': editedTime,
                  'is_encrypted': 0,
                });
                debugPrint('데이터 마이그레이션 성공: $id');
              } catch (e) {
                debugPrint('마이그레이션 실패 row: $row, error: $e');
                continue;
              }
            }
            // 기존 테이블 삭제 및 새 테이블로 교체
            await db.execute('DROP TABLE $legacyTableName');
            await db.execute('ALTER TABLE ${currentTableName}_new RENAME TO $currentTableName');
            debugPrint('마이그레이션 완료');
          } else if (isNew) {
            debugPrint('신규 스키마이므로 마이그레이션 없이 복구합니다.');
            // 아무 작업도 하지 않음
          } else {
            debugPrint('알 수 없는 스키마입니다. 복구를 중단합니다.');
            await db.close();
            return false;
          }
        }
      }

      await db.close();
      await GetIt.I<MemoLocalDataSource>().reopenDatabase();
      return true;
    } catch (e, stack) {
      debugPrint('복구 중 오류 발생: $e');
      debugPrint('스택 트레이스: $stack');
      return false;
    }
  }

  // 날짜 포맷 변환 함수
  static String toIso8601(String value) {
    if (value.contains('T')) return value;
    return value.trim().replaceFirst(' ', 'T');
  }
} 