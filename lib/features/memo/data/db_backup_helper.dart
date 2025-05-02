import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

class DbBackupHelper {
  static const String dbFileName = 'memo_database.db';

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
    } else if (Platform.isIOS) {
      // iOS는 memo_database.db 파일을 날짜가 포함된 이름으로 임시 복사 후 공유 시트로 내보내기
      try {
        final tempDir = await getTemporaryDirectory();
        final tempBackupPath = '${tempDir.path}/$backupFileName';
        await dbFile.copy(tempBackupPath);
        await Share.shareXFiles([XFile(tempBackupPath)]);
        debugPrint('iOS 공유 시트로 내보내기 성공');
        return File(tempBackupPath);
      } catch (e) {
        debugPrint('iOS 공유 시트 내보내기 실패: ' + e.toString());
        return null;
      }
    } else if (Platform.isMacOS) {
      String? savePath = await FilePicker.platform.saveFile(
        dialogTitle: '백업 파일 저장 위치 선택',
        fileName: backupFileName,
      );
      debugPrint('사용자가 선택한 저장 경로: ' + (savePath ?? 'null'));
      if (savePath == null) {
        debugPrint('사용자가 저장 경로를 선택하지 않았습니다.');
        return null;
      }
      try {
        final result = await dbFile.copy(savePath);
        debugPrint('백업 성공: ' + savePath);
        return result;
      } catch (e) {
        debugPrint('파일 복사 실패: ' + e.toString());
        return null;
      }
    } else {
      final appDocDir = await getApplicationDocumentsDirectory();
      final backupPath = '${appDocDir.path}/$backupFileName';
      return dbFile.copy(backupPath);
    }
  }

  /// 파일이 SQLite DB 파일인지 검증 (간단히 확장자 및 헤더 체크)
  static Future<bool> isValidSqliteFile(String filePath) async {
    if (!filePath.endsWith('.db')) return false;
    final file = File(filePath);
    if (!await file.exists()) return false;
    final header = await file.openRead(0, 16).first;
    // SQLite 파일 헤더: 'SQLite format 3\0'
    return String.fromCharCodes(header).startsWith('SQLite format 3');
  }

  /// DB 복구 (선택한 파일을 앱 DB로 덮어쓰기)
  static Future<bool> restoreDb() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result == null || result.files.isEmpty) return false;
    final filePath = result.files.single.path;
    if (filePath == null) return false;
    if (!await isValidSqliteFile(filePath)) return false;
    final dbPath = await getDbPath();
    final srcFile = File(filePath);
    final dstFile = File(dbPath);
    await srcFile.copy(dbPath);
    return true;
  }
} 