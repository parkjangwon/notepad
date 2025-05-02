import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:notepad/features/memo/domain/entities/memo.dart';

class MemoLocalDataSource {
  static Database? _database;
  static const String tableName = 'memos';
  static const String backupTableName = 'memos_backup';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path;
    if (Platform.isMacOS) {
      final appDir = await getApplicationDocumentsDirectory();
      path = join(appDir.path, 'memo_database.db');
    } else {
      path = join(await getDatabasesPath(), 'memo_database.db');
    }
    
    return await openDatabase(
      path,
      version: 2,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE $tableName(
            id TEXT PRIMARY KEY,
            title TEXT,
            content TEXT,
            rich_content TEXT,
            created_at TEXT,
            updated_at TEXT,
            is_encrypted INTEGER
          )
        ''');
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        if (oldVersion < 2) {
          // 기존 테이블 백업
          await db.execute('ALTER TABLE $tableName RENAME TO $backupTableName');
          
          // 새로운 스키마로 테이블 생성
          await db.execute('''
            CREATE TABLE $tableName(
              id TEXT PRIMARY KEY,
              title TEXT,
              content TEXT,
              rich_content TEXT,
              created_at TEXT,
              updated_at TEXT,
              is_encrypted INTEGER
            )
          ''');
          
          // 백업된 데이터를 새로운 테이블에 복사
          await db.execute('''
            INSERT INTO $tableName (id, title, content, created_at, updated_at, is_encrypted)
            SELECT id, title, content, createdAt, updatedAt, isEncrypted
            FROM $backupTableName
          ''');
          
          // 백업 테이블 삭제
          await db.execute('DROP TABLE $backupTableName');
        }
      },
    );
  }

  Future<List<Map<String, dynamic>>> getAllMemos() async {
    final db = await database;
    return await db.query(tableName);
  }

  Future<Map<String, dynamic>?> getMemoById(String id) async {
    final db = await database;
    final results = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<void> insertMemo(Memo memo) async {
    final db = await database;
    await db.insert(
      tableName,
      memo.toSqlite(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteMemo(String id) async {
    final db = await database;
    await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
} 