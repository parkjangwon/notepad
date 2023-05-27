import 'package:notepad/src/screen/memo/dto/memo_dto.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

const String tableName = 'memos';

class DatabaseHelper {
  var _db;

  Future<Database> get database async {
    if (_db != null) return _db;
    _db = openDatabase(
      join(await getDatabasesPath(), 'memos.db'),
      onCreate: (db, version) {
        return db.execute(
          '''
            CREATE TABLE $tableName(
            id TEXT PRIMARY KEY,
            title TEXT,
            text TEXT,
            createdTime TEXT,
            editedTime TEXT
            )
          ''',
        );
      },
      version: 1,
    );
    return _db;
  }

  Future<void> insertMemo(MemoDTO memo) async {
    final db = await database;
    await db.insert(tableName, memo.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    print('저장 완료');
  }

  Future<List<MemoDTO>> selectMemos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);

    return List.generate(maps.length, (i) {
      return MemoDTO(
          id: maps[i]['id'],
          title: maps[i]['title'],
          text: maps[i]['text'],
          createdTime: maps[i]['createdTime'],
          editedTime: maps[i]['editedTime']);
    });
  }

  Future<List<MemoDTO>> selectMemo(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query(tableName, where: 'id = ?', whereArgs: [id]);

    return List.generate(maps.length, (i) {
      return MemoDTO(
          id: maps[i]['id'],
          title: maps[i]['title'],
          text: maps[i]['text'],
          createdTime: maps[i]['createdTime'],
          editedTime: maps[i]['editedTime']);
    });
  }

  Future<void> updateMemo(MemoDTO memo) async {
    final db = await database;
    await db
        .update(tableName, memo.toMap(), where: 'id = ?', whereArgs: [memo.id]);
  }

  Future<void> deleteMemo(String id) async {
    final db = await database;
    await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }
}
