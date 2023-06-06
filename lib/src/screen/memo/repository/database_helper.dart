import 'dart:convert' as convert;

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:notepad/src/screen/memo/dto/memo_dto.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

const String tableName = 'memos';

class DatabaseHelper {
  var _db;

  static const SECRET_KEY = "PARKJW_PRIVATE_KEY_ENCRYPT_KEY";
  static const DATABASE_VERSION = 1;

  List<String> tables = [];

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

  Future<String> generateBackup({bool isEncrypted = false}) async {
    print('GENERATE BACKUP');
    final db = await database;

    List data = [];
    List<Map<String, dynamic>> listMaps = [];

    for (var i = 0; i < tables.length; i++) {
      listMaps = await db.query(tables[i]);
      data.add(listMaps);
    }

    List backups = [tables, data];
    String json = convert.jsonEncode(backups);

    if (isEncrypted) {
      var key = encrypt.Key.fromUtf8(SECRET_KEY);
      var iv = encrypt.IV.fromLength(16);
      var encrypter = encrypt.Encrypter(encrypt.AES(key));
      var encrypted = encrypter.encrypt(json, iv: iv);

      return encrypted.base64;
    } else {
      return json;
    }
  }

  Future<void> restoreBackup(String backup, {bool isEncrypted = false}) async {
    print('RESTORE BACKUP');
    final db = await database;

    Batch batch = db.batch();

    var key = encrypt.Key.fromUtf8(SECRET_KEY);
    var iv = encrypt.IV.fromLength(16);
    var encrypter = encrypt.Encrypter(encrypt.AES(key));

    List json = convert
        .jsonDecode(isEncrypted ? encrypter.decrypt64(backup, iv: iv) : backup);

    for (var i = 0; i < json[0].length; i++) {
      for (var k = 0; k < json[1][i].length; k++) {
        batch.insert(json[0][i], json[1][i][k]);
      }
    }

    await batch.commit(continueOnError: false, noResult: true);
  }
}
